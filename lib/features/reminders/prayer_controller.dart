import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/prayer_settings.dart';
import '../../services/prayer_time_service.dart';
import '../../services/sync/settings_codec.dart';
import '../../services/sync/sync_models.dart';
import '../../services/sync/sync_service.dart';
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
    // A new GPS fix changes only the coordinates, which never sync.
    final synced = syncedValuesDiffer(
      SettingsCodec.encodePrayer(state),
      SettingsCodec.encodePrayer(next),
    );
    state = next;
    ref.read(settingsStoreProvider).writePrayer(next);
    if (synced) {
      ref.read(syncProvider.notifier).settingsChanged(SyncGroup.prayer);
    }
  }

  /// Adopts prayer settings pulled from the account. Coordinates stay this
  /// device's own; switching to device location fetches a fresh fix.
  void replaceFromSync(PrayerSettings next) {
    final wantsFix = next.useDeviceLocation && !state.useDeviceLocation;
    state = next;
    ref.read(settingsStoreProvider).writePrayer(next);
    if (wantsFix) Future.microtask(refreshLocation);
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
