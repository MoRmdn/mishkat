import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق الأذكار'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navReminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get navReminders;

  /// No description provided for @navFavorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get navFavorites;

  /// No description provided for @navProgress.
  ///
  /// In ar, this message translates to:
  /// **'التقدّم'**
  String get navProgress;

  /// No description provided for @titleHome.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get titleHome;

  /// No description provided for @titleReminders.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات'**
  String get titleReminders;

  /// No description provided for @titleFavorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get titleFavorites;

  /// No description provided for @titleProgress.
  ///
  /// In ar, this message translates to:
  /// **'التقدّم'**
  String get titleProgress;

  /// No description provided for @catMorning.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get catMorning;

  /// No description provided for @catEvening.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get catEvening;

  /// No description provided for @catSleep.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get catSleep;

  /// No description provided for @catWake.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الاستيقاظ'**
  String get catWake;

  /// No description provided for @catAfterPrayer.
  ///
  /// In ar, this message translates to:
  /// **'أذكار بعد الصلاة'**
  String get catAfterPrayer;

  /// No description provided for @catMisc.
  ///
  /// In ar, this message translates to:
  /// **'أذكار متفرقة'**
  String get catMisc;

  /// No description provided for @catTasbih.
  ///
  /// In ar, this message translates to:
  /// **'السبحة'**
  String get catTasbih;

  /// No description provided for @nextReminder.
  ///
  /// In ar, this message translates to:
  /// **'التذكير القادم'**
  String get nextReminder;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @inHours.
  ///
  /// In ar, this message translates to:
  /// **'بعد {hours} ساعات و{minutes} دقيقة'**
  String inHours(String hours, String minutes);

  /// No description provided for @prayerBased.
  ///
  /// In ar, this message translates to:
  /// **'محسوب على مواقيت اليوم'**
  String get prayerBased;

  /// No description provided for @schedFixed.
  ///
  /// In ar, this message translates to:
  /// **'مجدولة يومياً — لا تحتاج فتح التطبيق'**
  String get schedFixed;

  /// No description provided for @schedPrayer.
  ///
  /// In ar, this message translates to:
  /// **'مجدولة حتى {date} ({days} يوماً)'**
  String schedPrayer(String date, String days);

  /// No description provided for @tasbihTitle.
  ///
  /// In ar, this message translates to:
  /// **'السبحة'**
  String get tasbihTitle;

  /// No description provided for @tasbihSub.
  ///
  /// In ar, this message translates to:
  /// **'عدّاد حر — انقر على الشاشة للتسبيح'**
  String get tasbihSub;

  /// No description provided for @dayUnit.
  ///
  /// In ar, this message translates to:
  /// **'يوم'**
  String get dayUnit;

  /// No description provided for @dayUnitPl.
  ///
  /// In ar, this message translates to:
  /// **'يوماً'**
  String get dayUnitPl;

  /// No description provided for @sessions.
  ///
  /// In ar, this message translates to:
  /// **'جلسة'**
  String get sessions;

  /// No description provided for @fixedMode.
  ///
  /// In ar, this message translates to:
  /// **'وقت ثابت'**
  String get fixedMode;

  /// No description provided for @prayerMode.
  ///
  /// In ar, this message translates to:
  /// **'حسب مواقيت الصلاة'**
  String get prayerMode;

  /// No description provided for @exactTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات الدقيقة غير مسموحة'**
  String get exactTitle;

  /// No description provided for @exactBody.
  ///
  /// In ar, this message translates to:
  /// **'قد تتأخر التذكيرات بضع دقائق. يمكنك السماح بها من إعدادات النظام.'**
  String get exactBody;

  /// No description provided for @exactAllow.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالتنبيهات الدقيقة'**
  String get exactAllow;

  /// No description provided for @daily.
  ///
  /// In ar, this message translates to:
  /// **'يومياً · يتكرر تلقائياً'**
  String get daily;

  /// No description provided for @off.
  ///
  /// In ar, this message translates to:
  /// **'معطّل'**
  String get off;

  /// No description provided for @slotWake.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الاستيقاظ'**
  String get slotWake;

  /// No description provided for @slotMorning.
  ///
  /// In ar, this message translates to:
  /// **'أذكار الصباح'**
  String get slotMorning;

  /// No description provided for @slotEvening.
  ///
  /// In ar, this message translates to:
  /// **'أذكار المساء'**
  String get slotEvening;

  /// No description provided for @slotSleep.
  ///
  /// In ar, this message translates to:
  /// **'أذكار النوم'**
  String get slotSleep;

  /// No description provided for @slotPrayerWake.
  ///
  /// In ar, this message translates to:
  /// **'قبل الفجر بـ ١٥ دقيقة'**
  String get slotPrayerWake;

  /// No description provided for @slotPrayerMorning.
  ///
  /// In ar, this message translates to:
  /// **'بعد الفجر بـ ٣٠ دقيقة'**
  String get slotPrayerMorning;

  /// No description provided for @slotPrayerEvening.
  ///
  /// In ar, this message translates to:
  /// **'بعد العصر بـ ٤٥ دقيقة'**
  String get slotPrayerEvening;

  /// No description provided for @slotPrayerSleep.
  ///
  /// In ar, this message translates to:
  /// **'وقت ثابت دائماً'**
  String get slotPrayerSleep;

  /// No description provided for @todayTimes.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت اليوم'**
  String get todayTimes;

  /// No description provided for @fajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get fajr;

  /// No description provided for @asr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get maghrib;

  /// No description provided for @windowLabel.
  ///
  /// In ar, this message translates to:
  /// **'النافذة المجدولة'**
  String get windowLabel;

  /// No description provided for @windowText.
  ///
  /// In ar, this message translates to:
  /// **'الأيام المجدولة: {days} · التنبيهات المعلّقة: {pending} من {cap}'**
  String windowText(String days, String pending, String cap);

  /// No description provided for @method.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get method;

  /// No description provided for @madhab.
  ///
  /// In ar, this message translates to:
  /// **'المذهب في العصر'**
  String get madhab;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get location;

  /// No description provided for @methodUmmAlQura.
  ///
  /// In ar, this message translates to:
  /// **'أم القرى'**
  String get methodUmmAlQura;

  /// No description provided for @methodMwl.
  ///
  /// In ar, this message translates to:
  /// **'رابطة العالم الإسلامي'**
  String get methodMwl;

  /// No description provided for @methodEgypt.
  ///
  /// In ar, this message translates to:
  /// **'الهيئة المصرية'**
  String get methodEgypt;

  /// No description provided for @madhabStandard.
  ///
  /// In ar, this message translates to:
  /// **'الجمهور'**
  String get madhabStandard;

  /// No description provided for @madhabHanafi.
  ///
  /// In ar, this message translates to:
  /// **'الحنفي'**
  String get madhabHanafi;

  /// No description provided for @oemTitle.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات لا تصل؟'**
  String get oemTitle;

  /// No description provided for @oemHintOn.
  ///
  /// In ar, this message translates to:
  /// **'الجهاز مستثنى من موفّر البطارية ✓'**
  String get oemHintOn;

  /// No description provided for @oemHintOff.
  ///
  /// In ar, this message translates to:
  /// **'دليل خاص بجهازك — {vendor}'**
  String oemHintOff(String vendor);

  /// No description provided for @oemBody.
  ///
  /// In ar, this message translates to:
  /// **'أنظمة بعض الشركات توقف التطبيقات في الخلفية فتُلغى التذكيرات. اتبع الخطوات التالية مرة واحدة.'**
  String get oemBody;

  /// No description provided for @openBattery.
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات البطارية'**
  String get openBattery;

  /// No description provided for @batteryOn.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق مستثنى حالياً ✓'**
  String get batteryOn;

  /// No description provided for @batteryOff.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق غير مستثنى'**
  String get batteryOff;

  /// No description provided for @favEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أذكار محفوظة بعد'**
  String get favEmptyTitle;

  /// No description provided for @favEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على القلب أثناء القراءة لحفظ الذكر هنا.'**
  String get favEmptyBody;

  /// No description provided for @currentStreak.
  ///
  /// In ar, this message translates to:
  /// **'تتابع مستمر'**
  String get currentStreak;

  /// No description provided for @longest.
  ///
  /// In ar, this message translates to:
  /// **'أطول تتابع'**
  String get longest;

  /// No description provided for @totalSessions.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الجلسات'**
  String get totalSessions;

  /// No description provided for @last14.
  ///
  /// In ar, this message translates to:
  /// **'آخر ١٤ يوماً'**
  String get last14;

  /// No description provided for @byCategory.
  ///
  /// In ar, this message translates to:
  /// **'حسب الفئة — هذا الأسبوع'**
  String get byCategory;

  /// No description provided for @countOf.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get countOf;

  /// No description provided for @once.
  ///
  /// In ar, this message translates to:
  /// **'مرة واحدة'**
  String get once;

  /// No description provided for @tapHint.
  ///
  /// In ar, this message translates to:
  /// **'انقر في أي مكان للعد · الشاشة تبقى مضاءة'**
  String get tapHint;

  /// No description provided for @completedToday.
  ///
  /// In ar, this message translates to:
  /// **'أُكملت اليوم'**
  String get completedToday;

  /// No description provided for @athkarCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} أذكار'**
  String athkarCount(String count);

  /// No description provided for @prev.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get prev;

  /// No description provided for @reset.
  ///
  /// In ar, this message translates to:
  /// **'تصفير'**
  String get reset;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @donePrefix.
  ///
  /// In ar, this message translates to:
  /// **'تمّت'**
  String get donePrefix;

  /// No description provided for @doneTitle.
  ///
  /// In ar, this message translates to:
  /// **'تمّت — {category}'**
  String doneTitle(String category);

  /// No description provided for @doneStreak.
  ///
  /// In ar, this message translates to:
  /// **'تتابعك الآن {days} يوماً. التذكير القادم {time}.'**
  String doneStreak(String days, String time);

  /// No description provided for @shareAsImage.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة كصورة'**
  String get shareAsImage;

  /// No description provided for @backHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get backHome;

  /// No description provided for @shareTitle.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة الذكر'**
  String get shareTitle;

  /// No description provided for @saveImage.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كصورة'**
  String get saveImage;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @appearance.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearance;

  /// No description provided for @light.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ar, this message translates to:
  /// **'غامق'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get system;

  /// No description provided for @themeLabel.
  ///
  /// In ar, this message translates to:
  /// **'لون التطبيق'**
  String get themeLabel;

  /// No description provided for @themeTeal.
  ///
  /// In ar, this message translates to:
  /// **'أخضر حجري'**
  String get themeTeal;

  /// No description provided for @themeIndigo.
  ///
  /// In ar, this message translates to:
  /// **'نيلي'**
  String get themeIndigo;

  /// No description provided for @themeOlive.
  ///
  /// In ar, this message translates to:
  /// **'زيتوني'**
  String get themeOlive;

  /// No description provided for @fontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get fontSize;

  /// No description provided for @fontSizeSmall.
  ///
  /// In ar, this message translates to:
  /// **'صغير'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير'**
  String get fontSizeLarge;

  /// No description provided for @quranFont.
  ///
  /// In ar, this message translates to:
  /// **'الخط القرآني'**
  String get quranFont;

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @saveReschedule.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وإعادة الجدولة'**
  String get saveReschedule;

  /// No description provided for @timeOf.
  ///
  /// In ar, this message translates to:
  /// **'وقت {slot}'**
  String timeOf(String slot);

  /// No description provided for @repeatsDaily.
  ///
  /// In ar, this message translates to:
  /// **'يتكرر يومياً'**
  String get repeatsDaily;

  /// No description provided for @am.
  ///
  /// In ar, this message translates to:
  /// **'ص'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In ar, this message translates to:
  /// **'م'**
  String get pm;

  /// No description provided for @onb1Title.
  ///
  /// In ar, this message translates to:
  /// **'اذكر الله في وقته'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات لطيفة لأذكار الصباح والمساء والنوم والاستيقاظ — تعمل بالكامل دون إنترنت.'**
  String get onb1Body;

  /// No description provided for @onb1NoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'بدون حساب'**
  String get onb1NoteLabel;

  /// No description provided for @onb1Note.
  ///
  /// In ar, this message translates to:
  /// **'لا تسجيل دخول ولا بيانات تُرسل. كل شيء محفوظ على جهازك.'**
  String get onb1Note;

  /// No description provided for @onb1Primary.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ'**
  String get onb1Primary;

  /// No description provided for @onb1Secondary.
  ///
  /// In ar, this message translates to:
  /// **'تخطي التهيئة'**
  String get onb1Secondary;

  /// No description provided for @onb2Title.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج إذن التنبيهات'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات تُجدول على جهازك مباشرة، لذلك لا بد من السماح بالتنبيهات — بدونها لن يصل أي تذكير.'**
  String get onb2Body;

  /// No description provided for @onb2NoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'لماذا الآن'**
  String get onb2NoteLabel;

  /// No description provided for @onb2Note.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك السماح لاحقاً من الإعدادات، ولكن التذكيرات ستبقى معطلة حتى ذلك الحين.'**
  String get onb2Note;

  /// No description provided for @onb2Primary.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالتنبيهات'**
  String get onb2Primary;

  /// No description provided for @onb2Secondary.
  ///
  /// In ar, this message translates to:
  /// **'ليس الآن'**
  String get onb2Secondary;

  /// No description provided for @onb3Title.
  ///
  /// In ar, this message translates to:
  /// **'وقت دقيق للتذكير'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In ar, this message translates to:
  /// **'ليصل التذكير في وقته بالضبط، يحتاج التطبيق إذن «التنبيهات الدقيقة» من نظام أندرويد.'**
  String get onb3Body;

  /// No description provided for @onb3NoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'إن رفضت'**
  String get onb3NoteLabel;

  /// No description provided for @onb3Note.
  ///
  /// In ar, this message translates to:
  /// **'سيستمر التطبيق في العمل، لكن قد يتأخر التذكير بضع دقائق، وسنخبرك بذلك في الإعدادات.'**
  String get onb3Note;

  /// No description provided for @onb3Primary.
  ///
  /// In ar, this message translates to:
  /// **'السماح'**
  String get onb3Primary;

  /// No description provided for @onb3Secondary.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة بدون دقة'**
  String get onb3Secondary;

  /// No description provided for @onb4Title.
  ///
  /// In ar, this message translates to:
  /// **'حرّر التطبيق من موفّر البطارية'**
  String get onb4Title;

  /// No description provided for @onb4Body.
  ///
  /// In ar, this message translates to:
  /// **'أنظمة بعض الأجهزة تُغلق التطبيقات في الخلفية فتُلغى التذكيرات المجدولة. استثناء واحد يحل المشكلة نهائياً.'**
  String get onb4Body;

  /// No description provided for @onb4NoteLabel.
  ///
  /// In ar, this message translates to:
  /// **'خطوة واحدة'**
  String get onb4NoteLabel;

  /// No description provided for @onb4Note.
  ///
  /// In ar, this message translates to:
  /// **'سنفتح لك شاشة الإعدادات الصحيحة لجهازك، ثم ننتهي.'**
  String get onb4Note;

  /// No description provided for @onb4Primary.
  ///
  /// In ar, this message translates to:
  /// **'استثناء التطبيق'**
  String get onb4Primary;

  /// No description provided for @onb4Secondary.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get onb4Secondary;

  /// No description provided for @notifBody.
  ///
  /// In ar, this message translates to:
  /// **'{thikr} · {count} أذكار · {minutes} دقائق'**
  String notifBody(String thikr, String count, String minutes);

  /// No description provided for @scheduleThroughShort.
  ///
  /// In ar, this message translates to:
  /// **'مجدولة حتى {date}'**
  String scheduleThroughShort(String date);

  /// No description provided for @prayerFallbackNotice.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حساب المواقيت — تُستخدم الأوقات الثابتة مؤقتاً'**
  String get prayerFallbackNotice;

  /// No description provided for @notificationsBlocked.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات غير مسموحة — لن تصل التذكيرات'**
  String get notificationsBlocked;

  /// No description provided for @enableNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التنبيهات'**
  String get enableNotifications;

  /// No description provided for @notifTitleMorning.
  ///
  /// In ar, this message translates to:
  /// **'وقت أذكار الصباح'**
  String get notifTitleMorning;

  /// No description provided for @notifTitleEvening.
  ///
  /// In ar, this message translates to:
  /// **'وقت أذكار المساء'**
  String get notifTitleEvening;

  /// No description provided for @notifTitleSleep.
  ///
  /// In ar, this message translates to:
  /// **'وقت أذكار النوم'**
  String get notifTitleSleep;

  /// No description provided for @notifTitleWake.
  ///
  /// In ar, this message translates to:
  /// **'وقت أذكار الاستيقاظ'**
  String get notifTitleWake;

  /// No description provided for @notifActionStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get notifActionStart;

  /// No description provided for @notifActionSnooze.
  ///
  /// In ar, this message translates to:
  /// **'تأجيل ١٥ د'**
  String get notifActionSnooze;

  /// No description provided for @notifChannelName.
  ///
  /// In ar, this message translates to:
  /// **'تذكيرات الأذكار'**
  String get notifChannelName;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return LAr();
    case 'en':
      return LEn();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
