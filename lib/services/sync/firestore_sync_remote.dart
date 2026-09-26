import 'package:cloud_firestore/cloud_firestore.dart';

import 'sync_models.dart';
import 'sync_remote.dart';
import 'user_profile.dart';

/// [SyncRemote] on Cloud Firestore, laid out so a sync touches as few
/// documents as possible:
///
/// ```
/// users/{uid}                      {schema, profile, providers, createdAt,
///                                   lastSignInAt, app, lastActiveAt,
///                                   lastFeedbackAt}
/// users/{uid}/data/settings        {app: {…, updatedAt}, reminders: {…},
///                                   prayer: {…}}
/// users/{uid}/data/favorites       {items: {thikrId: {addedAt, deletedAt}},
///                                   updatedAt}
/// users/{uid}/completions/{yyyy-MM} {days: {'2026-09-25': {morning: at, …}},
///                                   updatedAt}
/// ```
///
/// A full pull is two documents plus one per month of history (about twelve
/// a year, where a document per routine per day was ~1,460); a resume pull
/// asks only for months the server changed since the last one, normally the
/// current month. Every write is a merge into a natural key, so a retried
/// push can never duplicate anything, and the merge rules themselves stay in
/// `merge.dart`.
class FirestoreSyncRemote implements SyncRemote {
  FirestoreSyncRemote(this._db);

  final FirebaseFirestore _db;

  /// Layout version, in `users/{uid}.schema`.
  static const schema = 2;

  /// Firestore allows 500 writes per batch.
  static const _batchLimit = 450;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _settings(String uid) =>
      _user(uid).collection('data').doc('settings');

  DocumentReference<Map<String, dynamic>> _favorites(String uid) =>
      _user(uid).collection('data').doc('favorites');

  CollectionReference<Map<String, dynamic>> _months(String uid) =>
      _user(uid).collection('completions');

  /// `2026-09-25` → `2026-09`.
  static String _month(String day) => day.substring(0, 7);

  @override
  Future<RemoteState> fetch(String uid, {DateTime? completionsSince}) => _guard(
    () async {
      const server = GetOptions(source: Source.server);
      Query<Map<String, dynamic>> months = _months(uid);
      if (completionsSince != null) {
        months = months.where(
          'updatedAt',
          isGreaterThan: Timestamp.fromDate(completionsSince),
        );
      }
      final (monthDocs, settingsDoc, favoritesDoc) = await (
        months.get(server),
        _settings(uid).get(server),
        _favorites(uid).get(server),
      ).wait;

      DateTime? cursor;
      final completions = <SyncCompletion>[];
      for (final doc in monthDocs.docs) {
        final days = doc.data()['days'];
        if (days is Map) {
          for (final MapEntry(key: day, value: routines) in days.entries) {
            if (day is! String || routines is! Map) continue;
            for (final MapEntry(key: category, value: at) in routines.entries) {
              final completedAt = _date(at);
              if (category is! String || completedAt == null) continue;
              completions.add(
                SyncCompletion(
                  category: category,
                  day: day,
                  completedAt: completedAt,
                ),
              );
            }
          }
        }
        final updated = _date(doc.data()['updatedAt']);
        if (updated != null && (cursor == null || updated.isAfter(cursor))) {
          cursor = updated;
        }
      }

      final favorites = <SyncFavorite>[];
      final items = favoritesDoc.data()?['items'];
      if (items is Map) {
        for (final MapEntry(key: id, value: row) in items.entries) {
          if (id is! String || row is! Map) continue;
          final added = _date(row['addedAt']);
          if (added == null) continue;
          favorites.add(
            SyncFavorite(
              thikrId: id,
              addedAt: added,
              deletedAt: _date(row['deletedAt']),
            ),
          );
        }
      }

      final settings = <SyncGroup, SettingsSnapshot>{};
      final groups = settingsDoc.data() ?? const {};
      for (final group in SyncGroup.values) {
        final raw = groups[group.key];
        if (raw is! Map) continue;
        final values = Map<String, Object?>.of(raw.cast<String, Object?>());
        final updated = _date(values.remove('updatedAt'));
        if (updated == null) continue;
        settings[group] = SettingsSnapshot(
          group: group,
          values: values,
          updatedAt: updated,
        );
      }

      return RemoteState(
        completions: completions,
        favorites: favorites,
        settings: settings,
        completionsCursor: cursor,
      );
    },
  );

