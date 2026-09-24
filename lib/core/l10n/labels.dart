import '../../data/models/reminder_settings.dart';
import '../../data/models/thikr.dart';
import '../widgets/mishkat_icon.dart';
import 'app_localizations.dart';

/// A routine's full name — "أذكار الصباح" / "Morning athkar".
String categoryLabel(L l, ThikrCategory c) => switch (c) {
  ThikrCategory.morning => l.catMorning,
  ThikrCategory.evening => l.catEvening,
  ThikrCategory.sleep => l.catSleep,
  ThikrCategory.wake => l.catWake,
  ThikrCategory.afterPrayer => l.catAfterPrayer,
  ThikrCategory.misc => l.catMisc,
  ThikrCategory.tasbih => l.catTasbih,
};

/// The short name used in Home's library list.
String libraryLabel(L l, ThikrCategory c) => switch (c) {
  ThikrCategory.afterPrayer => l.libAfterPrayer,
  ThikrCategory.misc => l.libMisc,
  _ => categoryLabel(l, c),
};

MIcon categoryIcon(ThikrCategory c) => switch (c) {
  ThikrCategory.morning => MIcon.routineMorning,
  ThikrCategory.evening => MIcon.routineEvening,
  ThikrCategory.sleep => MIcon.routineSleep,
  ThikrCategory.wake => MIcon.routineWake,
  ThikrCategory.afterPrayer => MIcon.routineAfterPrayer,
  ThikrCategory.misc => MIcon.routineMisc,
  ThikrCategory.tasbih => MIcon.routineTasbih,
};

/// A reminder slot's name in the Reminders list.
String slotLabel(L l, ReminderSlotId id) => switch (id) {
  ReminderSlotId.wake => l.slotWake,
  ReminderSlotId.morning => l.slotMorning,
  ReminderSlotId.evening => l.slotEvening,
  ReminderSlotId.sleep => l.slotSleep,
};

/// The one-word column label in Home's day band.
String bandLabel(L l, ReminderSlotId id) => switch (id) {
  ReminderSlotId.wake => l.bandWake,
  ReminderSlotId.morning => l.bandMorning,
  ReminderSlotId.evening => l.bandEvening,
  ReminderSlotId.sleep => l.bandSleep,
};

/// How a slot's time is derived in prayer mode.
String slotPrayerRule(L l, ReminderSlotId id) => switch (id) {
  ReminderSlotId.wake => l.slotPrayerWake,
  ReminderSlotId.morning => l.slotPrayerMorning,
  ReminderSlotId.evening => l.slotPrayerEvening,
  ReminderSlotId.sleep => l.slotPrayerSleep,
};
