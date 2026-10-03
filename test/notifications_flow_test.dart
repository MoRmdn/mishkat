import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/app.dart';
import 'package:mishkat/core/widgets/buttons.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/features/account/account_actions.dart';
import 'package:mishkat/features/notifications/notifications_page.dart';
import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/feedback/feedback_models.dart';
import 'package:mishkat/services/push/push_models.dart';
import 'package:mishkat/services/update/update_config.dart';

import 'support/app_harness.dart';

const _me = AppUser(
  uid: 'me',
  isAnonymous: false,
  displayName: 'Mohamed Ramadan',
  email: 'mohamed.r@gmail.com',
  provider: AuthProviderKind.google,
);

final _now = DateTime(2026, 9, 25, 10, 20);

Announcement _announcement(String id, {DateTime? at, String title = 'Iftar'}) =>
    Announcement(
      id: id,
      titleAr: 'أذكار الإفطار',
      titleEn: '$title athkar added',
      bodyAr: 'أضفنا أذكار الإفطار إلى المكتبة.',
      bodyEn: 'The iftar athkar are now in the library.',
      createdAt: at ?? DateTime(2026, 9, 24, 18),
    );

/// Home's notifications button.
IconCircleButton? bell(WidgetTester tester) {
  final f = find.byWidgetPredicate(
    (w) => w is IconCircleButton && w.icon == MIcon.inbox,
  );
  return f.evaluate().isEmpty ? null : tester.widget<IconCircleButton>(f);
}

ProviderContainer container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MishkatApp)));

