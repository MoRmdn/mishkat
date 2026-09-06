// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Athkar';

  @override
  String get navHome => 'Home';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navFavorites => 'Saved';

  @override
  String get navProgress => 'Progress';

  @override
  String get titleHome => 'Athkar';

  @override
  String get titleReminders => 'Reminders';

  @override
  String get titleFavorites => 'Saved';

  @override
  String get titleProgress => 'Progress';

  @override
  String get catMorning => 'Morning';

  @override
  String get catEvening => 'Evening';

  @override
  String get catSleep => 'Before sleep';

  @override
  String get catWake => 'On waking';

  @override
  String get catAfterPrayer => 'After prayer';

  @override
  String get catMisc => 'Assorted';

  @override
  String get catTasbih => 'Tasbih';

  @override
  String get nextReminder => 'Next reminder';

  @override
  String get edit => 'Edit';

  @override
  String inHours(String hours, String minutes) {
    return 'in $hours hours $minutes minutes';
  }

  @override
  String get prayerBased => 'Computed from today’s prayer times';

  @override
  String get schedFixed => 'Repeats daily — no need to open the app';

  @override
  String schedPrayer(String date, String days) {
    return 'Scheduled through $date ($days days)';
  }

  @override
  String get tasbihTitle => 'Tasbih counter';

  @override
  String get tasbihSub => 'Free counter — tap anywhere to count';

  @override
  String get dayUnit => 'days';

  @override
  String get dayUnitPl => 'days';

  @override
  String get sessions => 'sessions';

  @override
  String get fixedMode => 'Fixed time';

  @override
  String get prayerMode => 'By prayer times';

  @override
  String get exactTitle => 'Exact alarms not allowed';

  @override
  String get exactBody =>
      'Reminders may arrive a few minutes late. You can allow exact alarms in system settings.';

  @override
  String get exactAllow => 'Allow exact alarms';

  @override
  String get daily => 'Daily · repeats automatically';

  @override
  String get off => 'Off';

  @override
  String get slotWake => 'On waking';

  @override
  String get slotMorning => 'Morning athkar';

  @override
  String get slotEvening => 'Evening athkar';

  @override
  String get slotSleep => 'Before sleep';

  @override
  String get slotPrayerWake => '15 min before Fajr';

  @override
  String get slotPrayerMorning => '30 min after Fajr';

  @override
  String get slotPrayerEvening => '45 min after Asr';

  @override
  String get slotPrayerSleep => 'Always a fixed time';

  @override
  String get todayTimes => 'Today’s times';

  @override
  String get fajr => 'Fajr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get windowLabel => 'Scheduled window';

  @override
  String windowText(String days, String pending, String cap) {
    return 'Days scheduled: $days · Pending notifications: $pending of $cap';
  }

  @override
  String get method => 'Calculation method';

  @override
  String get madhab => 'Asr madhab';

  @override
  String get location => 'Location';

  @override
  String get methodUmmAlQura => 'Umm al-Qura';

  @override
  String get methodMwl => 'Muslim World League';

  @override
  String get methodEgypt => 'Egyptian Authority';

  @override
  String get madhabStandard => 'Standard';

  @override
  String get madhabHanafi => 'Hanafi';

  @override
  String get oemTitle => 'Reminders not arriving?';

  @override
  String get oemHintOn => 'Device is exempt from battery saver ✓';

  @override
  String oemHintOff(String vendor) {
    return 'Guide for your device — $vendor';
  }

  @override
  String get oemBody =>
      'Some manufacturers stop apps in the background, which cancels scheduled reminders. These steps fix it once.';

  @override
  String get openBattery => 'Open battery settings';

  @override
  String get batteryOn => 'App is currently exempt ✓';

  @override
  String get batteryOff => 'App is not exempt';

  @override
  String get favEmptyTitle => 'Nothing saved yet';

  @override
  String get favEmptyBody =>
      'Tap the heart while reading to keep a thikr here.';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get longest => 'Longest streak';

  @override
  String get totalSessions => 'Total sessions';

  @override
  String get last14 => 'Last 14 days';

  @override
  String get byCategory => 'By category — this week';

  @override
  String get countOf => 'of';

  @override
  String get once => 'once';

  @override
  String get tapHint => 'Tap anywhere to count · screen stays awake';

  @override
  String get completedToday => 'Completed today';

  @override
  String athkarCount(String count) {
    return '$count athkar';
  }

  @override
  String get prev => 'Previous';

  @override
  String get reset => 'Reset';

  @override
  String get next => 'Next';

  @override
  String get donePrefix => 'Completed';

  @override
  String doneTitle(String category) {
    return 'Completed — $category';
  }

  @override
  String doneStreak(String days, String time) {
    return 'Your streak is now $days days. Next reminder at $time.';
  }

  @override
  String get shareAsImage => 'Share as image';

  @override
  String get backHome => 'Back to home';

  @override
  String get shareTitle => 'Share this thikr';

  @override
  String get saveImage => 'Save image';

  @override
  String get share => 'Share';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get appearance => 'Appearance';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get themeLabel => 'App colour';

  @override
  String get themeTeal => 'Stone teal';

  @override
  String get themeIndigo => 'Indigo';

  @override
  String get themeOlive => 'Olive';

  @override
  String get fontSize => 'Text size';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeMedium => 'Medium';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get quranFont => 'Quranic script';

  @override
  String get done => 'Done';

  @override
  String get saveReschedule => 'Save and reschedule';

  @override
  String timeOf(String slot) {
    return 'Time — $slot';
  }

  @override
  String get repeatsDaily => 'repeats daily';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get onb1Title => 'Remember Allah, on time';

  @override
  String get onb1Body =>
      'Gentle reminders for the morning, evening, sleep and waking athkar — fully offline.';

  @override
  String get onb1NoteLabel => 'NO ACCOUNT';

  @override
  String get onb1Note =>
      'No sign-in and nothing sent anywhere. Everything stays on your device.';

  @override
  String get onb1Primary => 'Get started';

  @override
  String get onb1Secondary => 'Skip setup';

  @override
  String get onb2Title => 'Notifications permission';

  @override
  String get onb2Body =>
      'Reminders are scheduled by your device itself, so notifications must be allowed — without them nothing arrives.';

  @override
  String get onb2NoteLabel => 'WHY NOW';

  @override
  String get onb2Note =>
      'You can allow it later in settings, but reminders stay off until you do.';

  @override
  String get onb2Primary => 'Allow notifications';

  @override
  String get onb2Secondary => 'Not now';

  @override
  String get onb3Title => 'Exact timing';

  @override
  String get onb3Body =>
      'To arrive at the exact minute, the app needs Android’s “exact alarm” permission.';

  @override
  String get onb3NoteLabel => 'IF YOU DECLINE';

  @override
  String get onb3Note =>
      'The app keeps working, but reminders may run a few minutes late — settings will say so.';

  @override
  String get onb3Primary => 'Allow';

  @override
  String get onb3Secondary => 'Continue without it';

  @override
  String get onb4Title => 'Free it from battery saver';

  @override
  String get onb4Body =>
      'Some devices kill background apps, cancelling scheduled reminders. One exemption fixes it for good.';

  @override
  String get onb4NoteLabel => 'ONE STEP';

  @override
  String get onb4Note =>
      'We open the right settings screen for your device, and that’s it.';

  @override
  String get onb4Primary => 'Exempt the app';

  @override
  String get onb4Secondary => 'Later';

  @override
  String get notifTitleMorning => 'Time for the morning athkar';

  @override
  String get notifTitleEvening => 'Time for the evening athkar';

  @override
  String get notifTitleSleep => 'Time for the sleep athkar';

  @override
  String get notifTitleWake => 'Time for the waking athkar';

  @override
  String get notifActionStart => 'Start';

  @override
  String get notifActionSnooze => 'Snooze 15 min';

  @override
  String get notifChannelName => 'Athkar reminders';
}
