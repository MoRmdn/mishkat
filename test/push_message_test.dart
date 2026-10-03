import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/services/push/push_models.dart';

Announcement _at(String id, DateTime at) => Announcement(
  id: id,
  titleAr: 'عنوان',
  titleEn: 'Title',
  bodyAr: 'نص',
  bodyEn: 'Body',
  createdAt: at,
);

void main() {
  group('PushMessage.fromData', () {
    // functions/src/messages.ts builds these; the two must agree.
    test('an announcement names its id', () {
      expect(
        PushMessage.fromData({'type': 'announcement', 'id': 'a1'}),
        const AnnouncementPush('a1'),
      );
    });

    test('a reply names its thread', () {
      expect(
        PushMessage.fromData({'type': 'reply', 'threadId': 't9'}),
        const ReplyPush('t9'),
      );
    });

    test('anything else, or a missing id, is ignored', () {
      expect(PushMessage.fromData({'type': 'promo', 'id': 'x'}), isNull);
      expect(PushMessage.fromData({'type': 'announcement'}), isNull);
      expect(PushMessage.fromData({'type': 'reply', 'threadId': ''}), isNull);
      expect(PushMessage.fromData(const {}), isNull);
    });
  });

  group('unread announcements', () {
    final sep20 = DateTime(2026, 9, 20);
    final sep24 = DateTime(2026, 9, 24);

    test('with nothing seen, any is unread', () {
      expect(hasUnreadAnnouncements([_at('a', sep20)], null), isTrue);
      expect(hasUnreadAnnouncements(const [], null), isFalse);
    });

    test('only one newer than the last seen counts', () {
      expect(hasUnreadAnnouncements([_at('a', sep20)], sep20), isFalse);
      expect(
        hasUnreadAnnouncements([_at('a', sep20), _at('b', sep24)], sep20),
        isTrue,
      );
    });
  });

  test('one topic per language', () {
    expect(announcementTopic('ar'), 'announcements_ar');
    expect(announcementTopic('en'), 'announcements_en');
  });

  group('AnnouncementDraft', () {
    AnnouncementDraft draft({String title = 'T', String body = 'B'}) =>
        AnnouncementDraft(
          titleAr: title,
          titleEn: 'T',
          bodyAr: body,
          bodyEn: 'B',
        );

    test('needs every field, within the rules’ limits', () {
      expect(draft().isValid, isTrue);
      expect(draft(title: '   ').isValid, isFalse);
      expect(draft(title: 'x' * 80).isValid, isTrue);
      expect(draft(title: 'x' * 81).isValid, isFalse);
      expect(draft(body: 'x' * 500).isValid, isTrue);
      expect(draft(body: 'x' * 501).isValid, isFalse);
    });

    test('is trimmed before it is sent', () {
      expect(draft(title: '  T  ').trimmed.titleAr, 'T');
    });
  });
}
