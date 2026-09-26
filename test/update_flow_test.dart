import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/segmented_control.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/features/update/optional_update_sheet.dart';
import 'package:mishkat/features/update/required_update_screen.dart';
import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/update/app_updater.dart';
import 'package:mishkat/services/update/update_config.dart';

import 'support/app_harness.dart';

/// The harness runs build `1.2.0 (34)`.
UpdateConfig _required({bool allowReading = true}) => UpdateConfig.fromValues(
  recommended: '1.3.0',
  minSupported: '1.3.0',
  releaseNotes: '',
  allowReading: allowReading,
);

final _optional = UpdateConfig.fromValues(
  recommended: '1.3.0',
  minSupported: '0.0.0',
  releaseNotes:
      '{"version":"1.3.0","notes":[{"icon":"bell","ar":"تذكيرات أدق على أجهزة شاومي وهواوي","en":"More accurate reminders on Xiaomi and Huawei"}]}',
  allowReading: true,
);

const _me = AppUser(
  uid: 'me',
  isAnonymous: false,
  displayName: 'Mohamed Ramadan',
  email: 'mohamed.r@gmail.com',
  provider: AuthProviderKind.google,
);

final _now = DateTime(2026, 9, 20, 9);

Future<void> _openReminders(WidgetTester tester) async {
  await tester.tap(find.text('Reminders').last);
  await AppHarness.settleWithDatabase(tester);
}

