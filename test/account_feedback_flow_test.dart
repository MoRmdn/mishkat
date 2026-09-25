import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/buttons.dart';
import 'package:mishkat/core/widgets/list_rows.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/feedback/feedback_models.dart';
import 'package:mishkat/services/sync/sync_models.dart';

import 'support/app_harness.dart';

const _me = AppUser(
  uid: 'me',
  isAnonymous: false,
  displayName: 'Mohamed Ramadan',
  email: 'mohamed.r@gmail.com',
  provider: AuthProviderKind.google,
);

final _now = DateTime(2026, 9, 25, 10, 20);

FeedbackThread _thread(
  String id, {
  String uid = 'me',
  bool unreadForUser = false,
  bool unreadForAdmin = false,
  FeedbackStatus status = FeedbackStatus.open,
}) => FeedbackThread(
  id: id,
  uid: uid,
  type: FeedbackType.bug,
  status: status,
  preview: 'Evening reminder late on Xiaomi',
  createdAt: DateTime(2026, 9, 21, 18, 2),
  updatedAt: DateTime(2026, 9, 22, 9),
  unreadForUser: unreadForUser,
  unreadForAdmin: unreadForAdmin,
  device: const DeviceDetails(
    appVersion: '1.2.0 (34)',
    platform: 'Android 14 · Pixel 7',
    language: 'en',
  ),
);

List<FeedbackMessage> _messages({bool replied = false}) => [
  FeedbackMessage(
    id: 'first',
    from: MessageAuthor.user,
    body: 'My evening reminder arrived 10 minutes late.',
    createdAt: DateTime(2026, 9, 21, 18, 2),
  ),
  if (replied)
    FeedbackMessage(
      id: 'm1',
      from: MessageAuthor.admin,
      body: 'Turning on Autostart usually helps.',
      createdAt: DateTime(2026, 9, 22, 9),
    ),
];

/// Home's settings button: its dot, and what a screen reader hears.
IconCircleButton settingsButton(WidgetTester tester) =>
    tester.widget<IconCircleButton>(
      find.byWidgetPredicate(
        (w) => w is IconCircleButton && w.icon == MIcon.settings,
      ),
    );

NavRow row(WidgetTester tester, String label) => tester.widget<NavRow>(
  find.byWidgetPredicate((w) => w is NavRow && w.label == label),
);

Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(findIcon(MIcon.settings));
  await AppHarness.settleWithDatabase(tester);
}

