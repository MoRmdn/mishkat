import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'push_models.dart';

/// The owner's announcements, and where each device receives replies.
///
/// ```
/// announcements/{id}                  {titleAr, titleEn, bodyAr, bodyEn,
///                                      createdAt, createdBy}: public
/// users/{uid}/devices/{deviceId}      {token, lang, platform, updatedAt}
/// ```
///
/// A new announcement document is what sends the push: `functions/` watches
/// the collection. Keeping them in Firestore also lets someone who missed
/// the push, or has pushes off, read them on the notifications page.
abstract class AnnouncementRepository {
  /// Newest first. Empty when the server cannot be reached and nothing is
  /// cached.
  Future<List<Announcement>> latest({int limit = 50});

  /// Owner only. Publishing is sending: every subscribed phone gets it.
  Future<void> publish(AnnouncementDraft draft, {required String uid});

  /// Owner only. Removes it from the page; a push already delivered stays.
  Future<void> delete(String id);

  /// Records this install's token under the account, so a reply to the
  /// account's feedback reaches this phone in [languageCode].
  Future<void> registerDevice(
    String uid,
    String deviceId, {
    required String token,
    required String languageCode,
    required String platform,
  });

  Future<void> removeDevice(String uid, String deviceId);
}

class _NoAnnouncements implements AnnouncementRepository {
  const _NoAnnouncements();

  @override
  Future<List<Announcement>> latest({int limit = 50}) async => const [];

  @override
  Future<void> publish(AnnouncementDraft draft, {required String uid}) =>
      Future.error(StateError('Announcements are unavailable'));

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> registerDevice(
    String uid,
    String deviceId, {
    required String token,
    required String languageCode,
    required String platform,
  }) async {}

  @override
  Future<void> removeDevice(String uid, String deviceId) async {}
}

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => const _NoAnnouncements(),
);
