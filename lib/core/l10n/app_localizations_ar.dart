// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LAr extends L {
  LAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مِشْكَاةُ الوِرْدِ';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navReminders => 'التذكيرات';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navProgress => 'التقدّم';

  @override
  String get titleReminders => 'التذكيرات';

  @override
  String get titleFavorites => 'المفضلة';

  @override
  String get titleProgress => 'التقدّم';

  @override
  String get catMorning => 'أذكار الصباح';

  @override
  String get catEvening => 'أذكار المساء';

  @override
  String get catSleep => 'أذكار النوم';

  @override
  String get catWake => 'أذكار الاستيقاظ';

  @override
  String get catAfterPrayer => 'أذكار بعد الصلاة';

  @override
  String get catMisc => 'أذكار متفرقة';

  @override
  String get catTasbih => 'السبحة';

  @override
  String get schedFixed => 'مجدولة يومياً — لا تحتاج فتح التطبيق';

  @override
  String get fixedMode => 'وقت ثابت';

  @override
  String get prayerMode => 'حسب الصلاة';

  @override
  String get off => 'معطّل';

  @override
  String get slotWake => 'أذكار الاستيقاظ';

  @override
  String get slotMorning => 'أذكار الصباح';

  @override
  String get slotEvening => 'أذكار المساء';

  @override
  String get slotSleep => 'أذكار النوم';

  @override
  String get slotPrayerWake => 'قبل الفجر بـ ١٥ د';

  @override
  String get slotPrayerMorning => 'بعد الفجر بـ ٣٠ د';

  @override
  String get slotPrayerEvening => 'بعد العصر بـ ٤٥ د';

  @override
  String get slotPrayerSleep => 'وقت ثابت دائماً';

  @override
  String cityAuto(String city) {
    return '$city · تلقائي';
  }

  @override
  String cityManual(String city) {
    return '$city · يدوي';
  }

  @override
  String get locationPending => 'جارٍ تحديد الموقع…';

  @override
  String get chooseCity => 'اختر المدينة';

  @override
  String get useMyLocation => 'استخدام موقع الجهاز';

  @override
  String get todayTimes => 'مواقيت اليوم';

  @override
  String get fajr => 'الفجر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get method => 'طريقة الحساب';

  @override
  String get madhab => 'مذهب العصر';

  @override
  String get location => 'الموقع';

  @override
  String get methodUmmAlQura => 'أم القرى';

  @override
  String get methodMwl => 'رابطة العالم الإسلامي';

  @override
  String get methodEgypt => 'الهيئة المصرية';

  @override
  String get madhabStandard => 'الجمهور';

  @override
  String get madhabHanafi => 'الحنفي';

  @override
  String get oemTitle => 'التذكيرات لا تصل؟';

  @override
  String get oemBody =>
      'بعض الأجهزة توقف التطبيقات في الخلفية فتُلغى التذكيرات. اتبع الخطوات مرة واحدة.';

  @override
  String oemHeading(String vendor) {
    return 'إعدادات $vendor';
  }

  @override
  String get oemStep1 => 'الإعدادات ← التطبيقات ← مِشْكَاة';

  @override
  String get oemStep2 => 'فعّل «التشغيل التلقائي»';

  @override
  String get oemStep3 => 'موفّر البطارية ← «لا قيود»';

  @override
  String get oemGenericHint =>
      'خطوات عامة — قد تختلف التسميات قليلاً بين الأجهزة';

  @override
  String get openBattery => 'فتح إعدادات البطارية';

  @override
  String get batteryOn => 'التطبيق مستثنى حالياً';

  @override
  String get batteryOff => 'التطبيق غير مستثنى حالياً';

  @override
  String get favEmptyTitle => 'لا شيء محفوظ بعد';

  @override
  String get favEmptyBody => 'اضغط على القلب أثناء القراءة ليُحفظ الذكر هنا.';

  @override
  String get currentStreak => 'التتابع الحالي';

  @override
  String get longest => 'الأطول';

  @override
  String get totalSessions => 'الجلسات';

  @override
  String get last14 => 'آخر ١٤ يوماً';

  @override
  String get byCategory => 'هذا الأسبوع';

  @override
  String get once => 'مرة واحدة';

  @override
  String get prev => 'السابق';

  @override
  String get reset => 'تصفير';

  @override
  String get next => 'التالي';

  @override
  String get shareAsImage => 'مشاركة كصورة';

  @override
  String get backHome => 'العودة للرئيسية';

  @override
  String get shareTitle => 'مشاركة الذكر';

  @override
  String get share => 'مشاركة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get appearance => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'غامق';

  @override
  String get system => 'النظام';

  @override
  String get fontSize => 'حجم نص الذكر';

  @override
  String get fontSizeSmall => 'صغير';

  @override
  String get fontSizeMedium => 'متوسط';

  @override
  String get fontSizeLarge => 'كبير';

  @override
  String get quranFont => 'الخط القرآني';

  @override
  String get done => 'تم';

  @override
  String get saveReschedule => 'حفظ وإعادة الجدولة';

  @override
  String timeOf(String slot) {
    return 'وقت $slot';
  }

  @override
  String get repeatsDaily => 'يتكرر يومياً';

  @override
  String get am => 'ص';

  @override
  String get pm => 'م';

  @override
  String get onb1Title => 'اذكر الله في وقته';

  @override
  String get onb1Body =>
      'تذكيرات لأذكار الصباح والمساء والنوم والاستيقاظ، تُجدول على جهازك وتعمل دون إنترنت. بلا حساب.';

  @override
  String get onb1Primary => 'لنبدأ';

  @override
  String get onb1Secondary => 'تخطي';

  @override
  String get onb2Title => 'نحتاج إذن التنبيهات';

  @override
  String get onb2Body =>
      'التذكيرات تُجدول على جهازك مباشرة، فلا بد من السماح بالتنبيهات — بدونها لن يصل أي تذكير.';

  @override
  String get onb2Note =>
      'يمكنك السماح لاحقاً من الإعدادات، لكن التذكيرات ستبقى معطّلة حتى ذلك الحين.';

  @override
  String get onb2Primary => 'السماح بالتنبيهات';

  @override
  String get onb2Secondary => 'ليس الآن';

  @override
  String get onb3Title => 'وقت دقيق للتذكير';

  @override
  String get onb3Body =>
      'ليصل التذكير في دقيقته، يحتاج التطبيق إذن «التنبيهات الدقيقة» من أندرويد.';

  @override
  String get onb3Note =>
      'إن رفضت، يستمر التطبيق في العمل لكن قد يتأخر التذكير بضع دقائق — وسنوضح ذلك في التذكيرات.';

  @override
  String get onb3Primary => 'السماح';

  @override
  String get onb3Secondary => 'المتابعة بدون دقة';

  @override
  String get onb4Title => 'استثناء من موفّر البطارية';

  @override
  String get onb4Body =>
      'بعض الأجهزة تُغلق التطبيقات في الخلفية فتُلغى التذكيرات. استثناء واحد يكفي.';

  @override
  String get onb4Note => 'سنفتح الشاشة الصحيحة لجهازك.';

  @override
  String get onb4Primary => 'استثناء التطبيق';

  @override
  String get onb4Secondary => 'لاحقاً';

  @override
  String notifBody(String thikr, String count, String minutes) {
    return '$thikr · $count أذكار · $minutes دقائق';
  }

  @override
  String scheduleThroughShort(String date) {
    return 'مجدولة حتى $date';
  }

  @override
  String get prayerFallbackNotice =>
      'تعذّر حساب المواقيت — تُستخدم الأوقات الثابتة مؤقتاً';

  @override
  String get notifTitleMorning => 'وقت أذكار الصباح';

  @override
  String get notifTitleEvening => 'وقت أذكار المساء';

  @override
  String get notifTitleSleep => 'وقت أذكار النوم';

  @override
  String get notifTitleWake => 'وقت أذكار الاستيقاظ';

  @override
  String get notifActionStart => 'ابدأ';

  @override
  String get notifActionSnooze => 'تأجيل ١٥ د';

  @override
  String get notifChannelName => 'تذكيرات الأذكار';

  @override
  String get brandShort => 'مِشْكَاة';

  @override
  String get brandName => 'مِشْكَاةُ';

  @override
  String get brandWird => 'الوِرْدِ';

  @override
  String get about => 'عن التطبيق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfUse => 'الشروط والأحكام';

  @override
  String get shareStyleAubergine => 'بنفسجي';

  @override
  String get shareStyleStone => 'حجري';

  @override
  String get nowLabel => 'الآن';

  @override
  String get nextLabel => 'التالي';

  @override
  String get begin => 'ابدأ';

  @override
  String get editTimes => 'تعديل الأوقات';

  @override
  String athkarCountLabel(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits ذكر',
      many: '$digits ذكراً',
      few: '$digits أذكار',
      two: 'ذكران',
      one: 'ذكر واحد',
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
      other: 'نحو $digits دقيقة',
      few: 'نحو $digits دقائق',
      two: 'نحو دقيقتين',
      one: 'نحو دقيقة',
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
      other: '$digits يوم متتالٍ',
      many: '$digits يوماً متتالياً',
      few: '$digits أيام متتالية',
      two: 'يومان متتاليان',
      one: 'يوم واحد متتالٍ',
    );
    return '$_temp0';
  }

  @override
  String get streakStart => 'ابدأ تتابعك اليوم';

  @override
  String daysCount(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits يوم',
      many: '$digits يوماً',
      few: '$digits أيام',
      two: 'يومان',
      one: 'يوم واحد',
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
      other: 'يوم',
      many: 'يوماً',
      few: 'أيام',
      two: 'يومان',
      one: 'يوم',
    );
    return '$_temp0';
  }

  @override
  String get bandWake => 'استيقاظ';

  @override
  String get bandMorning => 'صباح';

  @override
  String get bandEvening => 'مساء';

  @override
  String get bandSleep => 'نوم';

  @override
  String bandSemantics(String routine, String time, String state) {
    return '$routine، $time، $state';
  }

  @override
  String get stateDone => 'تمّت';

  @override
  String get stateNow => 'الآن';

  @override
  String get stateLater => 'لاحقاً';

  @override
  String get allDoneTitle => 'أتممت أذكار اليوم';

  @override
  String tomorrowAt(String routine, String time) {
    return '$routine غداً $time';
  }

  @override
  String get notifOffTitle => 'التنبيهات معطّلة';

  @override
  String get notifOffBody => 'لن تصل أي تذكيرات حتى تسمح بها.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get remindersAllOff => 'كل التذكيرات متوقفة — الأوقات للعرض فقط';

  @override
  String get libAfterPrayer => 'بعد الصلاة';

  @override
  String get libMisc => 'متفرقة';

  @override
  String get close => 'إغلاق';

  @override
  String tasbihRound(String round, String target) {
    return 'الدورة $round · من $target';
  }

  @override
  String get tasbihFree => 'عدّ حر';

  @override
  String get tasbihNoLimit => 'بلا حد';

  @override
  String get tasbihHint => 'المس أي مكان للعد · اهتزاز خفيف عند كل ٣٣';

  @override
  String get favoriteAdd => 'حفظ في المفضلة';

  @override
  String get favoriteRemove => 'إزالة من المفضلة';

  @override
  String get scrollToContinue => 'مرّر للمتابعة';

  @override
  String counterOf(String total) {
    return 'من $total';
  }

  @override
  String counterRemaining(String remaining, String total) {
    return 'المتبقي $remaining من $total';
  }

  @override
  String positionOf(String index, String total) {
    return '$index من $total';
  }

  @override
  String doneRoutine(String routine) {
    return 'تمّت $routine';
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
      other: 'تتابعك الآن $digits يوم.',
      many: 'تتابعك الآن $digits يوماً.',
      few: 'تتابعك الآن $digits أيام.',
      two: 'تتابعك الآن يومان.',
      one: 'تتابعك الآن يوم واحد.',
      zero: 'ابدأ تتابعك اليوم.',
    );
    return '$_temp0';
  }

  @override
  String nextReminderLine(String routine, String time) {
    return 'التذكير القادم $routine $time.';
  }

  @override
  String get shareChooseTitle => 'اختر ذكراً للمشاركة';

  @override
  String get exactBanner =>
      'قد تتأخر التذكيرات بضع دقائق — التنبيهات الدقيقة غير مسموحة.';

  @override
  String get allow => 'السماح';

  @override
  String get slotDaily => 'يومياً';

  @override
  String pendingShort(String count) {
    return '$count معلّقة';
  }

  @override
  String windowShort(String date, String pending, String cap) {
    return 'مجدولة حتى $date · $pending من $cap معلّقة';
  }

  @override
  String get timeSheetHint => 'يتكرر يومياً · خطوات ٥ دقائق';

  @override
  String get favHint => 'اضغط على الذكر لقراءته · اسحب لإزالته';

  @override
  String get browseAthkar => 'تصفّح الأذكار';

  @override
  String get legendFull => 'كامل';

  @override
  String get legendPartial => 'جزئي';

  @override
  String get legendNone => 'لا شيء';

  @override
  String weekRatio(String done, String target) {
    return '$done / $target';
  }

  @override
  String get errorTitle => 'تعذّر تحميل الأذكار';

  @override
  String get errorBody => 'حدث خطأ غير متوقع. تذكيراتك المجدولة لم تتأثر.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String onb4NoteVendor(String vendor) {
    return 'جهازك: $vendor · سنفتح الشاشة الصحيحة';
  }

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String onbStep(String index, String total) {
    return 'الخطوة $index من $total';
  }

  @override
  String get slotWakeShort => 'الاستيقاظ';

  @override
  String get slotMorningShort => 'الصباح';

  @override
  String get slotEveningShort => 'المساء';

  @override
  String get slotSleepShort => 'النوم';

  @override
  String get hourUp => 'زيادة الساعة';

  @override
  String get hourDown => 'إنقاص الساعة';

  @override
  String get minuteUp => 'زيادة الدقائق';

  @override
  String get minuteDown => 'إنقاص الدقائق';

  @override
  String timesCount(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits مرة',
      few: '$digits مرات',
      two: 'مرتان',
      one: 'مرة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get textSmaller => 'تصغير نص الذكر';

  @override
  String get textLarger => 'تكبير نص الذكر';

  @override
  String get readerStartAgain => 'البدء من جديد';

  @override
  String get readerRestartQuestion => 'هل تريد بدء هذه الجلسة من جديد؟';

  @override
  String get readerRestoreError =>
      'تعذّر استعادة القراءة المحفوظة. يمكنك الإغلاق أو البدء من جديد.';

  @override
  String get readerSaveError =>
      'تعذّر حفظ التقدّم. أبقِ التطبيق مفتوحًا وحاول مجددًا.';

  @override
  String get back => 'رجوع';

  @override
  String get settingsReading => 'القراءة';

  @override
  String get settingsLanguageAppearance => 'اللغة والمظهر';

  @override
  String get settingsSupport => 'الدعم';

  @override
  String versionLine(String version) {
    return 'نور الذكر اليومي · الإصدار $version';
  }

  @override
  String get account => 'الحساب';

  @override
  String get accountCardTitle => 'احفظ تقدّمك على كل أجهزتك';

  @override
  String get accountCardBody => 'اختياري · التطبيق يعمل كاملاً بدونه';

  @override
  String get signInShort => 'دخول';

  @override
  String get signInToSync => 'سجّل الدخول لمزامنة تقدّمك';

  @override
  String syncedAgo(String ago) {
    return 'آخر مزامنة $ago';
  }

  @override
  String get notSyncedYet => 'لم تتم المزامنة بعد';

  @override
  String get feedback => 'ملاحظات واقتراحات';

  @override
  String get inbox => 'صندوق الوارد';

  @override
  String get unreadReply => 'رد جديد';

  @override
  String withUnread(String label, String state) {
    return '$label، $state';
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
      other: '$digits غير مقروءة',
      many: '$digits غير مقروءة',
      few: '$digits غير مقروءة',
      two: 'اثنتان غير مقروءتين',
      one: 'واحدة غير مقروءة',
    );
    return '$_temp0';
  }

  @override
  String get signInTitle => 'احفظ وِردك على كل أجهزتك';

  @override
  String get signInSubtitle => 'الحساب اختياري، والتطبيق يعمل كاملاً بدونه.';

  @override
  String get signInStreak => 'تتابعك وجلساتك';

  @override
  String get signInStreakBody => 'لا تضيع عند تغيير الجهاز';

  @override
  String get signInFavorites => 'المفضلة';

  @override
  String get signInFavoritesBody => 'أذكارك المحفوظة معك على كل جهاز';

  @override
  String get signInSettingsBody => 'أوقات التذكير والمظهر تنتقل معك';

  @override
  String get signInApple => 'تسجيل الدخول باستخدام Apple';

  @override
  String get signInGoogle => 'تسجيل الدخول باستخدام Google';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get signInPrivacy => 'نستخدم حسابك لمزامنة تقدّمك ومفضلتك وإعداداتك.';

  @override
  String get signInFailed => 'تعذّر تسجيل الدخول. حاول مرة أخرى.';

  @override
  String get signedInToast => 'تم تسجيل الدخول';

  @override
  String get mergeTitle => 'تم ربط حسابك';

  @override
  String mergeBody(String items) {
    return 'دمجنا $items من هذا الجهاز مع حسابك.';
  }

  @override
  String mergeAnd(String a, String b) {
    return '$a و$b';
  }

  @override
  String get mergeSettingsOnly => 'دمجنا إعداداتك من هذا الجهاز مع حسابك.';

  @override
  String mergeSessions(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$digits جلسة',
      many: '$digits جلسة',
      few: '$digits جلسات',
      two: 'جلستين',
      one: 'جلسة واحدة',
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
      other: '$digits ذكر محفوظ',
      many: '$digits ذكراً محفوظاً',
      few: '$digits أذكار محفوظة',
      two: 'ذكرين محفوظين',
      one: 'ذكراً محفوظاً',
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
      other: '$digits جلسة',
      many: '$digits جلسة',
      few: '$digits جلسات',
      two: 'جلستان',
      one: 'جلسة واحدة',
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
      other: '$digits ذكر محفوظ',
      many: '$digits ذكراً محفوظاً',
      few: '$digits أذكار محفوظة',
      two: 'ذكران محفوظان',
      one: 'ذكر محفوظ',
    );
    return '$_temp0';
  }

  @override
  String currentStreakLine(String days) {
    return 'تتابعك الحالي: $days';
  }

  @override
  String get continueLabel => 'متابعة';

  @override
  String viaProvider(String provider) {
    return 'عبر $provider';
  }

  @override
  String get syncSynced => 'تمت المزامنة';

  @override
  String get syncSyncing => 'جارٍ المزامنة…';

  @override
  String get syncSyncingBody => 'يمكنك متابعة القراءة';

  @override
  String get syncOffline => 'غير متصل';

  @override
  String get syncOfflineBody => 'ستتم المزامنة عند الاتصال';

  @override
  String get syncError => 'تعذّرت المزامنة';

  @override
  String get syncErrorBody => 'بياناتك آمنة على هذا الجهاز';

  @override
  String get syncNow => 'زامن الآن';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutBody => 'تبقى بياناتك على هذا الجهاز';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteTitle => 'حذف حسابك؟';

  @override
  String get deleteSubtitle => 'لا يمكن التراجع عن هذا.';

  @override
  String get deleteRemovedHeading => 'يُحذف من حسابك';

  @override
  String get deleteItemProgress => 'التقدّم والتتابع المتزامن';

  @override
  String get deleteItemMessages => 'رسائلك مع فريق مشكاة';

  @override
  String get deleteKeptHeading => 'يبقى على هذا الجهاز';

  @override
  String get deleteKeptBody =>
      'كل ما هو محفوظ هنا يبقى، وتستمر في استخدام التطبيق بدون حساب.';

  @override
  String get deleteConfirm => 'حذف الحساب نهائياً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deleteFailed =>
      'تعذّر حذف الحساب. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get deleteFailedTryLater =>
      'تعذّر حذف الحساب الآن. حاول مرة أخرى بعد قليل.';

  @override
  String get appleAccount => 'حساب Apple';

  @override
  String get rateApp => 'قيّم التطبيق';

  @override
  String get thikrSources => 'مصادر الأذكار';

  @override
  String get sourcesIntro =>
      'نصوص الأذكار مأخوذة من كتب السنة التالية، وكل ذكر يذكر مصدره تحته.';

  @override
  String get sourcesReview =>
      'التخريج قيد المراجعة من مختص قبل الإصدار. إن وجدت خطأً فأبلغنا من قائمة الذكر.';

  @override
  String get contentVersionLabel => 'إصدار المحتوى';

  @override
  String get accountDeletedToast => 'حُذف حسابك';

  @override
  String get nudgeTitle => 'احفظ تتابعك';

  @override
  String get nudgeBody => 'سجّل الدخول ليبقى تتابعك محفوظاً إذا غيّرت جهازك.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get dismiss => 'إخفاء';

  @override
  String get more => 'المزيد';

  @override
  String get reportThikr => 'الإبلاغ عن خطأ في هذا الذكر';

  @override
  String get copyText => 'نسخ النص';

  @override
  String get copied => 'نُسخ النص';

  @override
  String get feedbackIntro =>
      'نقرأ كل رسالة، ويصلك الرد في «ملاحظات واقتراحات».';

  @override
  String get typeFeature => 'اقتراح ميزة';

  @override
  String get typeThikr => 'خطأ في ذكر';

  @override
  String get typeBug => 'مشكلة في التطبيق';

  @override
  String get yourMessage => 'رسالتك';

  @override
  String get messageHint => 'اكتب رسالتك…';

  @override
  String charCount(String count, String max) {
    return '$count / $max';
  }

  @override
  String get replyEmail => 'بريدك للرد (اختياري)';

  @override
  String get replyEmailNote => 'نرد داخل التطبيق، والبريد احتياطي فقط.';

  @override
  String get invalidEmail => 'البريد غير صحيح';

  @override
  String get attachDevice => 'إرفاق معلومات الجهاز';

  @override
  String get attachDeviceBody => 'إصدار التطبيق، النظام، اللغة';

  @override
  String get send => 'إرسال';

  @override
  String get reportTitle => 'الإبلاغ عن خطأ في ذكر';

  @override
  String get whatsWrong => 'ما الخطأ؟';

  @override
  String get issueText => 'النص';

  @override
  String get issueSource => 'التخريج';

  @override
  String get issueCount => 'عدد المرات';

  @override
  String get issueTranslation => 'الترجمة';

  @override
  String get details => 'التفاصيل';

  @override
  String get sendReport => 'إرسال البلاغ';

  @override
  String get sentTitle => 'وصلتنا رسالتك';

  @override
  String get sentBody =>
      'ستجد الرد في «ملاحظات واقتراحات». ستظهر نقطة على الإعدادات عند وصوله.';

  @override
  String get viewMyMessages => 'عرض رسائلي';

  @override
  String get queuedTitle => 'ستُرسل عند الاتصال';

  @override
  String get queuedBody => 'حفظناها على جهازك وسنرسلها تلقائياً.';

  @override
  String get sendFailedTitle => 'تعذّر الإرسال';

  @override
  String get sendFailedBody => 'رسالتك محفوظة كمسودة.';

  @override
  String get statusNew => 'جديدة';

  @override
  String get statusInReview => 'قيد المراجعة';

  @override
  String get statusAnswered => 'تم الرد';

  @override
  String get statusClosed => 'مغلقة';

  @override
  String get statusQueued => 'بانتظار الاتصال';

  @override
  String get repliesInAppOnly => 'الردود تظهر هنا فقط، ولا تصل كإشعارات.';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get noMessagesTitle => 'لا رسائل بعد';

  @override
  String get noMessagesBody =>
      'إذا أرسلت اقتراحاً أو أبلغت عن خطأ، ستجد الرد هنا.';

  @override
  String get sendFeedback => 'أرسل ملاحظة';

  @override
  String startedOn(String date) {
    return 'بدأت $date';
  }

  @override
  String get mishkatTeam => 'فريق مشكاة';

  @override
  String get writeReply => 'اكتب رداً…';

  @override
  String get sendReply => 'إرسال الرد';

  @override
  String closedOn(String date) {
    return 'أُغلقت في $date';
  }

  @override
  String get threadClosedTitle => 'هذه المحادثة مغلقة';

  @override
  String get threadClosedBody => 'تحتاج مساعدة أخرى؟ ابدأ محادثة جديدة.';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterIdeas => 'اقتراحات';

  @override
  String get filterAthkar => 'أذكار';

  @override
  String get filterApp => 'مشكلات';

  @override
  String get inboxEmptyTitle => 'لا جديد هنا';

  @override
  String get inboxEmptyBody => 'لا رسائل تطابق هذا الاختيار.';

  @override
  String get clearFilters => 'مسح التصفية';

  @override
  String messageNumber(String number) {
    return 'رسالة #$number';
  }

  @override
  String get messageUnnumbered => 'رسالة';

  @override
  String get metaType => 'النوع';

  @override
  String get metaVersion => 'الإصدار';

  @override
  String get metaPlatform => 'المنصة';

  @override
  String get metaDate => 'التاريخ';

  @override
  String get metaEmail => 'البريد';

  @override
  String get notAttached => 'غير مرفق';

  @override
  String get openThikr => 'افتح الذكر';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get theUser => 'المستخدم';

  @override
  String get adminReplyNote =>
      'يظهر ردّك لدى المستخدم في «ملاحظات واقتراحات»، ويتحول الوضع إلى «تم الرد».';

  @override
  String get writeReplyToUser => 'اكتب رداً للمستخدم…';

  @override
  String minutesAgo(num count, String digits) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'قبل $digits دقيقة',
      many: 'قبل $digits دقيقة',
      few: 'قبل $digits دقائق',
      two: 'قبل دقيقتين',
      one: 'قبل دقيقة',
    );
    return '$_temp0';
  }

  @override
  String minutesAgoShort(String digits) {
    return 'قبل $digits د';
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
      other: 'قبل $digits ساعة',
      many: 'قبل $digits ساعة',
      few: 'قبل $digits ساعات',
      two: 'قبل ساعتين',
      one: 'قبل ساعة',
    );
    return '$_temp0';
  }

  @override
  String get yesterday => 'أمس';

  @override
  String get justNow => 'الآن';
}