void main() {
  setUpAll(AppHarness.loadLibrary);

  group('required', () {
    testWidgets('covers the app, cached values apply with no network', (
      tester,
    ) async {
      // Offline launch: the fetch fails, the last activated values stand.
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_required()));
      await h.pump(tester, language: 'en', now: _now);

      expect(find.byType(RequiredUpdateScreen), findsOneWidget);
      expect(find.text('Mishkat needs an update'), findsOneWidget);
      expect(find.text('Update on Google Play'), findsOneWidget);
      expect(find.text('Keep reading only'), findsOneWidget);
      expect(h.updateConfig.refreshes, 1);
    });

    testWidgets('keep reading opens the app; changes stop and say why', (
      tester,
    ) async {
      final h = AppHarness(
        auth: FakeAuthService(initialUser: _me),
        updateConfig: FakeUpdateConfigSource(_required()),
      );
      await h.pump(tester, language: 'en', now: _now);
      // The launch sync waited for the gate and never reached the server.
      expect(h.syncRemote.fetches, 0);

      await tester.tap(find.text('Keep reading only'));
      await AppHarness.settleWithDatabase(tester);
      expect(find.byType(RequiredUpdateScreen), findsNothing);

      await _openReminders(tester);
      expect(
        find.text(
          'Update Mishkat to change reminders or sync. '
          'Your current reminders still arrive.',
        ),
        findsOneWidget,
      );

      final before = h.notifications.applied.last.entries.length;
      final sleepSwitch = find.byType(AppSwitch).at(3);
      await tester.scrollUntilVisible(sleepSwitch, 120);
      await tester.tap(sleepSwitch);
      await tester.pumpAndSettle();
      expect(h.notifications.applied.last.entries, hasLength(before));

      // The banner's action brings the screen back.
      await tester.scrollUntilVisible(find.text('Update'), -120);
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();
      expect(find.byType(RequiredUpdateScreen), findsOneWidget);
    });

    testWidgets('the owner can withhold «keep reading»', (tester) async {
      final h = AppHarness(
        updateConfig: FakeUpdateConfigSource(_required(allowReading: false)),
      );
      await h.pump(tester, language: 'en', now: _now);
      expect(find.text('Keep reading only'), findsNothing);
    });

    testWidgets('offline says so, and retry starts Play\'s update', (
      tester,
    ) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_required()));
      h.updater.online = false;
      await h.pump(tester, language: 'en', now: _now);

      await tester.tap(find.text('Update on Google Play'));
      await tester.pumpAndSettle();
      expect(find.text('No connection'), findsOneWidget);
      expect(h.updater.immediateUpdates, 0);

      h.updater.online = true;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(h.updater.immediateUpdates, 1);
      // Declined: back to the button.
      expect(find.text('Update on Google Play'), findsOneWidget);
    });

    testWidgets('without Play\'s in-app update, the store page opens', (
      tester,
    ) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_required()));
      h.updater.inApp = false;
      await h.pump(tester, language: 'en', now: _now);

      await tester.tap(find.text('Update on Google Play'));
      await tester.pumpAndSettle();
      expect(h.updater.storeOpens, 1);
      expect(h.updater.immediateUpdates, 0);
    });

    testWidgets('a failed immediate update falls back to the store', (
      tester,
    ) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_required()));
      h.updater.immediateResult = ImmediateResult.failed;
      await h.pump(tester, language: 'en', now: _now);

      await tester.tap(find.text('Update on Google Play'));
      await tester.pumpAndSettle();
      expect(h.updater.storeOpens, 1);
    });

    testWidgets('a fetch that lifts the minimum lifts the screen', (
      tester,
    ) async {
      final source = FakeUpdateConfigSource(_required())
        ..fetched = UpdateConfig.none;
      final h = AppHarness(updateConfig: source);
      await h.pump(tester, language: 'en', now: _now);
      expect(find.byType(RequiredUpdateScreen), findsNothing);
    });
  });

  group('optional', () {
    testWidgets('offered on launch, with its notes; Later closes it', (
      tester,
    ) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_optional));
      await h.pump(tester, now: _now);

      expect(find.byType(OptionalUpdateSheet), findsOneWidget);
      expect(find.text('تحديث جديد متاح'), findsOneWidget);
      expect(find.text('الإصدار ١٫٣٫٠'), findsOneWidget);
      expect(find.text('تذكيرات أدق على أجهزة شاومي وهواوي'), findsOneWidget);
      await tester.tap(find.text('لاحقاً'));
      await tester.pumpAndSettle();
      expect(find.byType(OptionalUpdateSheet), findsNothing);
      expect(h.updater.downloads, 0);
    });

    Map<String, Object> promptedAgo(Duration ago) => {
      'update.prompted.version': '1.3.0',
      'update.prompted.at': _now.subtract(ago).millisecondsSinceEpoch,
    };

    testWidgets('the same version stays quiet for three days', (tester) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_optional));
      await h.pump(
        tester,
        now: _now,
        extraPrefs: promptedAgo(const Duration(days: 2)),
      );
      expect(find.byType(OptionalUpdateSheet), findsNothing);
    });

    testWidgets('and comes back after them', (tester) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_optional));
      await h.pump(
        tester,
        now: _now,
        extraPrefs: promptedAgo(const Duration(days: 3)),
      );
      expect(find.byType(OptionalUpdateSheet), findsOneWidget);
    });

    testWidgets('not when a reminder opened the app', (tester) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_optional));
      h.notifications.launchedFrom = ReminderSlotId.morning;
      await h.pump(tester, now: _now);
      expect(find.byType(OptionalUpdateSheet), findsNothing);
    });

    testWidgets('Android downloads in the background, then restarts', (
      tester,
    ) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_optional));
      h.updater.finishDownload = false;
      await h.pump(tester, language: 'en', now: _now);

      await tester.tap(find.text('Update now'));
      await tester.pumpAndSettle();
      expect(find.text('Downloading the update'), findsOneWidget);
      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('a finished download offers the restart', (tester) async {
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_optional));
      await h.pump(tester, language: 'en', now: _now);

      await tester.tap(find.text('Update now'));
      await tester.pumpAndSettle();
      expect(find.text('The update is ready'), findsOneWidget);
      await tester.tap(find.text('Restart'));
      await tester.pumpAndSettle();
      expect(h.updater.installs, 1);
    });

    testWidgets('iOS opens the App Store', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final h = AppHarness(updateConfig: FakeUpdateConfigSource(_optional));
      h.updater.inApp = false;
      await h.pump(tester, language: 'en', now: _now);

      expect(find.text("Opens the app's store page"), findsOneWidget);
      await tester.tap(find.text('Update on the App Store'));
      await tester.pumpAndSettle();
      expect(h.updater.storeOpens, 1);
      expect(find.text('Downloading the update'), findsNothing);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('what\'s new', () {
    testWidgets('after an update: the toast, then the notes', (tester) async {
      final h = AppHarness();
      await h.pump(
        tester,
        language: 'en',
        now: _now,
        extraPrefs: {'update.lastSeenVersion': '0.9.0'},
      );

      expect(find.text('Updated to 1.2.0'), findsOneWidget);
      await tester.tap(find.text("What's new"));
      await tester.pumpAndSettle();
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(
        find.text(
          'Reminders that arrive on time: morning, evening, sleep and waking',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a first install is not announced, only recorded', (
      tester,
    ) async {
      final h = AppHarness();
      await h.pump(tester, language: 'en', now: _now);
      expect(find.text('Updated to 1.2.0'), findsNothing);
    });

    testWidgets('the same build again is quiet', (tester) async {
      final h = AppHarness();
      await h.pump(
        tester,
        language: 'en',
        now: _now,
        extraPrefs: {'update.lastSeenVersion': '1.2.0'},
      );
      expect(find.text('Updated to 1.2.0'), findsNothing);
    });
  });
}
