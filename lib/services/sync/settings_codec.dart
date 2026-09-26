import '../../data/models/app_settings.dart';
import '../../data/models/prayer_settings.dart';
import '../../data/models/reminder_settings.dart';

/// What of each settings group leaves the device, and how it comes back.
///
/// Decoding is defensive: a value this version does not recognise keeps the
/// local one, so an account written by a newer app never breaks an older one.
abstract final class SettingsCodec {
  /// Appearance, language, text size and the Quranic-script choice.
  /// `onboardingComplete` is per device and never syncs.
  static Map<String, Object?> encodeApp(AppSettings s) => {
    'appearance': s.appearance.name,
    'language': s.language.name,
    'textSize': s.textSize.index,
    'useQuranFont': s.useQuranFont,
  };

  static AppSettings decodeApp(Map<String, Object?> v, AppSettings local) {
    final size = v['textSize'];
    return local.copyWith(
      appearance: _enum(AppearanceMode.values, v['appearance']),
      language: _enum(AppLanguage.values, v['language']),
      textSize: size is int && size >= 0 && size < ThikrSize.values.length
          ? ThikrSize.values[size]
          : null,
      useQuranFont: v['useQuranFont'] is bool
          ? v['useQuranFont'] as bool
          : null,
    );
  }

  static Map<String, Object?> encodeReminders(ReminderSettings r) => {
    'mode': r.mode.name,
    'slots': [
      for (final s in r.slots)
        {
          'id': s.id.key,
          'hour': s.hour,
          'minute': s.minute,
          'enabled': s.enabled,
        },
    ],
  };

  static ReminderSettings decodeReminders(
    Map<String, Object?> v,
    ReminderSettings local,
  ) {
    var next = local.copyWith(mode: _enum(ReminderMode.values, v['mode']));
    final slots = v['slots'];
    if (slots is List) {
      for (final raw in slots.whereType<Map>()) {
        final id = ReminderSlotId.values
            .where((s) => s.key == raw['id'])
            .firstOrNull;
        final hour = raw['hour'], minute = raw['minute'];
        if (id == null || hour is! int || minute is! int) continue;
        if (hour < 0 || hour > 23 || minute < 0 || minute > 59) continue;
        next = next.withSlot(
          next
              .slot(id)
              .copyWith(
                hour: hour,
                minute: minute,
                enabled: raw['enabled'] is bool ? raw['enabled'] as bool : null,
              ),
        );
      }
    }
    return next;
  }

  /// Method, madhab and where times come from. Coordinates stay on the
  /// device: a position fixed on one phone is wrong for another, and keeping
  /// it local keeps location out of the account entirely.
  static Map<String, Object?> encodePrayer(PrayerSettings p) => {
    'method': p.method.name,
    'madhab': p.madhab.name,
    'useDeviceLocation': p.useDeviceLocation,
    'manualCityId': p.manualCityId,
  };

  static PrayerSettings decodePrayer(
    Map<String, Object?> v,
    PrayerSettings local,
  ) {
    final city = v['manualCityId'];
    return local.copyWith(
      method: _enum(PrayerCalculationMethod.values, v['method']),
      madhab: _enum(AsrMadhab.values, v['madhab']),
      useDeviceLocation: v['useDeviceLocation'] is bool
          ? v['useDeviceLocation'] as bool
          : null,
      manualCityId: kPrayerCities.any((c) => c.id == city)
          ? city as String
          : null,
    );
  }

  static T? _enum<T extends Enum>(List<T> values, Object? name) =>
      values.where((e) => e.name == name).firstOrNull;
}
