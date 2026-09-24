import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/format/numerals.dart';
import '../core/l10n/app_localizations.dart';
import '../data/models/reminder_settings.dart';
import '../data/models/thikr.dart';

/// Localized content shared by routine scheduling and background snoozes.
@immutable
class ReminderContent {
  const ReminderContent({
    required this.title,
    required this.body,
    required this.channelName,
    required this.startLabel,
    required this.snoozeLabel,
    this.languageCode = 'ar',
  });

  final String title, body, channelName, startLabel, snoozeLabel;
  final String languageCode;
}

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
    languageCode: languageCode,
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
