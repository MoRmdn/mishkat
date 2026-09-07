import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/services/reminder_scheduler.dart';

/// Prayer times that are the same clock times every day, so expectations stay
/// readable. Fajr 04:48, Asr 15:30, Maghrib 18:24 — the design's sample day.
PrayerTimesForDay constantTimes({bool available = true}) {
  return (day) {
    if (!available) return null;
    DateTime at(int h, int m) => DateTime(day.year, day.month, day.day, h, m);
    return (fajr: at(4, 48), asr: at(15, 30), maghrib: at(18, 24));
  };
}

ReminderSettings settingsWith({
  ReminderMode mode = ReminderMode.fixed,
  Set<ReminderSlotId> enabled = const {
    ReminderSlotId.wake,
    ReminderSlotId.morning,
    ReminderSlotId.evening,
  },
}) {
  return ReminderSettings(
    mode: mode,
    slots: [
      for (final s in ReminderSettings.defaultSlots)
        s.copyWith(enabled: enabled.contains(s.id)),
    ],
  );
}

void main() {
  group('nextOccurrence', () {
    test('returns today when the time is still ahead', () {
      final now = DateTime(2026, 9, 7, 5, 0);
      expect(nextOccurrence(now, 6, 30), DateTime(2026, 9, 7, 6, 30));
    });

    test('rolls to tomorrow when the time has passed', () {
      final now = DateTime(2026, 9, 7, 7, 0);
      expect(nextOccurrence(now, 6, 30), DateTime(2026, 9, 8, 6, 30));
    });

    test('treats exactly now as passed', () {
      final now = DateTime(2026, 9, 7, 6, 30);
      expect(nextOccurrence(now, 6, 30), DateTime(2026, 9, 8, 6, 30));
    });

    test('keeps the wall-clock time across a month boundary', () {
      final now = DateTime(2026, 9, 30, 23, 0);
      final next = nextOccurrence(now, 6, 30);
      expect(next, DateTime(2026, 10, 1, 6, 30));
      expect(next.hour, 6);
      expect(next.minute, 30);
    });

    test('keeps the wall-clock time across a DST transition', () {
      // Whatever the host zone, stepping the calendar day must preserve the
      // hour and minute — Duration(days: 1) would not on a DST night.
      for (final start in [
        DateTime(2026, 3, 28, 23, 0),
        DateTime(2026, 10, 24, 23, 0),
        DateTime(2026, 11, 1, 1, 0),
      ]) {
        final next = nextOccurrence(start, 6, 30);
        expect(next.hour, 6, reason: 'from $start');
        expect(next.minute, 30, reason: 'from $start');
      }
    });
  });

  group('fixed mode', () {
    test('gives each enabled slot one self-repeating notification', () {
      final schedule = buildSchedule(
        settings: settingsWith(),
        now: DateTime(2026, 9, 7, 3, 0),
      );

      expect(schedule.entries, hasLength(3));
      expect(schedule.entries.every((e) => e.repeatsDaily), isTrue);
      expect(
        schedule.repeatsForever,
        isTrue,
        reason: 'nothing can expire, so nothing to top up',
      );
      expect(schedule.scheduledThrough, isNull);
    });

    test('disabled slots are not scheduled', () {
      final schedule = buildSchedule(
        settings: settingsWith(enabled: {ReminderSlotId.morning}),
        now: DateTime(2026, 9, 7, 3, 0),
      );

      expect(schedule.entries, hasLength(1));
      expect(schedule.entries.single.slot, ReminderSlotId.morning);
    });

    test('an all-off configuration schedules nothing', () {
      final schedule = buildSchedule(
        settings: settingsWith(enabled: const {}),
        now: DateTime(2026, 9, 7, 3, 0),
      );
      expect(schedule.entries, isEmpty);
    });

    test('times match the slot settings', () {
      final schedule = buildSchedule(
        settings: settingsWith(enabled: {ReminderSlotId.morning}),
        now: DateTime(2026, 9, 7, 3, 0),
      );
      final e = schedule.entries.single;
      expect(e.at, DateTime(2026, 9, 7, 6, 30));
    });
  });

  group('prayer mode', () {
    test('anchored slots are windowed and the sleep slot still repeats', () {
      final schedule = buildSchedule(
        settings: settingsWith(
          mode: ReminderMode.prayer,
          enabled: {
            ReminderSlotId.wake,
            ReminderSlotId.morning,
            ReminderSlotId.evening,
            ReminderSlotId.sleep,
          },
        ),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: constantTimes(),
      );

      final sleep = schedule.entries.where(
        (e) => e.slot == ReminderSlotId.sleep,
      );
      expect(sleep, hasLength(1));
      expect(
        sleep.single.repeatsDaily,
        isTrue,
        reason: 'bedtime is not a function of the sun',
      );

      // Three anchored slots across a 14-day window.
      final windowed = schedule.entries.where((e) => !e.repeatsDaily);
      expect(windowed, hasLength(3 * 14));
      expect(schedule.scheduledThrough, isNotNull);
    });

    test('applies the design offsets to the right anchors', () {
      final schedule = buildSchedule(
        settings: settingsWith(mode: ReminderMode.prayer),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: constantTimes(),
        windowDays: 1,
      );

      DateTime timeOf(ReminderSlotId id) =>
          schedule.entries.firstWhere((e) => e.slot == id).at;

      // Fajr 04:48 − 15, Fajr 04:48 + 30, Asr 15:30 + 45.
      expect(timeOf(ReminderSlotId.wake), DateTime(2026, 9, 7, 4, 33));
      expect(timeOf(ReminderSlotId.morning), DateTime(2026, 9, 7, 5, 18));
      expect(timeOf(ReminderSlotId.evening), DateTime(2026, 9, 7, 16, 15));
    });

    test('skips times that have already passed today', () {
      final schedule = buildSchedule(
        settings: settingsWith(mode: ReminderMode.prayer),
        now: DateTime(2026, 9, 7, 12, 0), // after both Fajr-derived slots
        prayerTimes: constantTimes(),
        windowDays: 1,
      );

      final slots = schedule.entries.map((e) => e.slot).toSet();
      expect(slots, {ReminderSlotId.evening});
    });

    test('notification ids are unique across the whole window', () {
      final schedule = buildSchedule(
        settings: settingsWith(
          mode: ReminderMode.prayer,
          enabled: ReminderSlotId.values.toSet(),
        ),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: constantTimes(),
      );

      final ids = schedule.entries.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('entries come back in chronological order', () {
      final schedule = buildSchedule(
        settings: settingsWith(mode: ReminderMode.prayer),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: constantTimes(),
      );

      for (var i = 1; i < schedule.entries.length; i++) {
        expect(
          schedule.entries[i].at.isBefore(schedule.entries[i - 1].at),
          isFalse,
        );
      }
    });
  });

  group('the iOS cap', () {
    test('never schedules more than the safety limit', () {
      final schedule = buildSchedule(
        settings: settingsWith(
          mode: ReminderMode.prayer,
          enabled: ReminderSlotId.values.toSet(),
        ),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: constantTimes(),
        windowDays: 60, // far more than would fit
      );

      expect(schedule.pendingCount, lessThanOrEqualTo(kMaxPendingReminders));
      expect(schedule.pendingCount, lessThan(kIosPendingCap));
    });

    test('the reported window shrinks to what was actually scheduled', () {
      final schedule = buildSchedule(
        settings: settingsWith(
          mode: ReminderMode.prayer,
          enabled: ReminderSlotId.values.toSet(),
        ),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: constantTimes(),
        windowDays: 60,
      );

      // Must not claim coverage past the last entry actually kept.
      final latest = schedule.entries
          .where((e) => !e.repeatsDaily)
          .map((e) => e.at)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      expect(schedule.scheduledThrough, latest);
    });

    test('the default 14-day window stays comfortably under the cap', () {
      final schedule = buildSchedule(
        settings: settingsWith(
          mode: ReminderMode.prayer,
          enabled: ReminderSlotId.values.toSet(),
        ),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: constantTimes(),
      );
      // The design's figure: 56 of 64.
      expect(schedule.pendingCount, 43);
      expect(schedule.pendingCount, lessThan(kIosPendingCap));
    });
  });

  group('graceful degradation', () {
    test('prayer mode without prayer times falls back to fixed times', () {
      final schedule = buildSchedule(
        settings: settingsWith(mode: ReminderMode.prayer),
        now: DateTime(2026, 9, 7, 3, 0),
        prayerTimes: constantTimes(available: false),
      );

      expect(schedule.usedFixedFallback, isTrue);
      expect(schedule.entries, hasLength(3));
      expect(schedule.entries.every((e) => e.repeatsDaily), isTrue);
      // Falls back to the slots' own clock times.
      expect(
        schedule.entries.firstWhere((e) => e.slot == ReminderSlotId.morning).at,
        DateTime(2026, 9, 7, 6, 30),
      );
    });

    test('no prayer resolver at all behaves the same way', () {
      final schedule = buildSchedule(
        settings: settingsWith(mode: ReminderMode.prayer),
        now: DateTime(2026, 9, 7, 3, 0),
      );
      expect(schedule.usedFixedFallback, isTrue);
      expect(schedule.entries.every((e) => e.repeatsDaily), isTrue);
    });

    test('fixed mode never reports a fallback', () {
      final schedule = buildSchedule(
        settings: settingsWith(),
        now: DateTime(2026, 9, 7, 3, 0),
      );
      expect(schedule.usedFixedFallback, isFalse);
    });
  });
}
