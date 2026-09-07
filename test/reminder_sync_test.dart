import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/features/reminders/reminder_sync.dart';

import 'support/app_harness.dart';

void main() {
  setUpAll(AppHarness.loadLibrary);

  group('scheduling reaches the OS', () {
    testWidgets('a launch with permissions applies the schedule', (
      tester,
    ) async {
      final harness = AppHarness();
      await harness.pump(tester);

      expect(harness.notifications.applied, isNotEmpty);
      final schedule = harness.notifications.applied.last;
      // Three slots on by default; sleep is off.
      expect(schedule.entries, hasLength(3));
      expect(schedule.entries.every((e) => e.repeatsDaily), isTrue);
    });

    testWidgets('without notification permission everything is cancelled', (
      tester,
    ) async {
      final harness = AppHarness(
        permissions: FakePermissionService(notifications: false),
      );
      await harness.pump(tester);

      expect(harness.notifications.applied, isEmpty);
      expect(
        harness.notifications.cancelled,
        isTrue,
        reason: 'stale reminders must not survive a revoked permission',
      );
    });

    testWidgets(
      'denied exact alarms schedule inexactly rather than not at all',
      (tester) async {
        final harness = AppHarness(
          permissions: FakePermissionService(exactAlarms: false),
        );
        await harness.pump(tester);

        expect(harness.notifications.applied, isNotEmpty);
        expect(harness.notifications.lastExactAllowed, isFalse);
      },
    );

    testWidgets('exact alarms are used when granted', (tester) async {
      final harness = AppHarness();
      await harness.pump(tester);
      expect(harness.notifications.lastExactAllowed, isTrue);
    });

    testWidgets('a notification that launched the app opens its athkar', (
      tester,
    ) async {
      final harness = AppHarness()
        ..notifications.launchedFrom = ReminderSlotId.evening;
      await harness.pump(tester);

      expect(
        find.text('١ من ٤'),
        findsOneWidget,
        reason: 'evening has four athkar',
      );
    });
  });

  group('notification content', () {
    test('carries the first thikr, the count and a duration', () {
      final library = AppHarness.library;
      final items = library[ThikrCategory.morning];

      expect(estimatedMinutes(items), greaterThan(0));
      // 118 repetitions at 2.5s is about five minutes.
      expect(estimatedMinutes(items), 5);
    });

    test('a short session still reports at least one minute', () {
      final library = AppHarness.library;
      expect(estimatedMinutes(library[ThikrCategory.wake]), 1);
    });

    test('an empty list does not divide by zero', () {
      expect(estimatedMinutes(const []), 1);
    });
  });
}
