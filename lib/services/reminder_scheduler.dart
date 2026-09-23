import 'package:flutter/foundation.dart';

import '../data/models/reminder_settings.dart';

/// iOS silently drops pending local notifications past this many.
const int kIosPendingCap = 64;

/// How far ahead prayer-mode reminders are scheduled. Two weeks means a user
/// who opens the app once a fortnight never has reminders lapse.
const int kScheduleWindowDays = 14;

/// Deliberately below [kIosPendingCap], leaving room for anything scheduled
/// outside this planner (a snooze, say).
const int kMaxPendingReminders = 60;

typedef DailyPrayerTimes = ({DateTime fajr, DateTime asr, DateTime maghrib});

/// Resolves prayer times for a given calendar day, or null when they cannot be
/// computed (no location yet, for instance).
typedef PrayerTimesForDay = DailyPrayerTimes? Function(DateTime day);

@immutable
class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.slot,
    required this.at,
    required this.repeatsDaily,
  });

  /// Stable OS notification id. Repeating slots own a small fixed id; windowed
  /// instances are keyed by slot and day so a reschedule replaces rather than
  /// duplicates.
  final int id;
  final ReminderSlotId slot;
  final DateTime at;

  /// True when this is a single self-repeating daily notification rather than
  /// one instance in a rolling window.
  final bool repeatsDaily;

  @override
  String toString() =>
      'ScheduledReminder(${slot.key}, $at, repeat=$repeatsDaily, id=$id)';
}

@immutable
class ReminderSchedule {
  const ReminderSchedule({
    required this.entries,
    required this.scheduledThrough,
    required this.usedFixedFallback,
  });

  final List<ScheduledReminder> entries;

  /// The last day the window covers, or null when every entry repeats daily
  /// and so nothing can expire.
  final DateTime? scheduledThrough;

  /// True when prayer mode was requested but prayer times were unavailable, so
  /// the fixed clock times were used instead.
  final bool usedFixedFallback;

  int get pendingCount => entries.length;

  bool get repeatsForever => scheduledThrough == null;
}

DateTime _atTime(DateTime day, int hour, int minute) =>
    DateTime(day.year, day.month, day.day, hour, minute);

/// The next time [hour]:[minute] occurs at or after [now].
///
/// Steps the calendar day rather than adding 24 hours: across a DST boundary
/// those differ, and the reminder must keep its wall-clock time.
@visibleForTesting
DateTime nextOccurrence(DateTime now, int hour, int minute) {
  final today = _atTime(now, hour, minute);
  if (today.isAfter(now)) return today;
  return DateTime(now.year, now.month, now.day + 1, hour, minute);
}

/// Computes what the notification schedule *should* be.
///
/// Pure by design: no plugin, no clock, no I/O. `NotificationService` is what
/// applies the result to the OS. Scheduling bugs do not surface until someone
/// misses a reminder, so this half has to be testable without a device.
ReminderSchedule buildSchedule({
  required ReminderSettings settings,
  required DateTime now,
  PrayerTimesForDay? prayerTimes,
  int windowDays = kScheduleWindowDays,
  int maxPending = kMaxPendingReminders,
}) {
  final entries = <ScheduledReminder>[];

  // Does prayer mode actually have data to work with?
  final wantsPrayer = settings.mode == ReminderMode.prayer;
  final anchoredSlots = settings.enabledSlots
      .where((s) => s.anchor != null)
      .toList();
  final haveTimes = prayerTimes != null && prayerTimes(now) != null;
  final usePrayer = wantsPrayer && haveTimes;
  final fellBack = wantsPrayer && !haveTimes && anchoredSlots.isNotEmpty;

  for (final slot in settings.enabledSlots) {
    final followsPrayer = usePrayer && slot.anchor != null;
    if (!followsPrayer) {
      // A constant wall-clock time can be one repeating notification, which
      // never needs topping up. This is why fixed mode is the default.
      entries.add(
        ScheduledReminder(
          id: slot.id.index,
          slot: slot.id,
          at: nextOccurrence(now, slot.hour, slot.minute),
          repeatsDaily: true,
        ),
      );
    }
  }

  DateTime? through;

  if (usePrayer) {
    for (var day = 0; day < windowDays; day++) {
      // Calendar-day stepping, not Duration(days:), so a DST change does not
      // shift the whole window by an hour.
      final date = DateTime(now.year, now.month, now.day + day);
      final times = prayerTimes(date);
      if (times == null) continue;

      for (final slot in anchoredSlots) {
        final anchorTime = slot.anchor == PrayerAnchor.fajr
            ? times.fajr
            : times.asr;
        final at = anchorTime.add(Duration(minutes: slot.anchorOffsetMinutes));
        if (!at.isAfter(now)) continue;

        entries.add(
          ScheduledReminder(
            // Keyed by slot and day so a reschedule overwrites the same ids.
            id: 1000 + slot.id.index * 100 + day,
            slot: slot.id,
            at: at,
            repeatsDaily: false,
          ),
        );
        through = through == null || at.isAfter(through) ? at : through;
      }
    }
  }

  entries.sort((a, b) => a.at.compareTo(b.at));

  // Never let the iOS cap bite silently: drop the furthest-out entries and
  // shorten the reported window to match what is actually scheduled.
  if (entries.length > maxPending) {
    entries.removeRange(maxPending, entries.length);
    final windowed = entries.where((e) => !e.repeatsDaily);
    through = windowed.isEmpty
        ? null
        : windowed.map((e) => e.at).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  return ReminderSchedule(
    entries: entries,
    scheduledThrough: through,
    usedFixedFallback: fellBack,
  );
}
