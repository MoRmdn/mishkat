import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/data/local/settings_store.dart';
import 'package:mishkat/data/models/app_settings.dart';
import 'package:mishkat/data/models/prayer_settings.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /// Exactly what a pre-2a install leaves in preferences.
  const legacy = <String, Object>{
    'settings.palette': 'indigo',
    'settings.appearance': 'dark',
    'settings.language': 'en',
    'settings.textSize': 2,
    'settings.quranFont': true,
    'settings.onboardingComplete': true,
    'reminders.mode': 'prayer',
    'reminders.slot.morning': '7:15:true',
    'reminders.slot.sleep': '23:0:false',
    'prayer.method': 'egyptian',
    'prayer.manualCity': 'cairo',
    'prayer.useDeviceLocation': false,
  };

  Future<SharedPreferences> seed(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues({
      for (final e in values.entries) 'flutter.${e.key}': e.value,
    });
    return SharedPreferences.getInstance();
  }

  test('migration drops the palette and keeps everything else', () async {
    final prefs = await seed(legacy);
    final store = SettingsStore(prefs);

    await store.migrate();

    expect(prefs.containsKey('settings.palette'), isFalse);
    final s = store.read();
    expect(s.appearance, AppearanceMode.dark);
    expect(s.language, AppLanguage.en);
    expect(s.textSize, ThikrSize.large);
    expect(s.useQuranFont, isTrue);
    expect(s.onboardingComplete, isTrue);

    final r = store.readReminders();
    expect(r.mode, ReminderMode.prayer);
    final morning = r.slots.firstWhere((x) => x.id == ReminderSlotId.morning);
    expect((morning.hour, morning.minute, morning.enabled), (7, 15, true));
    final sleep = r.slots.firstWhere((x) => x.id == ReminderSlotId.sleep);
    expect((sleep.hour, sleep.minute, sleep.enabled), (23, 0, false));

    final p = store.readPrayer();
    expect(p.method, PrayerCalculationMethod.egyptian);
    expect(p.manualCityId, 'cairo');
    expect(p.useDeviceLocation, isFalse);
  });

  test('migration is idempotent', () async {
    final prefs = await seed(legacy);
    final store = SettingsStore(prefs);

    await store.migrate();
    final first = prefs.getKeys().toSet();
    await store.migrate();

    expect(prefs.getKeys(), first);
    expect(store.read().language, AppLanguage.en);
  });

  test('writing settings never brings the palette key back', () async {
    final prefs = await seed(legacy);
    final store = SettingsStore(prefs);
    await store.migrate();

    await store.write(store.read().copyWith(language: AppLanguage.ar));

    expect(prefs.containsKey('settings.palette'), isFalse);
    expect(store.read().appearance, AppearanceMode.dark);
  });

  test('a fresh install defaults to Scheherazade, system appearance', () async {
    final prefs = await seed(const {});
    final s = SettingsStore(prefs).read();

    expect(s.useQuranFont, isFalse);
    expect(s.appearance, AppearanceMode.system);
    expect(s.textSize, ThikrSize.medium);
    expect(s.language, AppLanguage.ar);
  });
}
