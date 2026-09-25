import 'package:cloud_firestore/cloud_firestore.dart';

import 'feedback_models.dart';
import 'feedback_repository.dart';

/// [FeedbackRepository] on Cloud Firestore. `firestore.rules` enforces who
/// may do what; this class only follows those rules.
class FirestoreFeedbackRepository implements FeedbackRepository {
  FirestoreFeedbackRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _threads =>
      _db.collection('feedback');

  Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') throw const FeedbackOffline();
      rethrow;
    }
  }

  @override
  Future<void> submit(FeedbackDraft d, {required String uid}) => _guard(() {
    final thread = _threads.doc(d.id);
    final message = thread.collection('messages').doc('first');
    final user = _db.collection('users').doc(uid);
    return _db.runTransaction((tx) async {
      if ((await tx.get(thread)).exists) return;
      final now = FieldValue.serverTimestamp();
      tx
        ..set(thread, {
          'uid': uid,
          'type': d.type.name,
          'status': FeedbackStatus.open.key,
          'preview': FeedbackThread.previewOf(d.body),
          'issues': [for (final i in d.issues) i.name],
          'thikrId': d.thikrId,
          'contentVersion': d.contentVersion,
          'contactEmail': d.contactEmail,
          'device': d.device?.toJson(),
          'createdAt': now,
          'updatedAt': now,
          'unreadForUser': false,
          'unreadForAdmin': true,
        })
        ..set(message, {'from': 'user', 'body': d.body, 'createdAt': now})
        ..set(user, {'lastFeedbackAt': now}, SetOptions(merge: true));
    });
  });

  @override
  Future<List<FeedbackThread>> myThreads(String uid) => _guard(() async {
    final snap = await _threads
        .where('uid', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .get();
    return [for (final doc in snap.docs) ?_thread(doc)];
  });

  @override
  Future<List<FeedbackThread>> inbox({
    FeedbackType? type,
    FeedbackStatus? status,
  }) => _guard(() async {
    Query<Map<String, dynamic>> q = _threads;
    if (type != null) q = q.where('type', isEqualTo: type.name);
    if (status != null) q = q.where('status', isEqualTo: status.key);
    final snap = await q
        .orderBy('updatedAt', descending: true)
        .limit(200)
        .get();
    return [for (final doc in snap.docs) ?_thread(doc)];
  });

  @override
  Future<FeedbackThread?> thread(String id) =>
      _guard(() async => _thread(await _threads.doc(id).get()));

  @override
  Future<List<FeedbackMessage>> messages(String threadId) => _guard(() async {
    final snap = await _threads
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt')
        .get();
    return [
      for (final doc in snap.docs)
        if (doc.data()['body'] case final String body)
          FeedbackMessage(
            id: doc.id,
            from: doc.data()['from'] == 'admin'
                ? MessageAuthor.admin
                : MessageAuthor.user,
            body: body,
            createdAt: _date(doc.data()['createdAt']) ?? DateTime.now(),
          ),
    ];
  });

  @override
  Future<void> reply(
    String threadId, {
    required MessageAuthor from,
    required String body,
  }) => _guard(() {
    final thread = _threads.doc(threadId);
    final now = FieldValue.serverTimestamp();
    final batch = _db.batch()
      ..set(thread.collection('messages').doc(), {
        'from': from.name,
        'body': body,
        'createdAt': now,
      })
      ..update(thread, {
        'updatedAt': now,
        if (from == MessageAuthor.admin) ...{
          'unreadForUser': true,
          'status': FeedbackStatus.answered.key,
        } else
          'unreadForAdmin': true,
      });
    return batch.commit();
  });

  @override
  Future<void> markRead(String threadId, {required MessageAuthor reader}) =>
      _guard(
        () => _threads.doc(threadId).update({
          reader == MessageAuthor.admin ? 'unreadForAdmin' : 'unreadForUser':
              false,
        }),
      );

  @override
  Future<void> setStatus(String threadId, FeedbackStatus status) => _guard(
    () => _threads.doc(threadId).update({
      'status': status.key,
      'closedAt': status == FeedbackStatus.closed
          ? FieldValue.serverTimestamp()
          : null,
    }),
  );

  @override
  Future<int?> assignNumber(String threadId) async {
    try {
      return await _db.runTransaction((tx) async {
        final thread = _threads.doc(threadId);
        final current = (await tx.get(thread)).data()?['number'];
        if (current is int) return current;
        final counter = _db.collection('counters').doc('feedback');
        final next = ((await tx.get(counter)).data()?['next'] as int?) ?? 1;
        tx
          ..set(counter, {'next': next + 1})
          ..update(thread, {'number': next});
        return next;
      });
    } on FirebaseException {
      return null;
    }
  }

  @override
  Future<FeedbackBadges> badges(String uid, {required bool isAdmin}) =>
      _guard(() async {
        final mine = await _threads
            .where('uid', isEqualTo: uid)
            .where('unreadForUser', isEqualTo: true)
            .count()
            .get();
        final admin = isAdmin
            ? await _threads
                  .where('unreadForAdmin', isEqualTo: true)
                  .count()
                  .get()
            : null;
        return FeedbackBadges(
          userUnread: mine.count ?? 0,
          adminUnread: admin?.count ?? 0,
        );
      });

  @override
  Future<bool> isAdmin(String uid) async {
    try {
      return (await _db.collection('admins').doc(uid).get()).exists;
    } on FirebaseException {
      return false;
    }
  }

  @override
  Future<void> deleteAllFor(String uid) => _guard(() async {
    final threads = await _threads.where('uid', isEqualTo: uid).get();
    for (final thread in threads.docs) {
      final messages = await thread.reference.collection('messages').get();
      final batch = _db.batch();
      for (final m in messages.docs) {
        batch.delete(m.reference);
      }
      batch.delete(thread.reference);
      await batch.commit();
    }
  });

  static FeedbackThread? _thread(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data();
    if (d == null) return null;
    final type = FeedbackType.fromName(d['type']);
    final uid = d['uid'];
    if (type == null || uid is! String) return null;
    // A thread written a moment ago still carries a pending server time.
    final created = _date(d['createdAt']) ?? DateTime.now();
    final device = d['device'];
    return FeedbackThread(
      id: doc.id,
      uid: uid,
      type: type,
      status: FeedbackStatus.fromKey(d['status']),
      preview: d['preview'] as String? ?? '',
      createdAt: created,
      updatedAt: _date(d['updatedAt']) ?? created,
      issues: {
        for (final i in (d['issues'] as List?) ?? const [])
          ?ThikrIssue.fromName(i),
      },
      thikrId: d['thikrId'] as String?,
      contentVersion: d['contentVersion'] as String?,
      contactEmail: d['contactEmail'] as String?,
      device: device is Map
          ? DeviceDetails.fromJson(device.cast<String, Object?>())
          : null,
      number: d['number'] as int?,
      unreadForUser: d['unreadForUser'] == true,
      unreadForAdmin: d['unreadForAdmin'] == true,
      closedAt: _date(d['closedAt']),
    );
  }

  static DateTime? _date(Object? v) => switch (v) {
    Timestamp t => t.toDate(),
    DateTime d => d,
    _ => null,
  };
}
