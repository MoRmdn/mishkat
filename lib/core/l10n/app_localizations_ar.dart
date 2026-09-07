// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class LAr extends L {
  LAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تطبيق الأذكار';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navReminders => 'التذكيرات';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navProgress => 'التقدّم';

  @override
  String get titleHome => 'الأذكار';

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
  String get nextReminder => 'التذكير القادم';

  @override
  String get edit => 'تعديل';

  @override
  String inHours(String hours, String minutes) {
    return 'بعد $hours ساعات و$minutes دقيقة';
  }

  @override
  String get prayerBased => 'محسوب على مواقيت اليوم';

  @override
  String get schedFixed => 'مجدولة يومياً — لا تحتاج فتح التطبيق';

  @override
  String schedPrayer(String date, String days) {
    return 'مجدولة حتى $date ($days يوماً)';
  }

  @override
  String get tasbihTitle => 'السبحة';

  @override
  String get tasbihSub => 'عدّاد حر — انقر على الشاشة للتسبيح';

  @override
  String get dayUnit => 'يوم';

  @override
  String get dayUnitPl => 'يوماً';

  @override
  String get sessions => 'جلسة';

  @override
  String get fixedMode => 'وقت ثابت';

  @override
  String get prayerMode => 'حسب مواقيت الصلاة';

  @override
  String get exactTitle => 'التنبيهات الدقيقة غير مسموحة';

  @override
  String get exactBody =>
      'قد تتأخر التذكيرات بضع دقائق. يمكنك السماح بها من إعدادات النظام.';

  @override
  String get exactAllow => 'السماح بالتنبيهات الدقيقة';

  @override
  String get daily => 'يومياً · يتكرر تلقائياً';

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
  String get slotPrayerWake => 'قبل الفجر بـ ١٥ دقيقة';

  @override
  String get slotPrayerMorning => 'بعد الفجر بـ ٣٠ دقيقة';

  @override
  String get slotPrayerEvening => 'بعد العصر بـ ٤٥ دقيقة';

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
  String todayTimesFor(String city) {
    return 'مواقيت اليوم — $city';
  }

  @override
  String get todayTimes => 'مواقيت اليوم';

  @override
  String get fajr => 'الفجر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get windowLabel => 'النافذة المجدولة';

  @override
  String windowText(String days, String pending, String cap) {
    return 'الأيام المجدولة: $days · التنبيهات المعلّقة: $pending من $cap';
  }

  @override
  String get method => 'طريقة الحساب';

  @override
  String get madhab => 'المذهب في العصر';

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
  String get oemHintOn => 'الجهاز مستثنى من موفّر البطارية ✓';

  @override
  String oemHintOff(String vendor) {
    return 'دليل خاص بجهازك — $vendor';
  }

  @override
  String get oemBody =>
      'أنظمة بعض الشركات توقف التطبيقات في الخلفية فتُلغى التذكيرات. اتبع الخطوات التالية مرة واحدة.';

  @override
  String oemHeading(String vendor) {
    return 'إعدادات $vendor';
  }

  @override
  String get oemStep1 => 'الإعدادات ← التطبيقات ← إدارة التطبيقات ← مشكاة';

  @override
  String get oemStep2 => 'فعّل «التشغيل التلقائي» إن كان متاحاً على جهازك';

  @override
  String get oemStep3 => 'من «موفّر البطارية» اختر «بدون قيود»';

  @override
  String get oemStep4 => 'ثبّت التطبيق من شاشة التطبيقات الحديثة';

  @override
  String get oemGenericHint =>
      'خطوات عامة — قد تختلف التسميات قليلاً بين الأجهزة';

  @override
  String get openBattery => 'فتح إعدادات البطارية';

  @override
  String get batteryOn => 'التطبيق مستثنى حالياً ✓';

  @override
  String get batteryOff => 'التطبيق غير مستثنى';

  @override
  String get favEmptyTitle => 'لا توجد أذكار محفوظة بعد';

  @override
  String get favEmptyBody => 'اضغط على القلب أثناء القراءة لحفظ الذكر هنا.';

  @override
  String get currentStreak => 'تتابع مستمر';

  @override
  String get longest => 'أطول تتابع';

  @override
  String get totalSessions => 'إجمالي الجلسات';

  @override
  String get last14 => 'آخر ١٤ يوماً';

  @override
  String get byCategory => 'حسب الفئة — هذا الأسبوع';

  @override
  String get countOf => 'من';

  @override
  String get once => 'مرة واحدة';

  @override
  String get tapHint => 'انقر في أي مكان للعد · الشاشة تبقى مضاءة';

  @override
  String get completedToday => 'أُكملت اليوم';

  @override
  String athkarCount(String count) {
    return '$count أذكار';
  }

  @override
  String get prev => 'السابق';

  @override
  String get reset => 'تصفير';

  @override
  String get next => 'التالي';

  @override
  String get donePrefix => 'تمّت';

  @override
  String doneTitle(String category) {
    return 'تمّت — $category';
  }

  @override
  String doneStreak(String days, String time) {
    return 'تتابعك الآن $days يوماً. التذكير القادم $time.';
  }

  @override
  String get shareAsImage => 'مشاركة كصورة';

  @override
  String get backHome => 'العودة للرئيسية';

  @override
  String get shareTitle => 'مشاركة الذكر';

  @override
  String get saveImage => 'حفظ كصورة';

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
  String get themeLabel => 'لون التطبيق';

  @override
  String get themeTeal => 'أخضر حجري';

  @override
  String get themeIndigo => 'نيلي';

  @override
  String get themeOlive => 'زيتوني';

  @override
  String get fontSize => 'حجم الخط';

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
      'تذكيرات لطيفة لأذكار الصباح والمساء والنوم والاستيقاظ — تعمل بالكامل دون إنترنت.';

  @override
  String get onb1NoteLabel => 'بدون حساب';

  @override
  String get onb1Note =>
      'لا تسجيل دخول ولا بيانات تُرسل. كل شيء محفوظ على جهازك.';

  @override
  String get onb1Primary => 'لنبدأ';

  @override
  String get onb1Secondary => 'تخطي التهيئة';

  @override
  String get onb2Title => 'نحتاج إذن التنبيهات';

  @override
  String get onb2Body =>
      'التذكيرات تُجدول على جهازك مباشرة، لذلك لا بد من السماح بالتنبيهات — بدونها لن يصل أي تذكير.';

  @override
  String get onb2NoteLabel => 'لماذا الآن';

  @override
  String get onb2Note =>
      'يمكنك السماح لاحقاً من الإعدادات، ولكن التذكيرات ستبقى معطلة حتى ذلك الحين.';

  @override
  String get onb2Primary => 'السماح بالتنبيهات';

  @override
  String get onb2Secondary => 'ليس الآن';

  @override
  String get onb3Title => 'وقت دقيق للتذكير';

  @override
  String get onb3Body =>
      'ليصل التذكير في وقته بالضبط، يحتاج التطبيق إذن «التنبيهات الدقيقة» من نظام أندرويد.';

  @override
  String get onb3NoteLabel => 'إن رفضت';

  @override
  String get onb3Note =>
      'سيستمر التطبيق في العمل، لكن قد يتأخر التذكير بضع دقائق، وسنخبرك بذلك في الإعدادات.';

  @override
  String get onb3Primary => 'السماح';

  @override
  String get onb3Secondary => 'المتابعة بدون دقة';

  @override
  String get onb4Title => 'حرّر التطبيق من موفّر البطارية';

  @override
  String get onb4Body =>
      'أنظمة بعض الأجهزة تُغلق التطبيقات في الخلفية فتُلغى التذكيرات المجدولة. استثناء واحد يحل المشكلة نهائياً.';

  @override
  String get onb4NoteLabel => 'خطوة واحدة';

  @override
  String get onb4Note => 'سنفتح لك شاشة الإعدادات الصحيحة لجهازك، ثم ننتهي.';

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
  String get notificationsBlocked => 'التنبيهات غير مسموحة — لن تصل التذكيرات';

  @override
  String get enableNotifications => 'تفعيل التنبيهات';

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
}
