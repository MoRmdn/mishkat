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
  /// **'مِشْكَاةُ الوِرْدِ'**
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
  /// **'الإعدادات ← التطبيقات ← مِشْكَاة'**
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

  /// No description provided for @brandShort.
  ///
  /// In ar, this message translates to:
  /// **'مِشْكَاة'**
  String get brandShort;

  /// No description provided for @brandName.
  ///
  /// In ar, this message translates to:
  /// **'مِشْكَاةُ'**
  String get brandName;

  /// No description provided for @brandWird.
  ///
  /// In ar, this message translates to:
  /// **'الوِرْدِ'**
  String get brandWird;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get termsOfUse;

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

  /// No description provided for @readerStartAgain.
  ///
  /// In ar, this message translates to:
  /// **'البدء من جديد'**
  String get readerStartAgain;

  /// No description provided for @readerRestartQuestion.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد بدء هذه الجلسة من جديد؟'**
  String get readerRestartQuestion;

  /// No description provided for @readerRestoreError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر استعادة القراءة المحفوظة. يمكنك الإغلاق أو البدء من جديد.'**
  String get readerRestoreError;

  /// No description provided for @readerSaveError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ التقدّم. أبقِ التطبيق مفتوحًا وحاول مجددًا.'**
  String get readerSaveError;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @settingsReading.
  ///
  /// In ar, this message translates to:
  /// **'القراءة'**
  String get settingsReading;

  /// No description provided for @settingsLanguageAppearance.
  ///
  /// In ar, this message translates to:
  /// **'اللغة والمظهر'**
  String get settingsLanguageAppearance;

  /// No description provided for @settingsSupport.
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get settingsSupport;

  /// No description provided for @versionLine.
  ///
  /// In ar, this message translates to:
  /// **'نور الذكر اليومي · الإصدار {version}'**
  String versionLine(String version);

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get account;

  /// No description provided for @accountCardTitle.
  ///
  /// In ar, this message translates to:
  /// **'احفظ تقدّمك على كل أجهزتك'**
  String get accountCardTitle;

  /// No description provided for @accountCardBody.
  ///
  /// In ar, this message translates to:
  /// **'اختياري · التطبيق يعمل كاملاً بدونه'**
  String get accountCardBody;

  /// No description provided for @signInShort.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get signInShort;

  /// No description provided for @syncedAgo.
  ///
  /// In ar, this message translates to:
  /// **'آخر مزامنة {ago}'**
  String syncedAgo(String ago);

  /// No description provided for @notSyncedYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم المزامنة بعد'**
  String get notSyncedYet;

  /// No description provided for @feedback.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات واقتراحات'**
  String get feedback;

  /// No description provided for @inbox.
  ///
  /// In ar, this message translates to:
  /// **'صندوق الوارد'**
  String get inbox;

  /// No description provided for @unreadReply.
  ///
  /// In ar, this message translates to:
  /// **'رد جديد'**
  String get unreadReply;

  /// No description provided for @withUnread.
  ///
  /// In ar, this message translates to:
  /// **'{label}، {state}'**
  String withUnread(String label, String state);

  /// No description provided for @unreadCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{واحدة غير مقروءة} =2{اثنتان غير مقروءتين} few{{digits} غير مقروءة} many{{digits} غير مقروءة} other{{digits} غير مقروءة}}'**
  String unreadCount(num count, String digits);

  /// No description provided for @signInTitle.
  ///
  /// In ar, this message translates to:
  /// **'احفظ وِردك على كل أجهزتك'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'الحساب اختياري، والتطبيق يعمل كاملاً بدونه.'**
  String get signInSubtitle;

  /// No description provided for @signInStreak.
  ///
  /// In ar, this message translates to:
  /// **'تتابعك وجلساتك'**
  String get signInStreak;

  /// No description provided for @signInStreakBody.
  ///
  /// In ar, this message translates to:
  /// **'لا تضيع عند تغيير الجهاز'**
  String get signInStreakBody;

  /// No description provided for @signInFavorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get signInFavorites;

  /// No description provided for @signInFavoritesBody.
  ///
  /// In ar, this message translates to:
  /// **'أذكارك المحفوظة معك على كل جهاز'**
  String get signInFavoritesBody;

  /// No description provided for @signInSettingsBody.
  ///
  /// In ar, this message translates to:
  /// **'أوقات التذكير والمظهر تنتقل معك'**
  String get signInSettingsBody;

  /// No description provided for @signInApple.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول باستخدام Apple'**
  String get signInApple;

  /// No description provided for @signInGoogle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول باستخدام Google'**
  String get signInGoogle;

  /// No description provided for @notNow.
  ///
  /// In ar, this message translates to:
  /// **'ليس الآن'**
  String get notNow;

  /// No description provided for @signInPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'نستخدم حسابك لمزامنة تقدّمك ومفضلتك وإعداداتك.'**
  String get signInPrivacy;

  /// No description provided for @signInFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تسجيل الدخول. حاول مرة أخرى.'**
  String get signInFailed;

  /// No description provided for @signedInToast.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول'**
  String get signedInToast;

  /// No description provided for @mergeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم ربط حسابك'**
  String get mergeTitle;

  /// No description provided for @mergeBody.
  ///
  /// In ar, this message translates to:
  /// **'دمجنا {items} من هذا الجهاز مع حسابك.'**
  String mergeBody(String items);

  /// No description provided for @mergeAnd.
  ///
  /// In ar, this message translates to:
  /// **'{a} و{b}'**
  String mergeAnd(String a, String b);

  /// No description provided for @mergeSettingsOnly.
  ///
  /// In ar, this message translates to:
  /// **'دمجنا إعداداتك من هذا الجهاز مع حسابك.'**
  String get mergeSettingsOnly;

  /// No description provided for @mergeSessions.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{جلسة واحدة} =2{جلستين} few{{digits} جلسات} many{{digits} جلسة} other{{digits} جلسة}}'**
  String mergeSessions(num count, String digits);

  /// No description provided for @mergeFavorites.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{ذكراً محفوظاً} =2{ذكرين محفوظين} few{{digits} أذكار محفوظة} many{{digits} ذكراً محفوظاً} other{{digits} ذكر محفوظ}}'**
  String mergeFavorites(num count, String digits);

  /// No description provided for @sessionsChip.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{جلسة واحدة} =2{جلستان} few{{digits} جلسات} many{{digits} جلسة} other{{digits} جلسة}}'**
  String sessionsChip(num count, String digits);

  /// No description provided for @favoritesChip.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{ذكر محفوظ} =2{ذكران محفوظان} few{{digits} أذكار محفوظة} many{{digits} ذكراً محفوظاً} other{{digits} ذكر محفوظ}}'**
  String favoritesChip(num count, String digits);

  /// No description provided for @currentStreakLine.
  ///
  /// In ar, this message translates to:
  /// **'تتابعك الحالي: {days}'**
  String currentStreakLine(String days);

  /// No description provided for @continueLabel.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueLabel;

  /// No description provided for @viaProvider.
  ///
  /// In ar, this message translates to:
  /// **'عبر {provider}'**
  String viaProvider(String provider);

  /// No description provided for @syncSynced.
  ///
  /// In ar, this message translates to:
  /// **'تمت المزامنة'**
  String get syncSynced;

  /// No description provided for @syncSyncing.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ المزامنة…'**
  String get syncSyncing;

  /// No description provided for @syncSyncingBody.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك متابعة القراءة'**
  String get syncSyncingBody;

  /// No description provided for @syncOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get syncOffline;

  /// No description provided for @syncOfflineBody.
  ///
  /// In ar, this message translates to:
  /// **'ستتم المزامنة عند الاتصال'**
  String get syncOfflineBody;

  /// No description provided for @syncError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّرت المزامنة'**
  String get syncError;

  /// No description provided for @syncErrorBody.
  ///
  /// In ar, this message translates to:
  /// **'بياناتك آمنة على هذا الجهاز'**
  String get syncErrorBody;

  /// No description provided for @syncNow.
  ///
  /// In ar, this message translates to:
  /// **'زامن الآن'**
  String get syncNow;

  /// No description provided for @signOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get signOut;

  /// No description provided for @signOutBody.
  ///
  /// In ar, this message translates to:
  /// **'تبقى بياناتك على هذا الجهاز'**
  String get signOutBody;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @deleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف حسابك؟'**
  String get deleteTitle;

  /// No description provided for @deleteSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا.'**
  String get deleteSubtitle;

  /// No description provided for @deleteRemovedHeading.
  ///
  /// In ar, this message translates to:
  /// **'يُحذف من حسابك'**
  String get deleteRemovedHeading;

  /// No description provided for @deleteItemProgress.
  ///
  /// In ar, this message translates to:
  /// **'التقدّم والتتابع المتزامن'**
  String get deleteItemProgress;

  /// No description provided for @deleteItemMessages.
  ///
  /// In ar, this message translates to:
  /// **'رسائلك مع فريق مشكاة'**
  String get deleteItemMessages;

  /// No description provided for @deleteKeptHeading.
  ///
  /// In ar, this message translates to:
  /// **'يبقى على هذا الجهاز'**
  String get deleteKeptHeading;

  /// No description provided for @deleteKeptBody.
  ///
  /// In ar, this message translates to:
  /// **'كل ما هو محفوظ هنا يبقى، وتستمر في استخدام التطبيق بدون حساب.'**
  String get deleteKeptBody;

  /// No description provided for @deleteConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب نهائياً'**
  String get deleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @deleteFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حذف الحساب. تحقق من الاتصال وحاول مرة أخرى.'**
  String get deleteFailed;

  /// No description provided for @deleteFailedTryLater.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حذف الحساب الآن. حاول مرة أخرى بعد قليل.'**
  String get deleteFailedTryLater;

  /// No description provided for @appleAccount.
  ///
  /// In ar, this message translates to:
  /// **'حساب Apple'**
  String get appleAccount;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'قيّم التطبيق'**
  String get rateApp;

  /// No description provided for @thikrSources.
  ///
  /// In ar, this message translates to:
  /// **'مصادر الأذكار'**
  String get thikrSources;

  /// No description provided for @sourcesIntro.
  ///
  /// In ar, this message translates to:
  /// **'نصوص الأذكار مأخوذة من كتب السنة التالية، وكل ذكر يذكر مصدره تحته.'**
  String get sourcesIntro;

  /// No description provided for @sourcesReview.
  ///
  /// In ar, this message translates to:
  /// **'التخريج قيد المراجعة من مختص قبل الإصدار. إن وجدت خطأً فأبلغنا من قائمة الذكر.'**
  String get sourcesReview;

  /// No description provided for @contentVersionLabel.
  ///
  /// In ar, this message translates to:
  /// **'إصدار المحتوى'**
  String get contentVersionLabel;

  /// No description provided for @accountDeletedToast.
  ///
  /// In ar, this message translates to:
  /// **'حُذف حسابك'**
  String get accountDeletedToast;

  /// No description provided for @nudgeTitle.
  ///
  /// In ar, this message translates to:
  /// **'احفظ تتابعك'**
  String get nudgeTitle;

  /// No description provided for @nudgeBody.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول ليبقى تتابعك محفوظاً إذا غيّرت جهازك.'**
  String get nudgeBody;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @dismiss.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء'**
  String get dismiss;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @reportThikr.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن خطأ في هذا الذكر'**
  String get reportThikr;

  /// No description provided for @copyText.
  ///
  /// In ar, this message translates to:
  /// **'نسخ النص'**
  String get copyText;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'نُسخ النص'**
  String get copied;

  /// No description provided for @feedbackIntro.
  ///
  /// In ar, this message translates to:
  /// **'نقرأ كل رسالة، ويصلك الرد في «ملاحظات واقتراحات».'**
  String get feedbackIntro;

  /// No description provided for @typeFeature.
  ///
  /// In ar, this message translates to:
  /// **'اقتراح ميزة'**
  String get typeFeature;

  /// No description provided for @typeThikr.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في ذكر'**
  String get typeThikr;

  /// No description provided for @typeBug.
  ///
  /// In ar, this message translates to:
  /// **'مشكلة في التطبيق'**
  String get typeBug;

  /// No description provided for @yourMessage.
  ///
  /// In ar, this message translates to:
  /// **'رسالتك'**
  String get yourMessage;

  /// No description provided for @messageHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالتك…'**
  String get messageHint;

  /// No description provided for @charCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} / {max}'**
  String charCount(String count, String max);

  /// No description provided for @replyEmail.
  ///
  /// In ar, this message translates to:
  /// **'بريدك للرد (اختياري)'**
  String get replyEmail;

  /// No description provided for @replyEmailNote.
  ///
  /// In ar, this message translates to:
  /// **'نرد داخل التطبيق، والبريد احتياطي فقط.'**
  String get replyEmailNote;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد غير صحيح'**
  String get invalidEmail;

  /// No description provided for @attachDevice.
  ///
  /// In ar, this message translates to:
  /// **'إرفاق معلومات الجهاز'**
  String get attachDevice;

  /// No description provided for @attachDeviceBody.
  ///
  /// In ar, this message translates to:
  /// **'إصدار التطبيق، النظام، اللغة'**
  String get attachDeviceBody;

  /// No description provided for @send.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get send;

  /// No description provided for @reportTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن خطأ في ذكر'**
  String get reportTitle;

  /// No description provided for @whatsWrong.
  ///
  /// In ar, this message translates to:
  /// **'ما الخطأ؟'**
  String get whatsWrong;

  /// No description provided for @issueText.
  ///
  /// In ar, this message translates to:
  /// **'النص'**
  String get issueText;

  /// No description provided for @issueSource.
  ///
  /// In ar, this message translates to:
  /// **'التخريج'**
  String get issueSource;

  /// No description provided for @issueCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد المرات'**
  String get issueCount;

  /// No description provided for @issueTranslation.
  ///
  /// In ar, this message translates to:
  /// **'الترجمة'**
  String get issueTranslation;

  /// No description provided for @details.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get details;

  /// No description provided for @sendReport.
  ///
  /// In ar, this message translates to:
  /// **'إرسال البلاغ'**
  String get sendReport;

  /// No description provided for @sentTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصلتنا رسالتك'**
  String get sentTitle;

  /// No description provided for @sentBody.
  ///
  /// In ar, this message translates to:
  /// **'ستجد الرد في «ملاحظات واقتراحات». ستظهر نقطة على الإعدادات عند وصوله.'**
  String get sentBody;

  /// No description provided for @viewMyMessages.
  ///
  /// In ar, this message translates to:
  /// **'عرض رسائلي'**
  String get viewMyMessages;

  /// No description provided for @queuedTitle.
  ///
  /// In ar, this message translates to:
  /// **'ستُرسل عند الاتصال'**
  String get queuedTitle;

  /// No description provided for @queuedBody.
  ///
  /// In ar, this message translates to:
  /// **'حفظناها على جهازك وسنرسلها تلقائياً.'**
  String get queuedBody;

  /// No description provided for @sendFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الإرسال'**
  String get sendFailedTitle;

  /// No description provided for @sendFailedBody.
  ///
  /// In ar, this message translates to:
  /// **'رسالتك محفوظة كمسودة.'**
  String get sendFailedBody;

  /// No description provided for @statusNew.
  ///
  /// In ar, this message translates to:
  /// **'جديدة'**
  String get statusNew;

  /// No description provided for @statusInReview.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get statusInReview;

  /// No description provided for @statusAnswered.
  ///
  /// In ar, this message translates to:
  /// **'تم الرد'**
  String get statusAnswered;

  /// No description provided for @statusClosed.
  ///
  /// In ar, this message translates to:
  /// **'مغلقة'**
  String get statusClosed;

  /// No description provided for @statusQueued.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار الاتصال'**
  String get statusQueued;

  /// No description provided for @repliesInAppOnly.
  ///
  /// In ar, this message translates to:
  /// **'الردود تظهر هنا فقط، ولا تصل كإشعارات.'**
  String get repliesInAppOnly;

  /// No description provided for @newMessage.
  ///
  /// In ar, this message translates to:
  /// **'رسالة جديدة'**
  String get newMessage;

  /// No description provided for @noMessagesTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا رسائل بعد'**
  String get noMessagesTitle;

  /// No description provided for @noMessagesBody.
  ///
  /// In ar, this message translates to:
  /// **'إذا أرسلت اقتراحاً أو أبلغت عن خطأ، ستجد الرد هنا.'**
  String get noMessagesBody;

  /// No description provided for @sendFeedback.
  ///
  /// In ar, this message translates to:
  /// **'أرسل ملاحظة'**
  String get sendFeedback;

  /// No description provided for @startedOn.
  ///
  /// In ar, this message translates to:
  /// **'بدأت {date}'**
  String startedOn(String date);

  /// No description provided for @mishkatTeam.
  ///
  /// In ar, this message translates to:
  /// **'فريق مشكاة'**
  String get mishkatTeam;

  /// No description provided for @writeReply.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رداً…'**
  String get writeReply;

  /// No description provided for @sendReply.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرد'**
  String get sendReply;

  /// No description provided for @closedOn.
  ///
  /// In ar, this message translates to:
  /// **'أُغلقت في {date}'**
  String closedOn(String date);

  /// No description provided for @threadClosedTitle.
  ///
  /// In ar, this message translates to:
  /// **'هذه المحادثة مغلقة'**
  String get threadClosedTitle;

  /// No description provided for @threadClosedBody.
  ///
  /// In ar, this message translates to:
  /// **'تحتاج مساعدة أخرى؟ ابدأ محادثة جديدة.'**
  String get threadClosedBody;

  /// No description provided for @filterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get filterAll;

  /// No description provided for @filterIdeas.
  ///
  /// In ar, this message translates to:
  /// **'اقتراحات'**
  String get filterIdeas;

  /// No description provided for @filterAthkar.
  ///
  /// In ar, this message translates to:
  /// **'أذكار'**
  String get filterAthkar;

  /// No description provided for @filterApp.
  ///
  /// In ar, this message translates to:
  /// **'مشكلات'**
  String get filterApp;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا جديد هنا'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'لا رسائل تطابق هذا الاختيار.'**
  String get inboxEmptyBody;

  /// No description provided for @clearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح التصفية'**
  String get clearFilters;

  /// No description provided for @messageNumber.
  ///
  /// In ar, this message translates to:
  /// **'رسالة #{number}'**
  String messageNumber(String number);

  /// No description provided for @messageUnnumbered.
  ///
  /// In ar, this message translates to:
  /// **'رسالة'**
  String get messageUnnumbered;

  /// No description provided for @metaType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get metaType;

  /// No description provided for @metaVersion.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get metaVersion;

  /// No description provided for @metaPlatform.
  ///
  /// In ar, this message translates to:
  /// **'المنصة'**
  String get metaPlatform;

  /// No description provided for @metaDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get metaDate;

  /// No description provided for @metaEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد'**
  String get metaEmail;

  /// No description provided for @notAttached.
  ///
  /// In ar, this message translates to:
  /// **'غير مرفق'**
  String get notAttached;

  /// No description provided for @openThikr.
  ///
  /// In ar, this message translates to:
  /// **'افتح الذكر'**
  String get openThikr;

  /// No description provided for @statusLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get statusLabel;

  /// No description provided for @theUser.
  ///
  /// In ar, this message translates to:
  /// **'المستخدم'**
  String get theUser;

  /// No description provided for @adminReplyNote.
  ///
  /// In ar, this message translates to:
  /// **'يظهر ردّك لدى المستخدم في «ملاحظات واقتراحات»، ويتحول الوضع إلى «تم الرد».'**
  String get adminReplyNote;

  /// No description provided for @writeReplyToUser.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رداً للمستخدم…'**
  String get writeReplyToUser;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{قبل دقيقة} =2{قبل دقيقتين} few{قبل {digits} دقائق} many{قبل {digits} دقيقة} other{قبل {digits} دقيقة}}'**
  String minutesAgo(num count, String digits);

  /// No description provided for @minutesAgoShort.
  ///
  /// In ar, this message translates to:
  /// **'قبل {digits} د'**
  String minutesAgoShort(String digits);

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{قبل ساعة} =2{قبل ساعتين} few{قبل {digits} ساعات} many{قبل {digits} ساعة} other{قبل {digits} ساعة}}'**
  String hoursAgo(num count, String digits);

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @justNow.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get justNow;
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
