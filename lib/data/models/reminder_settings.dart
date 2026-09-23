import 'package:flutter/foundation.dart';

import 'thikr.dart';

/// The four reminder slots, in the order the design lists them.
enum ReminderSlotId {
  wake('wake', ThikrCategory.wake),
  morning('morning', ThikrCategory.morning),
  evening('evening', ThikrCategory.evening),
  sleep('sleep', ThikrCategory.sleep);

  const ReminderSlotId(this.key, this.category);

  final String key;

  /// The category a tap on this reminder opens.
  final ThikrCategory category;

  static ReminderSlotId fromKey(String key) => ReminderSlotId.values.firstWhere(
    (s) => s.key == key,
    orElse: () => ReminderSlotId.morning,
  );
}

enum ReminderMode {
  fixed,
  prayer;

  static ReminderMode fromName(String? n) => ReminderMode.values.firstWhere(
    (m) => m.name == n,
    orElse: () => ReminderMode.fixed,
  );
}

/// Where a slot's time comes from in prayer mode.
///
/// Offsets are the design's: wake 15 minutes before Fajr, morning 30 after
/// Fajr, evening 45 after Asr. Sleep keeps its fixed clock time in both modes —
/// bedtime is not a function of the sun.
enum PrayerAnchor { fajr, asr }

@immutable
class ReminderSlot {
  const ReminderSlot({
    required this.id,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  final ReminderSlotId id;
  final int hour, minute;
  final bool enabled;

  /// Null for [ReminderSlotId.sleep], which never follows prayer times.
  PrayerAnchor? get anchor => switch (id) {
    ReminderSlotId.wake => PrayerAnchor.fajr,
    ReminderSlotId.morning => PrayerAnchor.fajr,
    ReminderSlotId.evening => PrayerAnchor.asr,
    ReminderSlotId.sleep => null,
  };

  /// Minutes to add to the anchor. Negative means before it.
  int get anchorOffsetMinutes => switch (id) {
    ReminderSlotId.wake => -15,
    ReminderSlotId.morning => 30,
    ReminderSlotId.evening => 45,
    ReminderSlotId.sleep => 0,
  };

  /// True when this slot's time is dictated by prayer times and so cannot be
  /// edited by hand.
  bool lockedInPrayerMode(ReminderMode mode) =>
      mode == ReminderMode.prayer && anchor != null;

  ReminderSlot copyWith({int? hour, int? minute, bool? enabled}) =>
      ReminderSlot(
        id: id,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        enabled: enabled ?? this.enabled,
      );
}

@immutable
class ReminderSettings {
  const ReminderSettings({
    this.mode = ReminderMode.fixed,
    this.slots = defaultSlots,
  });

  /// The design's starting configuration: sleep is the only one off by default.
  static const List<ReminderSlot> defaultSlots = [
    ReminderSlot(id: ReminderSlotId.wake, hour: 5, minute: 0, enabled: true),
    ReminderSlot(
      id: ReminderSlotId.morning,
      hour: 6,
      minute: 30,
      enabled: true,
    ),
    ReminderSlot(
      id: ReminderSlotId.evening,
      hour: 17,
      minute: 30,
      enabled: true,
    ),
    ReminderSlot(
      id: ReminderSlotId.sleep,
      hour: 22,
      minute: 30,
      enabled: false,
    ),
  ];

  final ReminderMode mode;
  final List<ReminderSlot> slots;

  ReminderSlot slot(ReminderSlotId id) => slots.firstWhere((s) => s.id == id);

  Iterable<ReminderSlot> get enabledSlots => slots.where((s) => s.enabled);

  ReminderSettings copyWith({ReminderMode? mode, List<ReminderSlot>? slots}) =>
      ReminderSettings(mode: mode ?? this.mode, slots: slots ?? this.slots);

  ReminderSettings withSlot(ReminderSlot updated) => copyWith(
    slots: [for (final s in slots) s.id == updated.id ? updated : s],
  );
}
