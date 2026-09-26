import 'package:flutter/foundation.dart';

import '../../data/models/reminder_settings.dart';
import '../../data/models/thikr.dart';
import '../../services/reminder_scheduler.dart';

/// How a day-band column is drawn.
enum BandState { done, now, later }

@immutable
class BandSlot {
  const BandSlot({
    required this.id,
    required this.at,
    required this.done,
    required this.state,
  });

  final ReminderSlotId id;

  /// Today's time for this routine: the slot's clock time, or its prayer-
  /// derived time in prayer mode.
  final DateTime at;
  final bool done;
  final BandState state;
}

/// What Home's "now" module shows, derived from real data only.
@immutable
class HomeNow {
  const HomeNow({
    required this.band,
    required this.current,
    required this.currentIsUpcoming,
    required this.next,
  });

  /// The four daily routines in their fixed order: wake, morning, evening,
  /// sleep.
  final List<BandSlot> band;

  /// The routine the module offers, or null when there is nothing left today.
  final ReminderSlotId? current;

  /// True when [current]'s time has not come yet — it is simply the next one.
  final bool currentIsUpcoming;

  /// When nothing is due today: the first routine tomorrow and its time.
  final ({ReminderSlotId id, DateTime at})? next;

  bool get allDone => band.every((s) => s.done);
}

/// The time [slot] falls on [day].
///
/// Mirrors [buildSchedule]'s rule: in prayer mode an anchored slot follows
/// its prayer plus offset when that day's times are known, and otherwise
/// keeps its clock time.
DateTime slotTimeOn(
  ReminderSlot slot,
  ReminderMode mode,
  PrayerTimesForDay? prayerTimes,
  DateTime day,
) {
  final times = mode == ReminderMode.prayer ? prayerTimes?.call(day) : null;
  final anchor = slot.anchor;
  if (times != null && anchor != null) {
    final base = anchor == PrayerAnchor.fajr ? times.fajr : times.asr;
    return base.add(Duration(minutes: slot.anchorOffsetMinutes));
  }
  return DateTime(day.year, day.month, day.day, slot.hour, slot.minute);
}

/// Works out Home's "now" state.
///
/// Each routine owns the window from its time until the next routine's. The
/// routine whose window contains [now] is current unless it is already done;
/// then the next routine not yet done today is offered instead. Before the
/// day's first routine, the open window is last night's — sleep, normally —
/// which counts as done if it was completed yesterday or since midnight.
///
/// Reminders being switched off does not change any of this: the routines
/// exist whether or not a notification announces them.
HomeNow resolveHomeNow({
  required ReminderSettings settings,
  required PrayerTimesForDay? prayerTimes,
  required Set<ThikrCategory> completedToday,
  required Set<ThikrCategory> completedYesterday,
  required DateTime now,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final times = {
    for (final s in settings.slots)
      s.id: slotTimeOn(s, settings.mode, prayerTimes, today),
  };
  bool doneToday(ReminderSlotId id) => completedToday.contains(id.category);

  final byTime = [...ReminderSlotId.values]
    ..sort((a, b) => times[a]!.compareTo(times[b]!));

  // The window [now] sits in.
  final started = byTime.where((id) => !times[id]!.isAfter(now)).toList();
  ReminderSlotId? current;
  var upcoming = false;

  if (started.isNotEmpty) {
    final open = started.last;
    if (!doneToday(open)) current = open;
  } else {
    // Still inside last night's window.
    final last = byTime.last;
    final done = completedYesterday.contains(last.category) || doneToday(last);
    if (!done) current = last;
  }

  if (current == null) {
    for (final id in byTime) {
      if (times[id]!.isAfter(now) && !doneToday(id)) {
        current = id;
        upcoming = true;
        break;
      }
    }
  }

  ({ReminderSlotId id, DateTime at})? next;
  if (current == null) {
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final first = byTime.first;
    final slot = settings.slots.firstWhere((s) => s.id == first);
    next = (
      id: first,
      at: slotTimeOn(slot, settings.mode, prayerTimes, tomorrow),
    );
  }

  return HomeNow(
    band: [
      for (final id in ReminderSlotId.values)
        BandSlot(
          id: id,
          at: times[id]!,
          done: doneToday(id),
          state: id == current
              ? BandState.now
              : doneToday(id)
              ? BandState.done
              : BandState.later,
        ),
    ],
    current: current,
    currentIsUpcoming: upcoming,
    next: next,
  );
}

/// A rough reading time for a routine, for the "about N minutes" line.
///
/// A quarter-second a word plus a short beat per repetition — calibrated so
/// the placeholder corpus gives the design's own figures (morning ≈ 4
/// minutes, evening ≈ 3). Short phrases repeated a hundred times are said
/// quickly, which is why the per-word pace is brisk. It only needs to be the
/// right order of magnitude.
int estimatedMinutes(List<Thikr> items) {
  var seconds = 0.0;
  for (final t in items) {
    final words = t.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    seconds += t.count * (words.length * 0.25 + 0.8);
  }
  final minutes = (seconds / 60).ceil();
  return minutes < 1 ? 1 : minutes;
}
