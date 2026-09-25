import 'package:cloud_firestore/cloud_firestore.dart';

import 'sync_models.dart';
import 'sync_remote.dart';

/// [SyncRemote] on Cloud Firestore:
///
/// ```
/// users/{uid}                              {createdAt, lastSyncAt}
/// users/{uid}/completions/{day}_{category} {category, day, completedAt, syncedAt}
/// users/{uid}/favorites/{thikrId}          {addedAt, deletedAt?}
/// users/{uid}/settings/{app|reminders|prayer} {values…, updatedAt}
/// ```
///
/// Document ids are the natural keys, so every write is idempotent and a
/// retried push can never duplicate a row.
class FirestoreSyncRemote implements SyncRemote {
  FirestoreSyncRemote(this._db);

  final FirebaseFirestore _db;

  /// Firestore allows 500 writes per batch.
  static const _batchLimit = 450;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  @override
  Future<RemoteState> fetch(String uid, {DateTime? completionsSince}) async {
    const server = GetOptions(source: Source.server);
    final user = _user(uid);
    try {
      Query<Map<String, dynamic>> completionsQuery = user.collection(
        'completions',
      );
      if (completionsSince != null) {
        completionsQuery = completionsQuery.where(
          'syncedAt',
          isGreaterThan: Timestamp.fromDate(completionsSince),
        );
      }
      final results = await Future.wait([
        completionsQuery.get(server),
        user.collection('favorites').get(server),
        user.collection('settings').get(server),
      ]);

      DateTime? cursor;
      final completions = <SyncCompletion>[];
      for (final doc in results[0].docs) {
        final d = doc.data();
        final at = _date(d['completedAt']);
        final category = d['category'], day = d['day'];
        if (at == null || category is! String || day is! String) continue;
        completions.add(
          SyncCompletion(category: category, day: day, completedAt: at),
        );
        final synced = _date(d['syncedAt']);
        if (synced != null && (cursor == null || synced.isAfter(cursor))) {
          cursor = synced;
        }
      }

      final favorites = <SyncFavorite>[];
      for (final doc in results[1].docs) {
        final added = _date(doc.data()['addedAt']);
        if (added == null) continue;
        favorites.add(
          SyncFavorite(
            thikrId: doc.id,
            addedAt: added,
            deletedAt: _date(doc.data()['deletedAt']),
          ),
        );
      }

      final settings = <SyncGroup, SettingsSnapshot>{};
      for (final doc in results[2].docs) {
        final group = SyncGroup.values
            .where((g) => g.key == doc.id)
            .firstOrNull;
        final data = Map<String, Object?>.of(doc.data());
        final updated = _date(data.remove('updatedAt'));
        if (group == null || updated == null) continue;
        settings[group] = SettingsSnapshot(
          group: group,
          values: data,
          updatedAt: updated,
        );
      }

      return RemoteState(
        completions: completions,
        favorites: favorites,
        settings: settings,
        completionsCursor: cursor,
      );
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
  Future<void> putCompletions(String uid, List<SyncCompletion> rows) =>
      _chunked(rows, (batch, c) {
        batch.set(_user(uid).collection('completions').doc(c.key), {
          'category': c.category,
          'day': c.day,
          'completedAt': Timestamp.fromDate(c.completedAt),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      });

  @override
  Future<void> putFavorites(String uid, List<SyncFavorite> rows) =>
      _chunked(rows, (batch, f) {
        batch.set(_user(uid).collection('favorites').doc(f.thikrId), {
          'addedAt': Timestamp.fromDate(f.addedAt),
          'deletedAt': f.deletedAt == null
              ? null
              : Timestamp.fromDate(f.deletedAt!),
        });
      });

  @override
  Future<void> putSettings(String uid, SettingsSnapshot snapshot) {
    final batch = _db.batch()
      ..set(_user(uid).collection('settings').doc(snapshot.group.key), {
        ...snapshot.values,
        'updatedAt': Timestamp.fromDate(snapshot.updatedAt),
      })
      ..set(_user(uid), {
        'lastSyncAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    return batch.commit();
  }

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

  @override
  Future<void> deleteAll(String uid) async {
    final user = _user(uid);
    for (final name in ['completions', 'favorites', 'settings']) {
      final docs = (await user.collection(name).get()).docs;
      await _chunked(docs, (batch, doc) => batch.delete(doc.reference));
    }
    await user.delete();
  }
}
