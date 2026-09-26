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
  String get brandShort => 'Mishkat';

  @override
  String get brandName => 'Mishkat';

  @override
  String get brandWird => 'Al-Wird';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of use';

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

  @override
  String get readerStartAgain => 'Start again';

  @override
  String get readerRestartQuestion => 'Start this reading session again?';

  @override
  String get readerRestoreError =>
      'Your saved reading could not be restored. You can close this message or start again.';

  @override
  String get readerSaveError =>
      'Progress could not be saved. Keep the app open and try again.';

  @override
  String get back => 'Back';

  @override
  String get settingsReading => 'Reading';

  @override
  String get settingsLanguageAppearance => 'Language and appearance';

  @override
  String get settingsSupport => 'Support';

  @override
  String versionLine(String version) {
    return 'A light for daily remembrance · Version $version';
  }

  @override
  String get account => 'Account';

  @override
  String get accountCardTitle => 'Keep your progress on all your devices';

  @override
  String get accountCardBody => 'Optional · the app works fully without it';

  @override
  String get signInShort => 'Sign in';

  @override
  String get signInToSync => 'Sign in to sync your progress';

  @override
  String syncedAgo(String ago) {
    return 'Synced $ago';
  }

  @override
  String get notSyncedYet => 'Not synced yet';

  @override
  String get feedback => 'Feedback';

  @override
  String get inbox => 'Inbox';

  @override
  String get unreadReply => 'new reply';

  @override
  String withUnread(String label, String state) {
    return '$label, $state';
  }

  @override
  String unreadCount(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits unread',
      one: '1 unread',
    );
    return '$_temp0';
  }

  @override
  String get signInTitle => 'Keep your wird on every device';

  @override
  String get signInSubtitle => 'Optional. The app works fully without it.';

  @override
  String get signInStreak => 'Your streak and sessions';

  @override
  String get signInStreakBody => 'Kept when you change phones';

  @override
  String get signInFavorites => 'Favourites';

  @override
  String get signInFavoritesBody => 'Your saved athkar on every device';

  @override
  String get signInSettingsBody => 'Reminder times and appearance follow you';

  @override
  String get signInApple => 'Sign in with Apple';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get notNow => 'Not now';

  @override
  String get signInPrivacy =>
      'We use your account to sync progress, favourites and settings.';

  @override
  String get signInFailed => 'Couldn’t sign in. Please try again.';

  @override
  String get signedInToast => 'Signed in';

  @override
  String get mergeTitle => 'Your account is linked';

  @override
  String mergeBody(String items) {
    return 'We merged $items from this device into your account.';
  }

  @override
  String mergeAnd(String a, String b) {
    return '$a and $b';
  }

  @override
  String get mergeSettingsOnly =>
      'We merged your settings from this device into your account.';

  @override
  String mergeSessions(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String mergeFavorites(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits saved athkar',
      one: '1 saved thikr',
    );
    return '$_temp0';
  }

  @override
  String sessionsChip(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String favoritesChip(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits saved athkar',
      one: '1 saved thikr',
    );
    return '$_temp0';
  }

  @override
  String currentStreakLine(String days) {
    return 'Current streak: $days';
  }

  @override
  String get continueLabel => 'Continue';

  @override
  String viaProvider(String provider) {
    return 'via $provider';
  }

  @override
  String get syncSynced => 'Synced';

  @override
  String get syncSyncing => 'Syncing…';

  @override
  String get syncSyncingBody => 'You can keep reading';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncOfflineBody => 'Will sync when you’re back online';

  @override
  String get syncError => 'Couldn’t sync';

  @override
  String get syncErrorBody => 'Your data is safe on this device';

  @override
  String get syncNow => 'Sync now';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutBody => 'Your data stays on this device';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteTitle => 'Delete your account?';

  @override
  String get deleteSubtitle => 'This can’t be undone.';

  @override
  String get deleteRemovedHeading => 'Removed from your account';

  @override
  String get deleteItemProgress => 'Synced progress and streak';

  @override
  String get deleteItemMessages => 'Your messages with the Mishkat team';

  @override
  String get deleteKeptHeading => 'Stays on this device';

  @override
  String get deleteKeptBody =>
      'Everything saved here stays, and you keep using the app without an account.';

  @override
  String get deleteConfirm => 'Delete account permanently';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteFailed =>
      'Couldn’t delete the account. Check your connection and try again.';

  @override
  String get deleteFailedTryLater =>
      'Couldn’t delete the account right now. Try again in a little while.';

  @override
  String get appleAccount => 'Apple account';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get thikrSources => 'Athkar sources';

  @override
  String get sourcesIntro =>
      'The athkar are taken from these hadith collections, and each thikr names its source beneath it.';

  @override
  String get sourcesReview =>
      'The references are being reviewed by a qualified scholar before release. If you find a mistake, report it from the thikr’s menu.';

  @override
  String get contentVersionLabel => 'Content version';

  @override
  String get accountDeletedToast => 'Your account was deleted';

  @override
  String get nudgeTitle => 'Save your streak';

  @override
  String get nudgeBody =>
      'Sign in so your streak is kept if you change phones.';

  @override
  String get signIn => 'Sign in';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get more => 'More';

  @override
  String get reportThikr => 'Report a problem with this thikr';

  @override
  String get copyText => 'Copy text';

  @override
  String get copied => 'Text copied';

  @override
  String get feedbackIntro =>
      'We read every message. Replies appear under “Feedback”.';

  @override
  String get typeFeature => 'Suggest a feature';

  @override
  String get typeThikr => 'Thikr error';

  @override
  String get typeBug => 'App problem';

  @override
  String get yourMessage => 'Your message';

  @override
  String get messageHint => 'Write your message…';

  @override
  String charCount(String count, String max) {
    return '$count / $max';
  }

  @override
  String get replyEmail => 'Your email for replies (optional)';

  @override
  String get replyEmailNote => 'We reply in the app; email is only a fallback.';

  @override
  String get invalidEmail => 'That email doesn’t look right';

  @override
  String get attachDevice => 'Attach device information';

  @override
  String get attachDeviceBody => 'App version, system, language';

  @override
  String get send => 'Send';

  @override
  String get reportTitle => 'Report a thikr error';

  @override
  String get whatsWrong => 'What’s wrong?';

  @override
  String get issueText => 'Text';

  @override
  String get issueSource => 'Source';

  @override
  String get issueCount => 'Repetitions';

  @override
  String get issueTranslation => 'Translation';

  @override
  String get details => 'Details';

  @override
  String get sendReport => 'Send report';

  @override
  String get sentTitle => 'We got your message';

  @override
  String get sentBody =>
      'You’ll find the reply under “Feedback”. A dot appears on Settings when it arrives.';

  @override
  String get viewMyMessages => 'View my messages';

  @override
  String get queuedTitle => 'Will send when you’re online';

  @override
  String get queuedBody =>
      'Saved on your device — we’ll send it automatically.';

  @override
  String get sendFailedTitle => 'Couldn’t send';

  @override
  String get sendFailedBody => 'Your message is saved as a draft.';

  @override
  String get statusNew => 'New';

  @override
  String get statusInReview => 'In review';

  @override
  String get statusAnswered => 'Replied';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusQueued => 'Waiting to send';

  @override
  String get repliesInAppOnly =>
      'Replies appear here only, never as notifications.';

  @override
  String get newMessage => 'New message';

  @override
  String get noMessagesTitle => 'No messages yet';

  @override
  String get noMessagesBody =>
      'If you send a suggestion or report a problem, the reply will be here.';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String startedOn(String date) {
    return 'Started $date';
  }

  @override
  String get mishkatTeam => 'Mishkat team';

  @override
  String get writeReply => 'Write a reply…';

  @override
  String get sendReply => 'Send reply';

  @override
  String closedOn(String date) {
    return 'Closed on $date';
  }

  @override
  String get threadClosedTitle => 'This conversation is closed';

  @override
  String get threadClosedBody => 'Need more help? Start a new one.';

  @override
  String get filterAll => 'All';

  @override
  String get filterIdeas => 'Ideas';

  @override
  String get filterAthkar => 'Athkar';

  @override
  String get filterApp => 'App';

  @override
  String get inboxEmptyTitle => 'Nothing new here';

  @override
  String get inboxEmptyBody => 'No messages match these filters.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String messageNumber(String number) {
    return 'Message #$number';
  }

  @override
  String get messageUnnumbered => 'Message';

  @override
  String get metaType => 'Type';

  @override
  String get metaVersion => 'Version';

  @override
  String get metaPlatform => 'Platform';

  @override
  String get metaDate => 'Date';

  @override
  String get metaEmail => 'Email';

  @override
  String get notAttached => 'Not attached';

  @override
  String get openThikr => 'Open thikr';

  @override
  String get statusLabel => 'Status';

  @override
  String get theUser => 'User';

  @override
  String get adminReplyNote =>
      'Your reply appears under “Feedback” for the user, and the status becomes “Replied”.';

  @override
  String get writeReplyToUser => 'Write a reply to the user…';

  @override
  String minutesAgo(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits min ago',
      one: '1 min ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgoShort(String digits) {
    return '${digits}m ago';
  }

  @override
  String hoursAgo(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String get justNow => 'just now';

  @override
  String get updateAvailableTitle => 'A new update is available';

  @override
  String get updateAvailableBody =>
      'Small improvements that make your wird easier.';

  @override
  String updateVersionChip(String version) {
    return 'Version $version';
  }

  @override
  String get updateNow => 'Update now';

  @override
  String get updateLater => 'Later';

  @override
  String get updateFromAppStore => 'Update on the App Store';

  @override
  String get updateFromPlay => 'Update on Google Play';

  @override
  String get updateMetaInApp => 'Downloads in the background';

  @override
  String get updateMetaStore => 'Opens the app\'s store page';

  @override
  String get updateDownloading => 'Downloading the update';

  @override
  String get updateDownloadingHint =>
      'You can keep reading while it downloads.';

  @override
  String get updateReady => 'The update is ready';

  @override
  String get updateReadyHint => 'It takes seconds, and your progress is kept.';

  @override
  String get updateRestart => 'Restart';

  @override
  String get updateApplying => 'Applying the update…';

  @override
  String updatedTo(String version) {
    return 'Updated to $version';
  }

  @override
  String get whatsNew => 'What\'s new';

  @override
  String whatsNewVersion(String version) {
    return 'What\'s new in $version';
  }

  @override
  String get updateRequiredTitle => 'Mishkat needs an update';

  @override
  String get updateRequiredBody =>
      'This version no longer supports sync and the new reminders. Your progress and favourites stay safe on this device.';

  @override
  String updateVersions(String from, String to) {
    return 'From version $from to $to';
  }

  @override
  String get keepReadingOnly => 'Keep reading only';

  @override
  String get updateUpdating => 'Updating…';

  @override
  String get updateAutoRestart =>
      'The app restarts on its own when it\'s done.';

  @override
  String get updateOfflineTitle => 'No connection';

  @override
  String get updateOfflineBody =>
      'Connect to the internet to download the update.';

  @override
  String get updateLockedTitle => 'Mishkat needs an update';

  @override
  String get updateLockedBody =>
      'Update Mishkat to change reminders or sync. Your current reminders still arrive.';

  @override
  String get updateAction => 'Update';
}
