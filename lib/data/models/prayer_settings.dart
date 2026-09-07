import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/foundation.dart';

/// The calculation methods the design offers.
///
/// A deliberately short list: these three cover most users, and a longer menu
/// would be a worse decision to hand someone who does not already know which
/// one their mosque follows.
enum PrayerCalculationMethod {
  ummAlQura(adhan.CalculationMethod.umm_al_qura),
  muslimWorldLeague(adhan.CalculationMethod.muslim_world_league),
  egyptian(adhan.CalculationMethod.egyptian);

  const PrayerCalculationMethod(this.method);

  final adhan.CalculationMethod method;

  static PrayerCalculationMethod fromName(String? n) =>
      PrayerCalculationMethod.values.firstWhere(
        (m) => m.name == n,
        orElse: () => PrayerCalculationMethod.ummAlQura,
      );

  PrayerCalculationMethod get next =>
      PrayerCalculationMethod.values[(index + 1) %
          PrayerCalculationMethod.values.length];
}

/// How the Asr shadow length is determined.
enum AsrMadhab {
  standard(adhan.Madhab.shafi),
  hanafi(adhan.Madhab.hanafi);

  const AsrMadhab(this.madhab);

  final adhan.Madhab madhab;

  static AsrMadhab fromName(String? n) => AsrMadhab.values.firstWhere(
    (m) => m.name == n,
    orElse: () => AsrMadhab.standard,
  );

  AsrMadhab get other =>
      this == AsrMadhab.standard ? AsrMadhab.hanafi : AsrMadhab.standard;
}

/// A place prayer times can be computed for.
@immutable
class PrayerCity {
  const PrayerCity({
    required this.id,
    required this.ar,
    required this.en,
    required this.latitude,
    required this.longitude,
  });

  final String id, ar, en;
  final double latitude, longitude;

  String name(String languageCode) => languageCode == 'ar' ? ar : en;
}

/// Offered when the user declines location access, or has no signal.
///
/// Prayer times shift by only a few minutes across a city, so a nearby entry
/// from this list is far better than refusing to compute anything.
const List<PrayerCity> kPrayerCities = [
  PrayerCity(
    id: 'makkah',
    ar: 'مكة المكرمة',
    en: 'Makkah',
    latitude: 21.3891,
    longitude: 39.8579,
  ),
  PrayerCity(
    id: 'madinah',
    ar: 'المدينة المنورة',
    en: 'Madinah',
    latitude: 24.5247,
    longitude: 39.5692,
  ),
  PrayerCity(
    id: 'riyadh',
    ar: 'الرياض',
    en: 'Riyadh',
    latitude: 24.7136,
    longitude: 46.6753,
  ),
  PrayerCity(
    id: 'jeddah',
    ar: 'جدة',
    en: 'Jeddah',
    latitude: 21.4858,
    longitude: 39.1925,
  ),
  PrayerCity(
    id: 'cairo',
    ar: 'القاهرة',
    en: 'Cairo',
    latitude: 30.0444,
    longitude: 31.2357,
  ),
  PrayerCity(
    id: 'amman',
    ar: 'عمّان',
    en: 'Amman',
    latitude: 31.9454,
    longitude: 35.9284,
  ),
  PrayerCity(
    id: 'dubai',
    ar: 'دبي',
    en: 'Dubai',
    latitude: 25.2048,
    longitude: 55.2708,
  ),
  PrayerCity(
    id: 'doha',
    ar: 'الدوحة',
    en: 'Doha',
    latitude: 25.2854,
    longitude: 51.5310,
  ),
  PrayerCity(
    id: 'kuwait',
    ar: 'الكويت',
    en: 'Kuwait City',
    latitude: 29.3759,
    longitude: 47.9774,
  ),
  PrayerCity(
    id: 'istanbul',
    ar: 'إسطنبول',
    en: 'Istanbul',
    latitude: 41.0082,
    longitude: 28.9784,
  ),
  PrayerCity(
    id: 'london',
    ar: 'لندن',
    en: 'London',
    latitude: 51.5072,
    longitude: -0.1276,
  ),
  PrayerCity(
    id: 'newyork',
    ar: 'نيويورك',
    en: 'New York',
    latitude: 40.7128,
    longitude: -74.0060,
  ),
];

PrayerCity cityById(String? id) => kPrayerCities.firstWhere(
  (c) => c.id == id,
  orElse: () => kPrayerCities.first,
);

@immutable
class PrayerSettings {
  const PrayerSettings({
    this.method = PrayerCalculationMethod.ummAlQura,
    this.madhab = AsrMadhab.standard,
    this.useDeviceLocation = true,
    this.manualCityId = 'makkah',
    this.latitude,
    this.longitude,
  });

  final PrayerCalculationMethod method;
  final AsrMadhab madhab;

  /// True to use the device's position; false to use [manualCityId].
  final bool useDeviceLocation;
  final String manualCityId;

  /// The last known device position. Null until location has been resolved,
  /// which is what makes prayer mode fall back to fixed times.
  final double? latitude, longitude;

  PrayerCity get manualCity => cityById(manualCityId);

  bool get hasDevicePosition => latitude != null && longitude != null;

  /// The coordinates prayer times should actually be computed from, or null
  /// when device location was chosen but has not been resolved yet.
  ({double latitude, double longitude})? get effectiveCoordinates {
    if (!useDeviceLocation) {
      return (latitude: manualCity.latitude, longitude: manualCity.longitude);
    }
    if (!hasDevicePosition) return null;
    return (latitude: latitude!, longitude: longitude!);
  }

  PrayerSettings copyWith({
    PrayerCalculationMethod? method,
    AsrMadhab? madhab,
    bool? useDeviceLocation,
    String? manualCityId,
    double? latitude,
    double? longitude,
  }) => PrayerSettings(
    method: method ?? this.method,
    madhab: madhab ?? this.madhab,
    useDeviceLocation: useDeviceLocation ?? this.useDeviceLocation,
    manualCityId: manualCityId ?? this.manualCityId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );
}
