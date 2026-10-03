/// What a push carries in its `data`, as `functions/` sends it. The visible
/// title and body are the OS's business; the app only needs to know where a
/// tap leads.
sealed class PushMessage {
  const PushMessage();

  /// Null for anything this build does not recognise — a newer server's
  /// message type opens the app and goes nowhere.
  static PushMessage? fromData(Map<String, Object?> data) =>
      switch ((data['type'], data['id'], data['threadId'])) {
        ('announcement', final String id, _) when id.isNotEmpty =>
          AnnouncementPush(id),
        ('reply', _, final String threadId) when threadId.isNotEmpty =>
          ReplyPush(threadId),
        _ => null,
      };
}

/// The owner's message to everyone: opens the notifications page.
final class AnnouncementPush extends PushMessage {
  const AnnouncementPush(this.id);

  final String id;

  @override
  bool operator ==(Object other) => other is AnnouncementPush && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The owner answered this user's feedback: opens the conversation.
final class ReplyPush extends PushMessage {
  const ReplyPush(this.threadId);

  final String threadId;

  @override
  bool operator ==(Object other) =>
      other is ReplyPush && other.threadId == threadId;

  @override
  int get hashCode => threadId.hashCode;
}

/// FCM topics, one per language, so an announcement arrives in the language
/// the app is set to without the server knowing who anyone is.
String announcementTopic(String languageCode) => 'announcements_$languageCode';
const kAnnouncementLanguages = ['ar', 'en'];

/// One announcement, in both languages; the page shows the app's.
class Announcement {
  const Announcement({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.createdAt,
  });

  final String id;
  final String titleAr, titleEn, bodyAr, bodyEn;
  final DateTime createdAt;

  String title(String languageCode) => languageCode == 'ar' ? titleAr : titleEn;
  String body(String languageCode) => languageCode == 'ar' ? bodyAr : bodyEn;
}

/// What the owner's composer publishes. Limits match `firestore.rules`.
class AnnouncementDraft {
  const AnnouncementDraft({
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
  });

  static const maxTitle = 80;
  static const maxBody = 500;

  final String titleAr, titleEn, bodyAr, bodyEn;

  AnnouncementDraft get trimmed => AnnouncementDraft(
    titleAr: titleAr.trim(),
    titleEn: titleEn.trim(),
    bodyAr: bodyAr.trim(),
    bodyEn: bodyEn.trim(),
  );

  bool get isValid {
    final t = trimmed;
    bool ok(String s, int max) => s.isNotEmpty && s.length <= max;
    return ok(t.titleAr, maxTitle) &&
        ok(t.titleEn, maxTitle) &&
        ok(t.bodyAr, maxBody) &&
        ok(t.bodyEn, maxBody);
  }
}

/// Whether any announcement is newer than the last one the user saw. With
/// nothing seen yet, everything is new.
bool hasUnreadAnnouncements(List<Announcement> list, DateTime? seenUpTo) =>
    list.any((a) => seenUpTo == null || a.createdAt.isAfter(seenUpTo));
