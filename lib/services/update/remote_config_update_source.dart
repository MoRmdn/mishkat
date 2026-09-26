import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'update_config.dart';

/// [UpdateConfigSource] over Firebase Remote Config.
///
/// Remote Config persists what it last activated, so [cached] is readable on
/// a launch with no network; [refresh] fetches with a short timeout and never
/// throws. Per-platform values (an iOS release lagging Android review) are
/// Remote Config conditions, not separate keys.
class RemoteConfigUpdateSource implements UpdateConfigSource {
  RemoteConfigUpdateSource._(this._config);

  final FirebaseRemoteConfig _config;

  /// Called from `startCloud()` once Firebase is up.
  static Future<RemoteConfigUpdateSource> start() async {
    final config = FirebaseRemoteConfig.instance;
    await config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // Debug builds see a console change immediately.
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );
    await config.setDefaults(UpdateKeys.defaults);
    return RemoteConfigUpdateSource._(config);
  }

  @override
  UpdateConfig cached() => UpdateConfig.fromValues(
    recommended: _config.getString(UpdateKeys.recommended),
    minSupported: _config.getString(UpdateKeys.minSupported),
    releaseNotes: _config.getString(UpdateKeys.releaseNotes),
    allowReading: _config.getBool(UpdateKeys.allowReading),
  );

  @override
  Future<UpdateConfig> refresh() async {
    try {
      await _config.fetchAndActivate();
    } catch (e) {
      // Offline, throttled, or the project has no template yet: keep what
      // was last activated.
      debugPrint('Remote Config fetch failed, using cached values: $e');
    }
    return cached();
  }
}