void main() {
  setUpAll(AppHarness.loadLibrary);

  group('the bell', () {
    testWidgets('without Firebase there is no bell', (tester) async {
      final h = AppHarness(cloud: false)
        ..announcements.seed(_announcement('a1'));
      await h.pump(tester, language: 'en', now: _now);
      expect(bell(tester), isNull);
      expect(h.push.started, isFalse);
    });

    testWidgets('a dot for an unseen announcement, gone once it is read', (
      tester,
    ) async {
      final h = AppHarness()..announcements.seed(_announcement('a1'));
      await h.pump(tester, language: 'en', now: _now);
      expect(bell(tester)!.showDot, isTrue);
      expect(bell(tester)!.semanticLabel, 'Notifications, new announcement');

      await tester.tap(findIcon(MIcon.inbox));
      await AppHarness.settleWithDatabase(tester);
      expect(find.byType(NotificationsPage), findsOne);
      expect(find.text('Iftar athkar added'), findsOne);
      expect(find.text('The iftar athkar are now in the library.'), findsOne);
      expect(find.text('Yesterday'), findsOne);

      await tester.tap(find.bySemanticsLabel('Back'));
      await AppHarness.settleWithDatabase(tester);
      expect(bell(tester)!.showDot, isFalse);
    });

    testWidgets('seen stays seen after a relaunch', (tester) async {
      final h = AppHarness()..announcements.seed(_announcement('a1'));
      await h.pump(tester, language: 'en', now: _now);
      await tester.tap(findIcon(MIcon.inbox));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.bySemanticsLabel('Back'));
      await AppHarness.settleWithDatabase(tester);

      await h.pump(tester, language: 'en', now: _now, resetPrefs: false);
      expect(bell(tester)!.showDot, isFalse);
    });

    testWidgets('shows the app language, and an empty page says so', (
      tester,
    ) async {
      final h = AppHarness();
      await h.pump(tester, language: 'ar', now: _now);
      expect(bell(tester)!.showDot, isFalse);
      await tester.tap(findIcon(MIcon.inbox));
      await AppHarness.settleWithDatabase(tester);
      expect(find.text('لا إشعارات بعد'), findsOne);

      h.announcements.seed(_announcement('a1'));
      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await AppHarness.settleWithDatabase(tester);
      expect(find.text('أذكار الإفطار'), findsOne);
    });

    testWidgets('a push that arrives while open lights the dot', (
      tester,
    ) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      expect(bell(tester)!.showDot, isFalse);

      h.announcements.seed(_announcement('a2'));
      h.push.foreground.add(const AnnouncementPush('a2'));
      await AppHarness.settleWithDatabase(tester);
      expect(bell(tester)!.showDot, isTrue);
    });
  });

  group('a tapped push', () {
    testWidgets('an announcement opens the notifications page', (tester) async {
      final h = AppHarness()..announcements.seed(_announcement('a1'));
      await h.pump(tester, language: 'en', now: _now);
      h.push.opened.add(const AnnouncementPush('a1'));
      await AppHarness.settleWithDatabase(tester);
      final page = tester.widget<NotificationsPage>(
        find.byType(NotificationsPage),
      );
      expect(page.highlight, 'a1');
    });

    testWidgets('one that launched the app opens once onboarding is done', (
      tester,
    ) async {
      final h = AppHarness()..announcements.seed(_announcement('a1'));
      h.push.launchMessage = const AnnouncementPush('a1');
      await h.pump(tester, language: 'en', now: _now);
      expect(find.byType(NotificationsPage), findsOne);
    });

    testWidgets('a reply opens its conversation', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      h.feedback.seed(
        FeedbackThread(
          id: 't1',
          uid: 'me',
          type: FeedbackType.bug,
          status: FeedbackStatus.answered,
          preview: 'Evening reminder late on Xiaomi',
          createdAt: DateTime(2026, 9, 21, 18, 2),
          updatedAt: DateTime(2026, 9, 22, 9),
          unreadForUser: true,
          unreadForAdmin: false,
        ),
        messages: [
          FeedbackMessage(
            id: 'm1',
            from: MessageAuthor.admin,
            body: 'Turning on Autostart usually helps.',
            createdAt: DateTime(2026, 9, 22, 9),
          ),
        ],
      );
      h.push.launchMessage = const ReplyPush('t1');
      await h.pump(tester, language: 'en', now: _now);
      expect(find.text('Turning on Autostart usually helps.'), findsOne);
      expect(h.feedback.threads['t1']!.unreadForUser, isFalse);
    });
  });

  group('topics', () {
    testWidgets('the app language’s only', (tester) async {
      final h = AppHarness();
      await h.pump(tester, language: 'ar', now: _now);
      expect(h.push.topics, {'announcements_ar'});
      expect(h.notifications.messagesChannel, 'رسائل مشكاة');
    });

    testWidgets('follow a language change', (tester) async {
      final h = AppHarness();
      await h.pump(tester, language: 'ar', now: _now);
      await tester.tap(findIcon(MIcon.settings));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('English'));
      await AppHarness.settleWithDatabase(tester);
      expect(h.push.topics, {'announcements_en'});
      expect(h.notifications.messagesChannel, 'Mishkat messages');
    });

    testWidgets('none once announcements are switched off', (tester) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      await tester.tap(findIcon(MIcon.inbox));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('Announcement notifications'));
      await AppHarness.settleWithDatabase(tester);
      expect(h.push.topics, isEmpty);
    });
  });

  group('the device, for replies', () {
    testWidgets('is registered under the account in its language', (
      tester,
    ) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      await h.pump(tester, language: 'en', now: _now);
      final devices = h.announcements.devices['me']!;
      expect(devices.values.single, (token: 'token-1', lang: 'en'));
    });

    testWidgets('not while there is no account at all', (tester) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      expect(h.announcements.devices, isEmpty);
    });

    testWidgets('a new token replaces the old one', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      await h.pump(tester, language: 'en', now: _now);
      h.push.tokenRefresh.add('token-2');
      await AppHarness.settleWithDatabase(tester);
      final devices = h.announcements.devices['me']!;
      expect(devices.length, 1);
      expect(devices.values.single.token, 'token-2');
    });

    testWidgets('is removed on sign-out', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      await h.pump(tester, language: 'en', now: _now);
      expect(h.announcements.devices, contains('me'));
      await container(tester).read(accountActionsProvider).signOut();
      await AppHarness.settleWithDatabase(tester);
      expect(h.announcements.devices, isEmpty);
    });

    testWidgets('is not written below the minimum version', (tester) async {
      final h = AppHarness(
        auth: FakeAuthService(initialUser: _me),
        updateConfig: FakeUpdateConfigSource(
          UpdateConfig.fromValues(
            recommended: '1.3.0',
            minSupported: '1.3.0',
            releaseNotes: '',
            allowReading: true,
          ),
        ),
      );
      await h.pump(tester, language: 'en', now: _now);
      expect(h.announcements.devices, isEmpty);
    });
  });

  group('the owner', () {
    Future<void> openComposer(WidgetTester tester) async {
      await openAboutPage(tester);
      final row = find.text('Send announcement');
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await AppHarness.settleWithDatabase(tester);
    }

    testWidgets('only the owner can send one', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      await h.pump(tester, language: 'en', now: _now);
      await openAboutPage(tester);
      expect(find.text('Send announcement'), findsNothing);
    });

    testWidgets('writes both languages after a confirmation', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      h.feedback.admins.add('me');
      await h.pump(tester, language: 'en', now: _now);
      await openComposer(tester);

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'أذكار الإفطار');
      await tester.enterText(fields.at(1), 'أضفناها إلى المكتبة.');
      await tester.enterText(fields.at(2), 'Iftar athkar');
      await tester.enterText(fields.at(3), 'Now in the library.');
      await tester.pump();

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(find.text('Send to everyone?'), findsOne);
      await tester.tap(find.text('Send').last);
      await AppHarness.settleWithDatabase(tester);

      final sent = h.announcements.announcements.single;
      expect(sent.titleAr, 'أذكار الإفطار');
      expect(sent.bodyEn, 'Now in the library.');
      expect(find.text('Announcement sent'), findsOne);
    });

    testWidgets('send stays off until every field is filled', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      h.feedback.admins.add('me');
      await h.pump(tester, language: 'en', now: _now);
      await openComposer(tester);
      await tester.enterText(find.byType(TextField).first, 'Only a title');
      await tester.pump();
      final send = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(send.onPressed, isNull);
    });
  });
}
