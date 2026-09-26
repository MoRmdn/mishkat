import '../../core/l10n/app_localizations.dart';
import '../../data/models/thikr.dart';
import '../../services/notification_service.dart';
import '../../services/permission_service.dart';
import '../../services/reminder_content.dart';
import '../../services/reminder_scheduler.dart';

export '../../services/reminder_content.dart';

/// Pushes [schedule] to the OS, or clears everything when notifications are
/// not permitted — leaving stale reminders scheduled after a revoked
/// permission would be worse than none.
Future<void> syncReminders({
  required NotificationService service,
  required ReminderSchedule schedule,
  required PermissionState permissions,
  required L l,
  required AthkarLibrary library,
  required String languageCode,
}) async {
  await service.init();

  if (!permissions.notifications) {
    await service.cancelAll();
    return;
  }

  await service.apply(
    schedule,
    (slot) => buildReminderContent(
      l: l,
      library: library,
      slot: slot,
      languageCode: languageCode,
    ),
    exactAllowed: permissions.exactAlarms,
  );
}
