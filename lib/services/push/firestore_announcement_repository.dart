import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'announcement_repository.dart';
import 'push_models.dart';

/// [AnnouncementRepository] on Cloud Firestore. `firestore.rules` enforces
/// who may write what; this class only follows those rules.
///
/// Publishing is two steps: write the document, then call `sendAnnouncement`
/// (`functions/`) to push it. The database's region has no Firestore
/// triggers, so nothing sends it on its own.
class FirestoreAnnouncementRepository implements AnnouncementRepository {
  FirestoreAnnouncementRepository(this._db, this._functions);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Map<String, dynamic>> get _announcements =>
      _db.collection('announcements');

  @override
  Future<List<Announcement>> latest({int limit = 50}) async {
    final snap = await _announcements
        .orderBy('createdAt', descending: true)
        .limit(limit)
        // A just-published one read back from the local cache has no
        // server time yet: estimate it rather than drop it.
        .get(
          const GetOptions(
            serverTimestampBehavior: ServerTimestampBehavior.estimate,
          ),
        );
    return [for (final doc in snap.docs) ?_announcement(doc)];
  }

  @override
  Future<void> publish(AnnouncementDraft draft, {required String uid}) async {
    final d = draft.trimmed;
    final ref = await _announcements.add({
      'titleAr': d.titleAr,
      'titleEn': d.titleEn,
      'bodyAr': d.bodyAr,
      'bodyEn': d.bodyEn,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': uid,
    });
    try {
      await _functions.httpsCallable('sendAnnouncement').call<Object?>({
        'id': ref.id,
      });
    } catch (_) {
      // Not pushed: take it back down, so a retry does not list it twice.
      // If the push did go out and only the answer was lost, keep it.
      try {
        final snap = await ref.get(const GetOptions(source: Source.server));
        if (snap.data()?['pushedAt'] == null) await ref.delete();
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) => _announcements.doc(id).delete();

  @override
  Future<void> registerDevice(
    String uid,
    String deviceId, {
    required String token,
    required String languageCode,
    required String platform,
  }) => _device(uid, deviceId).set({
    'token': token,
    'lang': languageCode,
    'platform': platform,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> removeDevice(String uid, String deviceId) =>
      _device(uid, deviceId).delete();

  DocumentReference<Map<String, dynamic>> _device(String uid, String id) =>
      _db.collection('users').doc(uid).collection('devices').doc(id);

  static Announcement? _announcement(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    if (d == null) return null;
    return switch ((
      d['titleAr'],
      d['titleEn'],
      d['bodyAr'],
      d['bodyEn'],
      d['createdAt'],
    )) {
      (
        final String titleAr,
        final String titleEn,
        final String bodyAr,
        final String bodyEn,
        final Timestamp createdAt,
      ) =>
        Announcement(
          id: doc.id,
          titleAr: titleAr,
          titleEn: titleEn,
          bodyAr: bodyAr,
          bodyEn: bodyEn,
          createdAt: createdAt.toDate(),
        ),
      _ => null,
    };
  }
}
