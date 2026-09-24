// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Mishkat Al-Wird';

  @override
  String get navHome => 'Home';

  @override
  String get navReminders => 'Reminders';

  @override
  String get navFavorites => 'Saved';

  @override
  String get navProgress => 'Progress';

  @override
  String get titleReminders => 'Reminders';

  @override
  String get titleFavorites => 'Saved';

  @override
  String get titleProgress => 'Progress';

  @override
  String get catMorning => 'Morning athkar';

  @override
  String get catEvening => 'Evening athkar';

  @override
  String get catSleep => 'Sleep athkar';

  @override
  String get catWake => 'Waking athkar';

  @override
  String get catAfterPrayer => 'After prayer';

  @override
  String get catMisc => 'Assorted';

  @override
  String get catTasbih => 'Tasbih';

  @override
  String get schedFixed => 'Repeats daily — no need to open the app';

  @override
  String get fixedMode => 'Fixed time';

  @override
  String get prayerMode => 'By prayer';

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
  String cityAuto(String city) {
    return '$city · automatic';
  }

  @override
  String cityManual(String city) {
    return '$city · manual';
  }

  @override
  String get locationPending => 'Finding your location…';

  @override
  String get chooseCity => 'Choose a city';

  @override
  String get useMyLocation => 'Use my device location';

  @override
  String get todayTimes => 'Today’s prayer times';

  @override
  String get fajr => 'Fajr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

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
  String get oemBody =>
      'Some devices stop apps in the background, which cancels reminders. Follow these steps once.';

  @override
  String oemHeading(String vendor) {
    return '$vendor settings';
  }

  @override
  String get oemStep1 => 'Settings → Apps → Mishkat';

  @override
  String get oemStep2 => 'Turn on “Autostart”';

  @override
  String get oemStep3 => 'Battery saver → “No restrictions”';

  @override
  String get oemGenericHint =>
      'General steps — the exact labels vary a little by device';

  @override
  String get openBattery => 'Open battery settings';

  @override
  String get batteryOn => 'App is currently exempt';

  @override
  String get batteryOff => 'The app is not exempt yet';

  @override
  String get favEmptyTitle => 'Nothing saved yet';

  @override
  String get favEmptyBody =>
      'Tap the heart while reading to keep a thikr here.';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get longest => 'Longest';

  @override
  String get totalSessions => 'Sessions';

  @override
  String get last14 => 'Last 14 days';

  @override
  String get byCategory => 'This week';

  @override
  String get once => 'once';

  @override
  String get prev => 'Previous';

  @override
  String get reset => 'Reset';

  @override
  String get next => 'Next';

  @override
  String get shareAsImage => 'Share as image';

  @override
  String get backHome => 'Back to home';

  @override
  String get shareTitle => 'Share this thikr';

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
  String get fontSize => 'Thikr text size';

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
      'Reminders for the morning, evening, sleep and waking athkar, scheduled on your device and working without internet. No account.';

  @override
  String get onb1Primary => 'Get started';

  @override
  String get onb1Secondary => 'Skip';

  @override
  String get onb2Title => 'Notifications permission';

  @override
  String get onb2Body =>
      'Reminders are scheduled on your device, so notifications have to be allowed — without them no reminder can arrive.';

  @override
  String get onb2Note =>
      'You can allow them later in settings, but reminders stay off until then.';

  @override
  String get onb2Primary => 'Allow notifications';

  @override
  String get onb2Secondary => 'Not now';

  @override
  String get onb3Title => 'Exact timing';

  @override
  String get onb3Body =>
      'To arrive on the minute, reminders need Android’s “exact alarms” permission.';

  @override
  String get onb3Note =>
      'If you decline, the app keeps working but a reminder may arrive a few minutes late — the Reminders tab will say so.';

  @override
  String get onb3Primary => 'Allow';

  @override
  String get onb3Secondary => 'Continue without it';

  @override
  String get onb4Title => 'Exempt from battery saver';

  @override
  String get onb4Body =>
      'Some devices close apps in the background, which cancels reminders. One exemption is enough.';

  @override
  String get onb4Note => 'We’ll open the right screen for your device.';

  @override
  String get onb4Primary => 'Exempt the app';

  @override
  String get onb4Secondary => 'Later';

  @override
  String notifBody(String thikr, String count, String minutes) {
    return '$thikr · $count athkar · $minutes min';
  }

  @override
  String scheduleThroughShort(String date) {
    return 'Scheduled through $date';
  }

  @override
  String get prayerFallbackNotice =>
      'Prayer times unavailable — using fixed times for now';

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

  @override
  String get brandName => 'Mishkat';

  @override
  String get brandWird => 'Al-Wird';

  @override
  String get shareStyleAubergine => 'Aubergine';

  @override
  String get shareStyleStone => 'Stone';

  @override
  String get nowLabel => 'Now';

  @override
  String get nextLabel => 'Next';

  @override
  String get begin => 'Begin';

  @override
  String get editTimes => 'Edit times';

  @override
  String athkarCountLabel(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits athkar',
      one: '1 thikr',
    );
    return '$_temp0';
  }

  @override
  String aboutMinutes(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'about $digits minutes',
      one: 'about 1 minute',
    );
    return '$_temp0';
  }

  @override
  String streakDays(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits-day streak',
      one: '1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get streakStart => 'Start your streak today';

  @override
  String daysCount(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String daysUnit(num count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$_temp0';
  }

  @override
  String get bandWake => 'Waking';

  @override
  String get bandMorning => 'Morning';

  @override
  String get bandEvening => 'Evening';

  @override
  String get bandSleep => 'Sleep';

  @override
  String bandSemantics(String routine, String time, String state) {
    return '$routine, $time, $state';
  }

  @override
  String get stateDone => 'done';

  @override
  String get stateNow => 'now';

  @override
  String get stateLater => 'later';

  @override
  String get allDoneTitle => 'Today’s athkar are done';

  @override
  String tomorrowAt(String routine, String time) {
    return '$routine tomorrow, $time';
  }

  @override
  String get notifOffTitle => 'Notifications are off';

  @override
  String get notifOffBody => 'No reminders will arrive until you allow them.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get remindersAllOff =>
      'All reminders are off — times shown for reference';

  @override
  String get libAfterPrayer => 'After prayer';

  @override
  String get libMisc => 'Assorted';

  @override
  String get close => 'Close';

  @override
  String tasbihRound(String round, String target) {
    return 'Round $round · of $target';
  }

  @override
  String get tasbihFree => 'Free count';

  @override
  String get tasbihNoLimit => 'No limit';

  @override
  String get tasbihHint => 'Tap anywhere to count · a light buzz every 33';

  @override
  String get favoriteAdd => 'Save';

  @override
  String get favoriteRemove => 'Remove from saved';

  @override
  String get scrollToContinue => 'Scroll to continue';

  @override
  String counterOf(String total) {
    return 'of $total';
  }

  @override
  String counterRemaining(String remaining, String total) {
    return '$remaining of $total remaining';
  }

  @override
  String positionOf(String index, String total) {
    return '$index of $total';
  }

  @override
  String doneRoutine(String routine) {
    return '$routine complete';
  }

  @override
  String streakNow(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your streak is now $digits days.',
      one: 'Your streak is now 1 day.',
      zero: 'Start your streak today.',
    );
    return '$_temp0';
  }

  @override
  String nextReminderLine(String routine, String time) {
    return 'Next reminder: $routine at $time.';
  }

  @override
  String get shareChooseTitle => 'Choose a thikr to share';

  @override
  String get exactBanner =>
      'Reminders may arrive a few minutes late — exact alarms are not allowed.';

  @override
  String get allow => 'Allow';

  @override
  String get slotDaily => 'Daily';

  @override
  String pendingShort(String count) {
    return '$count pending';
  }

  @override
  String windowShort(String date, String pending, String cap) {
    return 'Scheduled through $date · $pending of $cap pending';
  }

  @override
  String get timeSheetHint => 'Repeats daily · 5-minute steps';

  @override
  String get favHint => 'Tap a thikr to read it · swipe to remove';

  @override
  String get browseAthkar => 'Browse athkar';

  @override
  String get legendFull => 'Full';

  @override
  String get legendPartial => 'Partial';

  @override
  String get legendNone => 'None';

  @override
  String weekRatio(String done, String target) {
    return '$done / $target';
  }

  @override
  String get errorTitle => 'Couldn’t load the athkar';

  @override
  String get errorBody =>
      'Something unexpected went wrong. Your scheduled reminders are not affected.';

  @override
  String get retry => 'Try again';

  @override
  String onb4NoteVendor(String vendor) {
    return 'Your device: $vendor · we’ll open the right screen';
  }

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String onbStep(String index, String total) {
    return 'Step $index of $total';
  }

  @override
  String get slotWakeShort => 'Waking';

  @override
  String get slotMorningShort => 'Morning';

  @override
  String get slotEveningShort => 'Evening';

  @override
  String get slotSleepShort => 'Sleep';

  @override
  String get hourUp => 'Increase hour';

  @override
  String get hourDown => 'Decrease hour';

  @override
  String get minuteUp => 'Increase minutes';

  @override
  String get minuteDown => 'Decrease minutes';

  @override
  String timesCount(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits times',
      two: 'twice',
      one: 'once',
    );
    return '$_temp0';
  }

  @override
  String get textSmaller => 'Smaller thikr text';

  @override
  String get textLarger => 'Larger thikr text';
}