  /// Firestore's "unavailable" means no network: the caller shows offline
  /// and retries on the next resume.
  static Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') throw const SyncOffline();
      rethrow;
    }
  }

  static DateTime? _date(Object? v) => switch (v) {
    Timestamp t => t.toDate(),
    DateTime d => d,
    _ => null,
  };

  @override
  Future<void> putCompletions(String uid, List<SyncCompletion> rows) async {
    // One merge per month: a first sign-in with a year of history is about
    // twelve writes.
    final byMonth = <String, Map<String, Map<String, Timestamp>>>{};
    for (final c in rows) {
      byMonth
          .putIfAbsent(_month(c.day), () => {})
          .putIfAbsent(c.day, () => {})[c.category] = Timestamp.fromDate(
        c.completedAt,
      );
    }
    await _chunked(byMonth.entries.toList(), (batch, month) {
      batch.set(_months(uid).doc(month.key), {
        'days': month.value,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  Future<void> putFavorites(String uid, List<SyncFavorite> rows) async {
    if (rows.isEmpty) return;
    await _favorites(uid).set({
      'items': {
        for (final f in rows)
          f.thikrId: {
            'addedAt': Timestamp.fromDate(f.addedAt),
            'deletedAt': f.deletedAt == null
                ? null
                : Timestamp.fromDate(f.deletedAt!),
          },
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> putSettings(String uid, SettingsSnapshot snapshot) =>
      // A merge leaves the other two groups alone. Within this group it
      // overwrites every key, since the codec always writes all of them (and
      // lists, like the reminder slots, are replaced whole).
      _settings(uid).set({
        snapshot.group.key: {
          ...snapshot.values,
          'updatedAt': Timestamp.fromDate(snapshot.updatedAt),
        },
      }, SetOptions(merge: true));

  @override
  Future<void> putProfile(String uid, UserProfile profile) => _user(uid).set({
    'schema': schema,
    // Nested maps merge key by key, so an absent field keeps its value.
    'profile': profile.identity,
    if (profile.providers.isNotEmpty) 'providers': profile.providers,
    if (profile.createdAt != null)
      'createdAt': Timestamp.fromDate(profile.createdAt!),
    if (profile.lastSignInAt != null)
      'lastSignInAt': Timestamp.fromDate(profile.lastSignInAt!),
    if (profile.app.isNotEmpty) 'app': profile.app,
    'lastActiveAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  Future<void> _chunked<T>(
    List<T> rows,
    void Function(WriteBatch batch, T row) write,
  ) async {
    for (var i = 0; i < rows.length; i += _batchLimit) {
      final batch = _db.batch();
      for (final row in rows.skip(i).take(_batchLimit)) {
        write(batch, row);
      }
      await batch.commit();
    }
  }

  /// Also clears the first layout (`favorites/{id}`, `settings/{group}`,
  /// `completions/{day}_{category}`), which test accounts may still hold.
  /// Reads the server, never the cache, so an offline delete fails fast
  /// instead of queueing behind a stale list.
  @override
  Future<void> deleteAll(String uid) => _guard(() async {
    const server = GetOptions(source: Source.server);
    final user = _user(uid);
    for (final name in ['completions', 'data', 'favorites', 'settings']) {
      final docs = (await user.collection(name).get(server)).docs;
      await _chunked(docs, (batch, doc) => batch.delete(doc.reference));
    }
    await user.delete();
  });
}
