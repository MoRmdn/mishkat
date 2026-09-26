import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/features/home/home_now.dart';
import 'package:mishkat/services/reminder_scheduler.dart';

void main() {
  // Default slots: wake 5:00, morning 6:30, evening 17:30, sleep 22:30.
  const fixed = ReminderSettings();
  const wake = ThikrCategory.wake,
      morning = ThikrCategory.morning,
      evening = ThikrCategory.evening,
      sleep = ThikrCategory.sleep;

  HomeNow at(
    DateTime now, {
    Set<ThikrCategory> today = const {},
    Set<ThikrCategory> yesterday = const {},
    ReminderSettings settings = fixed,
    PrayerTimesForDay? prayer,
  }) => resolveHomeNow(
    settings: settings,
    prayerTimes: prayer,
    completedToday: today,
    completedYesterday: yesterday,
    now: now,
  );

  List<BandState> states(HomeNow h) => [for (final s in h.band) s.state];

  group('the board\'s cases', () {
    test('2.1 · 9:41 with waking done → morning is now', () {
      final h = at(DateTime(2026, 9, 7, 9, 41), today: {wake});
      expect(h.current, ReminderSlotId.morning);
      expect(h.currentIsUpcoming, isFalse);
      expect(states(h), [
        BandState.done,
        BandState.now,
        BandState.later,
        BandState.later,
      ]);
    });

    test('2.2 · 17:22 with waking and morning done → evening, upcoming', () {
      final h = at(DateTime(2026, 9, 7, 17, 22), today: {wake, morning});
      expect(h.current, ReminderSlotId.evening);
      expect(h.currentIsUpcoming, isTrue);
      expect(states(h), [
        BandState.done,
        BandState.done,
        BandState.now,
        BandState.later,
      ]);
    });

    test('2.3 · 22:50 with everything done → all done, waking tomorrow', () {
      final h = at(
        DateTime(2026, 9, 7, 22, 50),
        today: {wake, morning, evening, sleep},
      );
      expect(h.allDone, isTrue);
      expect(h.current, isNull);
      expect(h.next!.id, ReminderSlotId.wake);
      expect(h.next!.at, DateTime(2026, 9, 8, 5, 0));
    });
  });

  group('edges', () {
    test('a missed routine stays current until the next window opens', () {
      final h = at(DateTime(2026, 9, 7, 12, 0), today: {wake});
      expect(h.current, ReminderSlotId.morning);
      expect(h.currentIsUpcoming, isFalse);
    });

    test('a missed routine yields once its window has passed', () {
      final h = at(DateTime(2026, 9, 7, 18, 0), today: {wake});
      expect(h.current, ReminderSlotId.evening);
      expect(h.band[1].state, BandState.later, reason: 'missed, not done');
      expect(h.allDone, isFalse);
    });

    test('before the first routine, last night\'s sleep is still open', () {
      final h = at(DateTime(2026, 9, 7, 3, 18));
      expect(h.current, ReminderSlotId.sleep);
    });

    test('before the first routine, a finished night moves on to waking', () {
      final h = at(DateTime(2026, 9, 7, 3, 18), yesterday: {sleep});
      expect(h.current, ReminderSlotId.wake);
      expect(h.currentIsUpcoming, isTrue);
    });

    test(
      'nothing left today but a routine was missed → next, not all done',
      () {
        final h = at(
          DateTime(2026, 9, 7, 23, 30),
          today: {wake, evening, sleep},
        );
        expect(h.current, isNull);
        expect(h.allDone, isFalse);
        expect(h.next!.id, ReminderSlotId.wake);
      },
    );

    test('the window starts exactly on the routine\'s time', () {
      final h = at(DateTime(2026, 9, 7, 17, 30), today: {wake, morning});
      expect(h.current, ReminderSlotId.evening);
      expect(h.currentIsUpcoming, isFalse);
    });

    test('switched-off reminders still have a routine and a time', () {
      final off = ReminderSettings(
        slots: [
          for (final s in ReminderSettings.defaultSlots)
            s.copyWith(enabled: false),
        ],
      );
      final h = at(DateTime(2026, 9, 7, 9, 41), settings: off);
      expect(h.current, ReminderSlotId.morning);
      expect(h.band[1].at, DateTime(2026, 9, 7, 6, 30));
    });
  });

  group('prayer mode', () {
    DailyPrayerTimes times(DateTime d) => (
      fajr: DateTime(d.year, d.month, d.day, 4, 56),
      asr: DateTime(d.year, d.month, d.day, 15, 38),
      maghrib: DateTime(d.year, d.month, d.day, 18, 32),
    );
    const prayerSettings = ReminderSettings(mode: ReminderMode.prayer);

    test('anchored routines follow the prayer, sleep keeps its clock', () {
      final h = at(
        DateTime(2026, 9, 7, 9, 0),
        settings: prayerSettings,
        prayer: times,
      );
      expect(h.band.map((s) => s.at), [
        DateTime(2026, 9, 7, 4, 41), // Fajr −15
        DateTime(2026, 9, 7, 5, 26), // Fajr +30
        DateTime(2026, 9, 7, 16, 23), // Asr +45
        DateTime(2026, 9, 7, 22, 30),
      ]);
    });

    test('the band agrees with the schedule the OS is given', () {
      final now = DateTime(2026, 9, 7, 3, 0);
      final schedule = buildSchedule(
        settings: prayerSettings,
        now: now,
        prayerTimes: times,
      );
      final band = at(now, settings: prayerSettings, prayer: times).band;
      // Sleep is off by default, so only the slots the OS holds compare.
      final held = {for (final e in schedule.entries) e.slot};
      expect(held, isNotEmpty);
      for (final slot in band.where((s) => held.contains(s.id))) {
        final firstEntry = schedule.entries.firstWhere(
          (e) => e.slot == slot.id,
        );
        expect(firstEntry.at, slot.at, reason: slot.id.key);
      }
    });

    test('without prayer times the clock times stand in', () {
      final h = at(
        DateTime(2026, 9, 7, 9, 0),
        settings: prayerSettings,
        prayer: (_) => null,
      );
      expect(h.band[1].at, DateTime(2026, 9, 7, 6, 30));
    });
  });

  test('reading time is at least a minute and grows with repetitions', () {
    Thikr t(String text, int count) => Thikr(
      id: 'x',
      category: ThikrCategory.morning,
      text: text,
      count: count,
      sourceId: 's',
      reference: 1,
      meaningEn: '',
    );
    expect(estimatedMinutes([t('سبحان الله', 1)]), 1);
    expect(
      estimatedMinutes([t('سبحان الله وبحمده', 100)]),
      greaterThan(estimatedMinutes([t('سبحان الله وبحمده', 3)])),
    );
  });
}
