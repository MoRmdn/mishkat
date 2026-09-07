import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/reminder_settings.dart';

/// Crash and usage reporting.
///
/// The point of analytics in this app is narrow and specific: reminders fail
/// silently on real devices — Doze, OEM battery killers, a revoked permission —
/// and the only way to learn that from the field is to compare how many
/// reminders were *scheduled* against how many were *opened*. These events
/// exist to answer that question, not to build a profile of anyone.
///
/// Nothing here records what a user read, when they pray, or where they are.
abstract class Diagnostics {
  /// The schedule was pushed to the OS.
  void reminderScheduled({
    required ReminderMode mode,
    required int pendingCount,
    required bool exactAlarmsAllowed,
  });

  /// A reminder was tapped. The gap between this and [reminderScheduled] is
  /// the signal that matters.
  void reminderOpened(ReminderSlotId slot);

  /// A reading session was finished.
  void sessionCompleted(String categoryKey);

  /// A permission was granted or refused during onboarding or later.
  void permissionResolved({required String permission, required bool granted});

  void recordError(Object error, StackTrace? stack, {bool fatal = false});
}

/// The default. Does nothing, so the app is fully functional — and completely
/// silent — with no analytics backend configured.
class NoopDiagnostics implements Diagnostics {
  const NoopDiagnostics();

  @override
  void reminderScheduled({
    required ReminderMode mode,
    required int pendingCount,
    required bool exactAlarmsAllowed,
  }) {}

  @override
  void reminderOpened(ReminderSlotId slot) {}

  @override
  void sessionCompleted(String categoryKey) {}

  @override
  void permissionResolved({
    required String permission,
    required bool granted,
  }) {}

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    // Still surface errors in debug, so a swallowed exception is not invisible
    // just because no backend is wired up.
    if (kDebugMode) {
      debugPrint('Diagnostics.recordError: $error\n$stack');
    }
  }
}

/// Override this to install a real implementation.
///
/// See `docs/firebase.md` for the Crashlytics and Analytics adapter — it is not
/// wired by default because it needs a Firebase project that only the app's
/// owner can create.
final diagnosticsProvider = Provider<Diagnostics>(
  (ref) => const NoopDiagnostics(),
);
