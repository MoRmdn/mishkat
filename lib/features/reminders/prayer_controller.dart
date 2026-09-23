import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/prayer_settings.dart';
import '../../services/prayer_time_service.dart';
import '../settings/settings_controller.dart';

final prayerTimeServiceProvider = Provider<PrayerTimeService>(
  (ref) => const PrayerTimeService(),
);

class PrayerController extends Notifier<PrayerSettings> {
  @override
  PrayerSettings build() {
    final stored = ref.read(settingsStoreProvider).readPrayer();
    // A cached fix is used immediately; a fresh one replaces it when it lands.
    if (stored.useDeviceLocation) Future.microtask(refreshLocation);
    return stored;
  }

  void _update(PrayerSettings next) {
    state = next;
    ref.read(settingsStoreProvider).writePrayer(next);
  }

  void cycleMethod() => _update(state.copyWith(method: state.method.next));

  void toggleMadhab() => _update(state.copyWith(madhab: state.madhab.other));

  void setManualCity(String cityId) =>
      _update(state.copyWith(useDeviceLocation: false, manualCityId: cityId));

  /// Switches to the device's position, asking for permission if needed.
  ///
  /// Falls back to the manual city when the request is refused — declining
  /// location leaves the app working rather than breaking prayer mode.
  Future<void> useDeviceLocation() async {
    _update(state.copyWith(useDeviceLocation: true));
    final ok = await refreshLocation();
    if (!ok) _update(state.copyWith(useDeviceLocation: false));
  }

  Future<bool> refreshLocation() async {
    final fix = await ref
        .read(prayerTimeServiceProvider)
        .resolveDevicePosition();
    if (fix == null) return false;
    _update(state.copyWith(latitude: fix.latitude, longitude: fix.longitude));
    return true;
  }
}

final prayerSettingsProvider =
    NotifierProvider<PrayerController, PrayerSettings>(PrayerController.new);