Future<void> scrollTo(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(AppHarness.loadLibrary);

  group('signing in', () {
    testWidgets('a first sign-in merges this device and says what it added', (
      tester,
    ) async {
      final h = AppHarness();
      await h.db.recordCompletion('morning', DateTime(2026, 9, 24, 6));
      await h.db.recordCompletion('evening', DateTime(2026, 9, 24, 17));
      await h.db.addFavorite('mo1', DateTime(2026, 9, 1));
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);

      expect(find.text('Keep your progress on all your devices'), findsOne);
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      expect(find.text('Keep your wird on every device'), findsOne);

      await tester.tap(find.text('Sign in with Google'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('Your account is linked'), findsOne);
      expect(
        find.text(
          'We merged 2 sessions and 1 saved thikr from this device into your '
          'account.',
        ),
        findsOne,
      );
      expect(h.syncRemote.completions['uid-google'], hasLength(2));
      expect(h.syncRemote.favorites['uid-google']!.keys, ['mo1']);
      final profile = h.syncRemote.profiles['uid-google']!;
      expect(profile.email, 'mohamed.r@gmail.com');
      expect(profile.language, 'en');
      expect(profile.appVersion, isNotNull);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Mohamed Ramadan'), findsOne);
    });

    testWidgets('with nothing to merge a toast says signed in', (tester) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in with Apple'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('Your account is linked'), findsNothing);
      expect(find.text('Signed in'), findsOne);
    });

    testWidgets('closing the provider sheet changes nothing', (tester) async {
      final h = AppHarness();
      h.auth.nextUser = null;
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      expect(find.text('Keep your wird on every device'), findsOne);
      expect(h.auth.currentUser, isNull);
    });
  });

  group('the account', () {
    testWidgets('signing out keeps everything on this device', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      await h.db.addFavorite('mo1', DateTime(2026, 9, 1));
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);

      await tester.tap(find.text('Mohamed Ramadan'));
      await tester.pumpAndSettle();
      expect(find.textContaining('via Google'), findsOne);

      await tester.tap(find.text('Sign out'));
      await AppHarness.settleWithDatabase(tester);

      expect(h.auth.currentUser, isNull);
      expect(find.text('Keep your progress on all your devices'), findsOne);
      expect((await h.db.allFavorites()).single.thikrId, 'mo1');
    });

    testWidgets('deleting removes the account, its data and its messages', (
      tester,
    ) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      await h.syncRemote.putFavorites('me', [
        SyncFavorite(thikrId: 'mo1', addedAt: DateTime(2026, 9, 1)),
      ]);
      h.feedback.seed(_thread('t1'), messages: _messages());
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await tester.tap(find.text('Mohamed Ramadan'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Delete account'));
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(find.text('Delete your account?'), findsOne);

      await tester.tap(find.text('Delete account permanently'));
      await AppHarness.settleWithDatabase(tester);

      expect(h.auth.reauthentications, 1);
      expect(h.auth.deleted, isTrue);
      expect(h.syncRemote.holds('me'), isFalse);
      expect(h.feedback.threads, isEmpty);
      // The device keeps what it had.
      expect((await h.db.allFavorites()).single.thikrId, 'mo1');
    });
  });

  group('deleting', () {
    testWidgets('offline, nothing is deleted and the toast says why', (
      tester,
    ) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      await h.syncRemote.putFavorites('me', [
        SyncFavorite(thikrId: 'mo1', addedAt: DateTime(2026, 9, 1)),
      ]);
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await tester.tap(find.text('Mohamed Ramadan'));
      await tester.pumpAndSettle();
      h.syncRemote.online = false;

      await scrollTo(tester, find.text('Delete account'));
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete account permanently'));
      await AppHarness.settleWithDatabase(tester);

      expect(h.auth.deleted, isFalse);
      expect(h.syncRemote.holds('me'), isTrue);
      expect(find.textContaining('Check your connection'), findsOne);
    });

    testWidgets('a failure that is not the network says try later', (
      tester,
    ) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      h.auth.deleteError = StateError('invalid-credential');
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await tester.tap(find.text('Mohamed Ramadan'));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Delete account'));
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete account permanently'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.textContaining('Try again in a little while'), findsOne);
    });

    testWidgets('an Apple relay address reads as «Apple account»', (
      tester,
    ) async {
      final h = AppHarness(
        auth: FakeAuthService(
          initialUser: const AppUser(
            uid: 'me',
            isAnonymous: false,
            email: 'rtszkw7f75@privaterelay.appleid.com',
            provider: AuthProviderKind.apple,
          ),
        ),
      );
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      expect(find.text('Apple account'), findsOne);

      await tester.tap(find.text('Apple account'));
      await tester.pumpAndSettle();
      expect(find.text('Apple account'), findsOne);
      expect(find.textContaining('privaterelay.appleid.com'), findsOne);
    });
  });

  group('feedback', () {
    testWidgets('closing the sheet puts the keyboard away', (tester) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await scrollTo(tester, find.text('Feedback'));
      await tester.tap(find.text('Feedback'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      await tester.showKeyboard(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isTrue);

      await tester.tap(find.bySemanticsLabel('Close').last);
      await tester.pumpAndSettle();
      expect(tester.testTextInput.isVisible, isFalse);
      expect(
        FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<EditableText>()),
      );
    });

    testWidgets('the sheet rises above the keyboard', (tester) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await scrollTo(tester, find.text('Feedback'));
      await tester.tap(find.text('Feedback'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      final field = find.byType(TextField).first;
      final before = tester.getBottomLeft(field).dy;
      tester.view.viewInsets = FakeViewPadding(
        bottom: 300 * tester.view.devicePixelRatio,
      );
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      final screen =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final after = tester.getBottomLeft(field).dy;
      expect(after, lessThan(before));
      expect(after, lessThanOrEqualTo(screen - 300));
    });

    testWidgets('send stays off until the message has ten characters', (
      tester,
    ) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await scrollTo(tester, find.text('Feedback'));
      await tester.tap(find.text('Feedback'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('No messages yet'), findsOne);
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Too short');
      await tester.pump();
      await tester.tap(find.text('Send'));
      await tester.pump();
      expect(h.feedback.threads, isEmpty);

      await tester.enterText(
        find.byType(TextField).first,
        'Please add an Urdu translation',
      );
      await tester.pump();
      await scrollTo(tester, find.text('Send'));
      await tester.tap(find.text('Send'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('We got your message'), findsOne);
      final sent = h.feedback.threads.values.single;
      expect(sent.type, FeedbackType.feature);
      expect(sent.uid, 'uid-anon', reason: 'signed out: anonymous sender');
      expect(sent.device!.platform, 'Android 14 · Pixel 7');
    });

    testWidgets('offline, a message waits on the device and is listed', (
      tester,
    ) async {
      final h = AppHarness();
      h.auth.online = false;
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await scrollTo(tester, find.text('Feedback'));
      await tester.tap(find.text('Feedback'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('App problem'));
      await tester.enterText(
        find.byType(TextField).first,
        'My evening reminder arrived late.',
      );
      await tester.pump();
      await scrollTo(tester, find.text('Send'));
      await tester.tap(find.text('Send'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('Will send when you’re online'), findsOne);
      await tester.tapAt(const Offset(20, 20));
      await AppHarness.settleWithDatabase(tester);
      expect(find.text('Waiting to send'), findsOne);
      expect(h.feedback.threads, isEmpty);
    });

    testWidgets('a report from the reader carries the thikr', (tester) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      await tester.tap(find.text('Morning').first);
      await AppHarness.settleWithDatabase(tester);

      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report a problem with this thikr'));
      await tester.pumpAndSettle();

      expect(find.text('Report a thikr error'), findsOne);
      final send = find.text('Send report');
      await tester.tap(find.text('Source'));
      await tester.pump();
      await scrollTo(tester, send);
      await tester.tap(send);
      await AppHarness.settleWithDatabase(tester);

      final report = h.feedback.threads.values.single;
      final first = AppHarness.library.all.firstWhere(
        (t) => t.category.key == 'morning',
      );
      expect(report.type, FeedbackType.thikr);
      expect(report.thikrId, first.id);
      expect(report.issues, {ThikrIssue.source});
      expect(report.contentVersion, AppHarness.library.contentVersion);
    });

    testWidgets('a team reply shows a dot until the thread is opened', (
      tester,
    ) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      h.feedback.seed(
        _thread('t1', unreadForUser: true, status: FeedbackStatus.answered),
        messages: _messages(replied: true),
      );
      await h.pump(tester, language: 'en', now: _now);

      expect(settingsButton(tester).showDot, isTrue);
      expect(settingsButton(tester).semanticLabel, 'Settings, new reply');
      await openSettings(tester);
      await scrollTo(tester, find.text('Feedback'));
      expect(row(tester, 'Feedback').unread, isTrue);
      await tester.tap(find.text('Feedback'));
      await AppHarness.settleWithDatabase(tester);
      expect(find.text('Replied'), findsOne);

      await tester.tap(find.text('Evening reminder late on Xiaomi'));
      await AppHarness.settleWithDatabase(tester);
      expect(find.text('Mishkat team'), findsOne);
      expect(find.text('Turning on Autostart usually helps.'), findsOne);
      expect(h.feedback.threads['t1']!.unreadForUser, isFalse);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.bySemanticsLabel('Back').last);
        await AppHarness.settleWithDatabase(tester);
      }
      expect(settingsButton(tester).showDot, isFalse);
      expect(settingsButton(tester).semanticLabel, 'Settings');
    });

    testWidgets('a closed thread offers a new message, not a reply', (
      tester,
    ) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      h.feedback.seed(
        _thread('t1', status: FeedbackStatus.closed),
        messages: _messages(replied: true),
      );
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await scrollTo(tester, find.text('Feedback'));
      await tester.tap(find.text('Feedback'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('Evening reminder late on Xiaomi'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('This conversation is closed'), findsOne);
      expect(find.byType(TextField), findsNothing);
    });
  });

  group('the owner', () {
    testWidgets('only the owner sees the inbox', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      await h.pump(tester, language: 'en', now: _now);
      await openSettings(tester);
      await scrollTo(tester, find.text('Feedback'));
      expect(find.text('Inbox'), findsNothing);
    });

    testWidgets('the owner replies, and the reply answers the thread', (
      tester,
    ) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _me));
      h.feedback
        ..admins.add('me')
        ..seed(
          _thread('t1', uid: 'someone', unreadForAdmin: true),
          messages: _messages(),
        );
      await h.pump(tester, language: 'en', now: _now);
      expect(settingsButton(tester).showDot, isTrue);
      await openSettings(tester);
      await scrollTo(tester, find.text('Inbox'));
      expect(row(tester, 'Inbox').count, 1);

      await tester.tap(find.text('Inbox'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('Evening reminder late on Xiaomi'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('Message #104'), findsOne);
      expect(find.text('Android 14 · Pixel 7'), findsOne);
      expect(h.feedback.threads['t1']!.unreadForAdmin, isFalse);

      await tester.enterText(find.byType(TextField), 'Thanks for the details.');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Send reply'));
      await AppHarness.settleWithDatabase(tester);

      final t1 = h.feedback.threads['t1']!;
      expect(t1.status, FeedbackStatus.answered);
      expect(t1.unreadForUser, isTrue);
      expect(h.feedback.messageLog['t1']!.last.from, MessageAuthor.admin);
    });
  });

  group('the streak nudge', () {
    Future<AppHarness> withStreak(
      WidgetTester tester, {
      AppUser? user,
      int days = 3,
    }) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: user));
      for (var d = 0; d < days; d++) {
        await h.db.recordCompletion(
          'morning',
          _now.subtract(Duration(days: d)),
        );
      }
      await h.pump(tester, language: 'en', now: _now);
      await tester.tap(find.text('Progress'));
      await AppHarness.settleWithDatabase(tester);
      return h;
    }

    testWidgets('shows from a three-day streak and dismisses', (tester) async {
      await withStreak(tester);
      expect(find.text('Save your streak'), findsOne);
      await tester.tap(find.bySemanticsLabel('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.text('Save your streak'), findsNothing);
    });

    testWidgets('not for a shorter streak', (tester) async {
      await withStreak(tester, days: 2);
      expect(find.text('Save your streak'), findsNothing);
    });

    testWidgets('not when signed in', (tester) async {
      await withStreak(tester, user: _me);
      expect(find.text('Save your streak'), findsNothing);
    });
  });

  testWidgets('without Firebase nothing about accounts or feedback shows', (
    tester,
  ) async {
    final h = AppHarness(cloud: false);
    await h.pump(tester, language: 'en', now: _now);
    await openSettings(tester);
    expect(find.text('Keep your progress on all your devices'), findsNothing);
    expect(find.text('Feedback'), findsNothing);
    expect(find.text('About'), findsOne);
  });
}
