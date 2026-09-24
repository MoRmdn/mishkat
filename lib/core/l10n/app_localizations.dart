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
  /// **'مشكاة الورد'**
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

  /// No description provided for @schedFixed.
  ///
  /// In ar, this message translates to:
  /// **'مجدولة يومياً — لا تحتاج فتح التطبيق'**
  String get schedFixed;

  /// No description provided for @fixedMode.
  ///
  /// In ar, this message translates to:
  /// **'وقت ثابت'**
  String get fixedMode;

  /// No description provided for @prayerMode.
  ///
  /// In ar, this message translates to:
  /// **'حسب الصلاة'**
  String get prayerMode;

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
  /// **'قبل الفجر بـ ١٥ د'**
  String get slotPrayerWake;

  /// No description provided for @slotPrayerMorning.
  ///
  /// In ar, this message translates to:
  /// **'بعد الفجر بـ ٣٠ د'**
  String get slotPrayerMorning;

  /// No description provided for @slotPrayerEvening.
  ///
  /// In ar, this message translates to:
  /// **'بعد العصر بـ ٤٥ د'**
  String get slotPrayerEvening;

  /// No description provided for @slotPrayerSleep.
  ///
  /// In ar, this message translates to:
  /// **'وقت ثابت دائماً'**
  String get slotPrayerSleep;

  /// No description provided for @cityAuto.
  ///
  /// In ar, this message translates to:
  /// **'{city} · تلقائي'**
  String cityAuto(String city);

  /// No description provided for @cityManual.
  ///
  /// In ar, this message translates to:
  /// **'{city} · يدوي'**
  String cityManual(String city);

  /// No description provided for @locationPending.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد الموقع…'**
  String get locationPending;

  /// No description provided for @chooseCity.
  ///
  /// In ar, this message translates to:
  /// **'اختر المدينة'**
  String get chooseCity;

  /// No description provided for @useMyLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقع الجهاز'**
  String get useMyLocation;

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

  /// No description provided for @method.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get method;

  /// No description provided for @madhab.
  ///
  /// In ar, this message translates to:
  /// **'مذهب العصر'**
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

  /// No description provided for @oemBody.
  ///
  /// In ar, this message translates to:
  /// **'بعض الأجهزة توقف التطبيقات في الخلفية فتُلغى التذكيرات. اتبع الخطوات مرة واحدة.'**
  String get oemBody;

  /// No description provided for @oemHeading.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات {vendor}'**
  String oemHeading(String vendor);

  /// No description provided for @oemStep1.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات ← التطبيقات ← مشكاة'**
  String get oemStep1;

  /// No description provided for @oemStep2.
  ///
  /// In ar, this message translates to:
  /// **'فعّل «التشغيل التلقائي»'**
  String get oemStep2;

  /// No description provided for @oemStep3.
  ///
  /// In ar, this message translates to:
  /// **'موفّر البطارية ← «لا قيود»'**
  String get oemStep3;

  /// No description provided for @oemGenericHint.
  ///
  /// In ar, this message translates to:
  /// **'خطوات عامة — قد تختلف التسميات قليلاً بين الأجهزة'**
  String get oemGenericHint;

  /// No description provided for @openBattery.
  ///
  /// In ar, this message translates to:
  /// **'فتح إعدادات البطارية'**
  String get openBattery;

  /// No description provided for @batteryOn.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق مستثنى حالياً'**
  String get batteryOn;

  /// No description provided for @batteryOff.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق غير مستثنى حالياً'**
  String get batteryOff;

  /// No description provided for @favEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا شيء محفوظ بعد'**
  String get favEmptyTitle;

  /// No description provided for @favEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على القلب أثناء القراءة ليُحفظ الذكر هنا.'**
  String get favEmptyBody;

  /// No description provided for @currentStreak.
  ///
  /// In ar, this message translates to:
  /// **'التتابع الحالي'**
  String get currentStreak;

  /// No description provided for @longest.
  ///
  /// In ar, this message translates to:
  /// **'الأطول'**
  String get longest;

  /// No description provided for @totalSessions.
  ///
  /// In ar, this message translates to:
  /// **'الجلسات'**
  String get totalSessions;

  /// No description provided for @last14.
  ///
  /// In ar, this message translates to:
  /// **'آخر ١٤ يوماً'**
  String get last14;

  /// No description provided for @byCategory.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get byCategory;

  /// No description provided for @once.
  ///
  /// In ar, this message translates to:
  /// **'مرة واحدة'**
  String get once;

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

  /// No description provided for @fontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم نص الذكر'**
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
  /// **'تذكيرات لأذكار الصباح والمساء والنوم والاستيقاظ، تُجدول على جهازك وتعمل دون إنترنت. بلا حساب.'**
  String get onb1Body;

  /// No description provided for @onb1Primary.
  ///
  /// In ar, this message translates to:
  /// **'لنبدأ'**
  String get onb1Primary;

  /// No description provided for @onb1Secondary.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get onb1Secondary;

  /// No description provided for @onb2Title.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج إذن التنبيهات'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In ar, this message translates to:
  /// **'التذكيرات تُجدول على جهازك مباشرة، فلا بد من السماح بالتنبيهات — بدونها لن يصل أي تذكير.'**
  String get onb2Body;

  /// No description provided for @onb2Note.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك السماح لاحقاً من الإعدادات، لكن التذكيرات ستبقى معطّلة حتى ذلك الحين.'**
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
  /// **'ليصل التذكير في دقيقته، يحتاج التطبيق إذن «التنبيهات الدقيقة» من أندرويد.'**
  String get onb3Body;

  /// No description provided for @onb3Note.
  ///
  /// In ar, this message translates to:
  /// **'إن رفضت، يستمر التطبيق في العمل لكن قد يتأخر التذكير بضع دقائق — وسنوضح ذلك في التذكيرات.'**
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
  /// **'استثناء من موفّر البطارية'**
  String get onb4Title;

  /// No description provided for @onb4Body.
  ///
  /// In ar, this message translates to:
  /// **'بعض الأجهزة تُغلق التطبيقات في الخلفية فتُلغى التذكيرات. استثناء واحد يكفي.'**
  String get onb4Body;

  /// No description provided for @onb4Note.
  ///
  /// In ar, this message translates to:
  /// **'سنفتح الشاشة الصحيحة لجهازك.'**
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

  /// No description provided for @brandName.
  ///
  /// In ar, this message translates to:
  /// **'مشكاة'**
  String get brandName;

  /// No description provided for @brandWird.
  ///
  /// In ar, this message translates to:
  /// **'الورد'**
  String get brandWird;

  /// No description provided for @shareStyleAubergine.
  ///
  /// In ar, this message translates to:
  /// **'بنفسجي'**
  String get shareStyleAubergine;

  /// No description provided for @shareStyleStone.
  ///
  /// In ar, this message translates to:
  /// **'حجري'**
  String get shareStyleStone;

  /// No description provided for @nowLabel.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get nowLabel;

  /// No description provided for @nextLabel.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get nextLabel;

  /// No description provided for @begin.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get begin;

  /// No description provided for @editTimes.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الأوقات'**
  String get editTimes;

  /// No description provided for @athkarCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{ذكر واحد} =2{ذكران} few{{digits} أذكار} many{{digits} ذكراً} other{{digits} ذكر}}'**
  String athkarCountLabel(num count, String digits);

  /// No description provided for @aboutMinutes.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{نحو دقيقة} =2{نحو دقيقتين} few{نحو {digits} دقائق} other{نحو {digits} دقيقة}}'**
  String aboutMinutes(num count, String digits);

  /// No description provided for @streakDays.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{يوم واحد متتالٍ} =2{يومان متتاليان} few{{digits} أيام متتالية} many{{digits} يوماً متتالياً} other{{digits} يوم متتالٍ}}'**
  String streakDays(num count, String digits);

  /// No description provided for @streakStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ تتابعك اليوم'**
  String get streakStart;

  /// No description provided for @daysCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{يوم واحد} =2{يومان} few{{digits} أيام} many{{digits} يوماً} other{{digits} يوم}}'**
  String daysCount(num count, String digits);

  /// No description provided for @daysUnit.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{يوم} =2{يومان} few{أيام} many{يوماً} other{يوم}}'**
  String daysUnit(num count);

  /// No description provided for @bandWake.
  ///
  /// In ar, this message translates to:
  /// **'استيقاظ'**
  String get bandWake;

  /// No description provided for @bandMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح'**
  String get bandMorning;

  /// No description provided for @bandEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء'**
  String get bandEvening;

  /// No description provided for @bandSleep.
  ///
  /// In ar, this message translates to:
  /// **'نوم'**
  String get bandSleep;

  /// No description provided for @bandSemantics.
  ///
  /// In ar, this message translates to:
  /// **'{routine}، {time}، {state}'**
  String bandSemantics(String routine, String time, String state);

  /// No description provided for @stateDone.
  ///
  /// In ar, this message translates to:
  /// **'تمّت'**
  String get stateDone;

  /// No description provided for @stateNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get stateNow;

  /// No description provided for @stateLater.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get stateLater;

  /// No description provided for @allDoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'أتممت أذكار اليوم'**
  String get allDoneTitle;

  /// No description provided for @tomorrowAt.
  ///
  /// In ar, this message translates to:
  /// **'{routine} غداً {time}'**
  String tomorrowAt(String routine, String time);

  /// No description provided for @notifOffTitle.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات معطّلة'**
  String get notifOffTitle;

  /// No description provided for @notifOffBody.
  ///
  /// In ar, this message translates to:
  /// **'لن تصل أي تذكيرات حتى تسمح بها.'**
  String get notifOffBody;

  /// No description provided for @openSettings.
  ///
  /// In ar, this message translates to:
  /// **'فتح الإعدادات'**
  String get openSettings;

  /// No description provided for @remindersAllOff.
  ///
  /// In ar, this message translates to:
  /// **'كل التذكيرات متوقفة — الأوقات للعرض فقط'**
  String get remindersAllOff;

  /// No description provided for @libAfterPrayer.
  ///
  /// In ar, this message translates to:
  /// **'بعد الصلاة'**
  String get libAfterPrayer;

  /// No description provided for @libMisc.
  ///
  /// In ar, this message translates to:
  /// **'متفرقة'**
  String get libMisc;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @tasbihRound.
  ///
  /// In ar, this message translates to:
  /// **'الدورة {round} · من {target}'**
  String tasbihRound(String round, String target);

  /// No description provided for @tasbihFree.
  ///
  /// In ar, this message translates to:
  /// **'عدّ حر'**
  String get tasbihFree;

  /// No description provided for @tasbihNoLimit.
  ///
  /// In ar, this message translates to:
  /// **'بلا حد'**
  String get tasbihNoLimit;

  /// No description provided for @tasbihHint.
  ///
  /// In ar, this message translates to:
  /// **'المس أي مكان للعد · اهتزاز خفيف عند كل ٣٣'**
  String get tasbihHint;

  /// No description provided for @favoriteAdd.
  ///
  /// In ar, this message translates to:
  /// **'حفظ في المفضلة'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة من المفضلة'**
  String get favoriteRemove;

  /// No description provided for @scrollToContinue.
  ///
  /// In ar, this message translates to:
  /// **'مرّر للمتابعة'**
  String get scrollToContinue;

  /// No description provided for @counterOf.
  ///
  /// In ar, this message translates to:
  /// **'من {total}'**
  String counterOf(String total);

  /// No description provided for @counterRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي {remaining} من {total}'**
  String counterRemaining(String remaining, String total);

  /// No description provided for @positionOf.
  ///
  /// In ar, this message translates to:
  /// **'{index} من {total}'**
  String positionOf(String index, String total);

  /// No description provided for @doneRoutine.
  ///
  /// In ar, this message translates to:
  /// **'تمّت {routine}'**
  String doneRoutine(String routine);

  /// No description provided for @streakNow.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{ابدأ تتابعك اليوم.} =1{تتابعك الآن يوم واحد.} =2{تتابعك الآن يومان.} few{تتابعك الآن {digits} أيام.} many{تتابعك الآن {digits} يوماً.} other{تتابعك الآن {digits} يوم.}}'**
  String streakNow(num count, String digits);

  /// No description provided for @nextReminderLine.
  ///
  /// In ar, this message translates to:
  /// **'التذكير القادم {routine} {time}.'**
  String nextReminderLine(String routine, String time);

  /// No description provided for @shareChooseTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر ذكراً للمشاركة'**
  String get shareChooseTitle;

  /// No description provided for @exactBanner.
  ///
  /// In ar, this message translates to:
  /// **'قد تتأخر التذكيرات بضع دقائق — التنبيهات الدقيقة غير مسموحة.'**
  String get exactBanner;

  /// No description provided for @allow.
  ///
  /// In ar, this message translates to:
  /// **'السماح'**
  String get allow;

  /// No description provided for @slotDaily.
  ///
  /// In ar, this message translates to:
  /// **'يومياً'**
  String get slotDaily;

  /// No description provided for @pendingShort.
  ///
  /// In ar, this message translates to:
  /// **'{count} معلّقة'**
  String pendingShort(String count);

  /// No description provided for @windowShort.
  ///
  /// In ar, this message translates to:
  /// **'مجدولة حتى {date} · {pending} من {cap} معلّقة'**
  String windowShort(String date, String pending, String cap);

  /// No description provided for @timeSheetHint.
  ///
  /// In ar, this message translates to:
  /// **'يتكرر يومياً · خطوات ٥ دقائق'**
  String get timeSheetHint;

  /// No description provided for @favHint.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على الذكر لقراءته · اسحب لإزالته'**
  String get favHint;

  /// No description provided for @browseAthkar.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح الأذكار'**
  String get browseAthkar;

  /// No description provided for @legendFull.
  ///
  /// In ar, this message translates to:
  /// **'كامل'**
  String get legendFull;

  /// No description provided for @legendPartial.
  ///
  /// In ar, this message translates to:
  /// **'جزئي'**
  String get legendPartial;

  /// No description provided for @legendNone.
  ///
  /// In ar, this message translates to:
  /// **'لا شيء'**
  String get legendNone;

  /// No description provided for @weekRatio.
  ///
  /// In ar, this message translates to:
  /// **'{done} / {target}'**
  String weekRatio(String done, String target);

  /// No description provided for @errorTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الأذكار'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. تذكيراتك المجدولة لم تتأثر.'**
  String get errorBody;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @onb4NoteVendor.
  ///
  /// In ar, this message translates to:
  /// **'جهازك: {vendor} · سنفتح الشاشة الصحيحة'**
  String onb4NoteVendor(String vendor);

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @onbStep.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {index} من {total}'**
  String onbStep(String index, String total);

  /// No description provided for @slotWakeShort.
  ///
  /// In ar, this message translates to:
  /// **'الاستيقاظ'**
  String get slotWakeShort;

  /// No description provided for @slotMorningShort.
  ///
  /// In ar, this message translates to:
  /// **'الصباح'**
  String get slotMorningShort;

  /// No description provided for @slotEveningShort.
  ///
  /// In ar, this message translates to:
  /// **'المساء'**
  String get slotEveningShort;

  /// No description provided for @slotSleepShort.
  ///
  /// In ar, this message translates to:
  /// **'النوم'**
  String get slotSleepShort;

  /// No description provided for @hourUp.
  ///
  /// In ar, this message translates to:
  /// **'زيادة الساعة'**
  String get hourUp;

  /// No description provided for @hourDown.
  ///
  /// In ar, this message translates to:
  /// **'إنقاص الساعة'**
  String get hourDown;

  /// No description provided for @minuteUp.
  ///
  /// In ar, this message translates to:
  /// **'زيادة الدقائق'**
  String get minuteUp;

  /// No description provided for @minuteDown.
  ///
  /// In ar, this message translates to:
  /// **'إنقاص الدقائق'**
  String get minuteDown;

  /// No description provided for @timesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{مرة واحدة} =2{مرتان} few{{digits} مرات} other{{digits} مرة}}'**
  String timesCount(num count, String digits);

  /// No description provided for @textSmaller.
  ///
  /// In ar, this message translates to:
  /// **'تصغير نص الذكر'**
  String get textSmaller;

  /// No description provided for @textLarger.
  ///
  /// In ar, this message translates to:
  /// **'تكبير نص الذكر'**
  String get textLarger;
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
