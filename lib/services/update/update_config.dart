import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_version.dart';
import 'release_notes.dart';

/// Remote Config parameter names. `docs/firebase.md` → Remote Config.
abstract final class UpdateKeys {
  /// Gently suggests an update: the sheet, at most every few days.
  static const recommended = 'recommended_version';

  /// Requires one: below it, sync, the account and reminder changes stop.
  static const minSupported = 'min_supported_version';

  /// `{"version": "1.3.0", "notes": [{"icon", "ar", "en"}]}` for the sheet.
  static const releaseNotes = 'release_notes';

  /// Whether «متابعة القراءة فقط» is offered behind the required screen.
  static const allowReading = 'update_allow_reading';

  static const Map<String, Object> defaults = {
    recommended: '0.0.0',
    minSupported: '0.0.0',
    releaseNotes: '',
    allowReading: true,
  };
}

/// What the owner has published about versions. Every field is optional:
/// a value that is unset, `0.0.0` or malformed simply means no gate.
class UpdateConfig {
  const UpdateConfig({
    this.recommended,
    this.minSupported,
    this.notes,
    this.allowReading = true,
  });

  static const none = UpdateConfig();

  final AppVersion? recommended;
  final AppVersion? minSupported;
  final Release? notes;
  final bool allowReading;

  factory UpdateConfig.fromValues({
    required String recommended,
    required String minSupported,
    required String releaseNotes,
    required bool allowReading,
  }) {
    AppVersion? version(String raw) {
      final v = AppVersion.tryParse(raw);
      return v == null || v.isZero ? null : v;
    }

    return UpdateConfig(
      recommended: version(recommended),
      minSupported: version(minSupported),
      notes: Release.tryDecode(releaseNotes),
      allowReading: allowReading,
    );
  }
}

/// Where [UpdateConfig] comes from. Remote Config in a build where Firebase
/// started; otherwise nothing, and no update is ever suggested or required.
abstract class UpdateConfigSource {
  /// The last values this device activated — what a launch with no network
  /// enforces, so a required update cannot be skipped by going offline.
  UpdateConfig cached();

  /// Fetches newer values. Never throws: a failed fetch returns [cached].
  Future<UpdateConfig> refresh();
}

class _NoUpdateConfig implements UpdateConfigSource {
  const _NoUpdateConfig();

  @override
  UpdateConfig cached() => UpdateConfig.none;

  @override
  Future<UpdateConfig> refresh() async => UpdateConfig.none;
}

final updateConfigSourceProvider = Provider<UpdateConfigSource>(
  (ref) => const _NoUpdateConfig(),
);
