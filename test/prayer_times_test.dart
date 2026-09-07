import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/data/models/prayer_settings.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/services/prayer_time_service.dart';
import 'package:mishkat/services/reminder_scheduler.dart';

void main() {
  const service = PrayerTimeService();

  PrayerSettings makkah({
    PrayerCalculationMethod method = PrayerCalculationMethod.ummAlQura,
    AsrMadhab madhab = AsrMadhab.standard,
  }) => PrayerSettings(
    method: method,
    madhab: madhab,
    useDeviceLocation: false,
    manualCityId: 'makkah',
  );

  group('computation', () {
    test('produces times in the right order for a known place and day', () {
      final times = service.timesFor(DateTime(2026, 9, 7), makkah());

      expect(times, isNotNull);
      expect(times!.fajr.isBefore(times.asr), isTrue);
      expect(times.asr.isBefore(times.maghrib), isTrue);
      // Sanity: Fajr before sunrise, Maghrib in the evening.
      expect(times.fajr.hour, inInclusiveRange(3, 6));
      expect(times.maghrib.hour, inInclusiveRange(17, 20));
    });

    test('times land on the requested calendar day', () {
      final day = DateTime(2026, 12, 21);
      final times = service.timesFor(day, makkah())!;
      for (final t in [times.fajr, times.asr, times.maghrib]) {
        expect(t.year, day.year);
        expect(t.month, day.month);
        expect(t.day, day.day);
      }
    });

    test('the Hanafi madhab pushes Asr later', () {
      final day = DateTime(2026, 9, 7);
      final standard = service.timesFor(day, makkah())!;
      final hanafi = service.timesFor(day, makkah(madhab: AsrMadhab.hanafi))!;

      expect(hanafi.asr.isAfter(standard.asr), isTrue);
      // Fajr does not depend on the madhab.
      expect(hanafi.fajr, standard.fajr);
    });

    test('calculation method changes Fajr', () {
      final day = DateTime(2026, 9, 7);
      final umm = service.timesFor(day, makkah())!;
      final mwl = service.timesFor(
        day,
        makkah(method: PrayerCalculationMethod.muslimWorldLeague),
      )!;

      expect(umm.fajr, isNot(mwl.fajr));
      // Both remain plausible dawn times.
      expect(mwl.fajr.hour, inInclusiveRange(3, 6));
    });

    test('a far northern city still resolves', () {
      final times = service.timesFor(
        DateTime(2026, 6, 21),
        const PrayerSettings(useDeviceLocation: false, manualCityId: 'london'),
      );
      expect(times, isNotNull);
    });

    test('times differ between cities', () {
      final day = DateTime(2026, 9, 7);
      final a = service.timesFor(day, makkah())!;
      final b = service.timesFor(
        day,
        const PrayerSettings(useDeviceLocation: false, manualCityId: 'cairo'),
      )!;
      expect(a.fajr, isNot(b.fajr));
    });
  });

  group('coordinates', () {
    test('device location without a fix has nothing to compute from', () {
      const settings = PrayerSettings();
      expect(settings.effectiveCoordinates, isNull);
      expect(service.timesFor(DateTime(2026, 9, 7), settings), isNull);
    });

    test('a cached fix is used', () {
      const settings = PrayerSettings(latitude: 21.42, longitude: 39.83);
      expect(settings.effectiveCoordinates, isNotNull);
      expect(service.timesFor(DateTime(2026, 9, 7), settings), isNotNull);
    });

    test('manual mode ignores any stored device fix', () {
      const settings = PrayerSettings(
        useDeviceLocation: false,
        manualCityId: 'cairo',
        latitude: 21.42,
        longitude: 39.83,
      );
      expect(
        settings.effectiveCoordinates!.latitude,
        cityById('cairo').latitude,
      );
    });

    test('an unknown city id falls back rather than throwing', () {
      expect(cityById('atlantis').id, kPrayerCities.first.id);
    });
  });

  group('driving the scheduler', () {
    test('real prayer times produce a full window', () {
      final settings = makkah();
      final schedule = buildSchedule(
        settings: const ReminderSettings(mode: ReminderMode.prayer),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: service.resolver(settings),
      );

      expect(schedule.usedFixedFallback, isFalse);
      // Three anchored slots enabled by default, across 14 days.
      expect(schedule.entries.where((e) => !e.repeatsDaily), hasLength(42));
      expect(schedule.pendingCount, lessThan(kIosPendingCap));
    });

    test('the offsets land relative to the computed times', () {
      final settings = makkah();
      final day = DateTime(2026, 9, 7, 0, 1);
      final times = service.timesFor(day, settings)!;

      final schedule = buildSchedule(
        settings: const ReminderSettings(mode: ReminderMode.prayer),
        now: day,
        prayerTimes: service.resolver(settings),
        windowDays: 1,
      );

      DateTime timeOf(ReminderSlotId id) =>
          schedule.entries.firstWhere((e) => e.slot == id).at;

      expect(
        timeOf(ReminderSlotId.wake),
        times.fajr.subtract(const Duration(minutes: 15)),
      );
      expect(
        timeOf(ReminderSlotId.morning),
        times.fajr.add(const Duration(minutes: 30)),
      );
      expect(
        timeOf(ReminderSlotId.evening),
        times.asr.add(const Duration(minutes: 45)),
      );
    });

    test('no location falls back to fixed times and reports it', () {
      final schedule = buildSchedule(
        settings: const ReminderSettings(mode: ReminderMode.prayer),
        now: DateTime(2026, 9, 7, 0, 1),
        prayerTimes: service.resolver(const PrayerSettings()),
      );
      expect(schedule.usedFixedFallback, isTrue);
    });
  });
}
