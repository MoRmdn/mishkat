import 'package:adhan/adhan.dart' as adhan;
import 'package:geolocator/geolocator.dart';

import '../data/models/prayer_settings.dart';
import 'reminder_scheduler.dart';

/// Computes prayer times, and resolves the device's position.
///
/// The computation half is pure and offline — `adhan` is a solar calculation,
/// not a network call — so prayer mode keeps working on a plane. Only the
/// position lookup touches the platform.
class PrayerTimeService {
  const PrayerTimeService();

  /// Fajr, Asr and Maghrib for [day] at the settings' effective coordinates,
  /// or null when there is no position to compute from.
  DailyPrayerTimes? timesFor(DateTime day, PrayerSettings settings) {
    final coords = settings.effectiveCoordinates;
    if (coords == null) return null;

    final params = settings.method.method.getParameters()
      ..madhab = settings.madhab.madhab;

    final times = adhan.PrayerTimes(
      adhan.Coordinates(coords.latitude, coords.longitude),
      adhan.DateComponents(day.year, day.month, day.day),
      params,
    );

    return (fajr: times.fajr, asr: times.asr, maghrib: times.maghrib);
  }

  /// Builds the resolver [buildSchedule] takes.
  PrayerTimesForDay resolver(PrayerSettings settings) =>
      (day) => timesFor(day, settings);

  /// Asks the platform for a position.
  ///
  /// Returns null on any refusal or failure rather than throwing: declining
  /// location must leave the app working, on the manual city.
  Future<({double latitude, double longitude})?> resolveDevicePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // Prayer times shift by seconds across a city, so a coarse fix is
          // plenty and costs far less battery than a precise one.
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return (latitude: position.latitude, longitude: position.longitude);
    } catch (_) {
      return null;
    }
  }
}
