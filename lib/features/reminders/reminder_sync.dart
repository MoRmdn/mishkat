import 'dart:math' as math;

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/reminder_settings.dart';
import '../../data/models/thikr.dart';
import '../../services/notification_service.dart';
import '../../services/permission_service.dart';
import '../../services/reminder_scheduler.dart';

/// Rough seconds per repetition, used only to tell the user how long a session
/// takes before they open it.
const double _secondsPerRepetition = 2.5;

int estimatedMinutes(List<Thikr> items) {
  final repetitions = items.fold<int>(0, (sum, t) => sum + t.count);
  return math.max(1, (repetitions * _secondsPerRepetition / 60).round());
}

String reminderTitle(L l, ReminderSlotId slot) => switch (slot) {
  ReminderSlotId.wake => l.notifTitleWake,
  ReminderSlotId.morning => l.notifTitleMorning,
  ReminderSlotId.evening => l.notifTitleEvening,
  ReminderSlotId.sleep => l.notifTitleSleep,
};

/// Builds the text for one reminder.
///
/// The body carries the first thikr, how many there are, and how long it takes,
/// so the notification is worth something even if it is never opened.
ReminderContent buildReminderContent({
  required L l,
  required AthkarLibrary library,
  required ReminderSlotId slot,
  required String languageCode,
}) {
  final items = library[slot.category];
  final first = items.isEmpty ? '' : items.first.text;

  return ReminderContent(
    title: reminderTitle(l, slot),
    body: l.notifBody(
      first,
      localizeDigits(items.length, languageCode),
      localizeDigits(estimatedMinutes(items), languageCode),
    ),
    channelName: l.notifChannelName,
    startLabel: l.notifActionStart,
    snoozeLabel: l.notifActionSnooze,
  );
}

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
