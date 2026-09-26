/// What the app should say about updates, decided without a device.
///
/// Pure, like `merge.dart` and `home_now.dart`: the controller supplies the
/// installed version, the published config, what was last shown and the
/// clock, and `test/update_policy_test.dart` pins every rule on the board.
library;

import 'app_version.dart';
import 'release_notes.dart';
import 'update_config.dart';

sealed class UpdateDecision {
  const UpdateDecision();
}

/// Up to date, or nothing published.
class NoUpdate extends UpdateDecision {
  const NoUpdate();
}

/// `recommended_version` is newer: the sheet may be offered.
class OptionalUpdate extends UpdateDecision {
  const OptionalUpdate({required this.target, this.notes});

  final AppVersion target;

  /// Shown on the sheet only when they describe [target].
  final Release? notes;
}

/// Below `min_supported_version`: the blocking screen.
class RequiredUpdate extends UpdateDecision {
  const RequiredUpdate({
    required this.installed,
    required this.target,
    required this.allowReading,
  });

  final AppVersion installed;

  /// The newest published version, which is what the store will install.
  final AppVersion target;
  final bool allowReading;
}

/// The sheet comes back for the same version after this long.
const kUpdatePromptInterval = Duration(days: 3);

UpdateDecision resolveUpdate({
  required AppVersion? installed,
  required UpdateConfig config,
}) {
  if (installed == null) return const NoUpdate();
  final min = config.minSupported;
  final recommended = config.recommended;
  if (min != null && installed < min) {
    final target = recommended != null && recommended > min ? recommended : min;
    return RequiredUpdate(
      installed: installed,
      target: target,
      allowReading: config.allowReading,
    );
  }
  if (recommended != null && installed < recommended) {
    final notes = config.notes;
    return OptionalUpdate(
      target: recommended,
      notes: notes != null && notes.version == recommended ? notes : null,
    );
  }
  return const NoUpdate();
}

/// Whether the optional sheet may be shown now.
///
/// Once per version; after that, no more often than [kUpdatePromptInterval].
/// Never when a reminder opened the app — the user came to read. The
/// controller also keeps it to once per launch, and the scope to when the
/// shell is on top (never over the reader).
bool shouldPromptUpdate({
  required AppVersion target,
  required AppVersion? lastPromptedVersion,
  required DateTime? lastPromptedAt,
  required DateTime now,
  bool launchedFromReminder = false,
}) {
  if (launchedFromReminder) return false;
  if (lastPromptedVersion != target || lastPromptedAt == null) return true;
  return now.difference(lastPromptedAt) >= kUpdatePromptInterval;
}

/// The releases to offer in «ما الجديد» after an update, or null for none.
///
/// A first install has nothing to compare with ([lastSeen] null): the app is
/// new, not updated, so it only records the version.
List<Release>? whatsNewAfterUpdate({
  required AppVersion? lastSeen,
  required AppVersion installed,
  required Changelog changelog,
}) {
  if (lastSeen == null || lastSeen >= installed) return null;
  final releases = changelog.since(lastSeen, installed);
  return releases.isEmpty ? null : releases;
}
