import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/buttons.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/features/account/account_screen.dart';
import 'package:mishkat/features/account/sign_in_sheet.dart';
import 'package:mishkat/features/feedback/feedback_widgets.dart';
import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/feedback/feedback_models.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/features/reader/reader_screen.dart';
import 'package:mishkat/features/share/share_card.dart';

import 'golden/font_loader.dart';
import 'support/app_harness.dart';

/// Every main screen at the smallest supported phone (320×640) with text at
/// 200%, in both languages and both appearances. A RenderFlex overflow is
/// reported as a FlutterError, which fails the test with the offending
/// widget named — so this is the layout budget check.
///
/// Uses the real fonts: Arabic in the test fallback font has different
/// metrics and would prove nothing.
void main() {
  const small = Size(320, 640);

  setUpAll(() async {
    await loadAppFonts();
    await AppHarness.loadLibrary();
  });

  final variants = [
    for (final lang in ['ar', 'en'])
      for (final appearance in ['light', 'dark']) (lang, appearance),
  ];

  Future<void> start(
    WidgetTester tester,
    (String, String) v, {
    bool onboarding = true,
    Map<String, Object> prefs = const {},
    FakePermissionService? permissions,
    AppHarness? harness,
  }) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final h = harness ?? AppHarness(permissions: permissions);
    await h.db.recordCompletion('wake', DateTime(2026, 9, 7, 5, 5));
    await h.db.recordCompletion('morning', DateTime(2026, 9, 6, 7));
    await h.pump(
      tester,
      size: small,
      language: v.$1,
      appearance: v.$2,
      onboardingComplete: onboarding,
      now: DateTime(2026, 9, 7, 9, 41),
      extraPrefs: prefs,
    );
  }

  String tab(String lang, String ar, String en) => lang == 'ar' ? ar : en;

  for (final v in variants) {
    final name = '${v.$1} ${v.$2}';

    testWidgets('home and its banner fit — $name', (tester) async {
      await start(
        tester,
        v,
        permissions: FakePermissionService(notifications: false),
      );
    });

    testWidgets('the reader fits the longest thikr at large text — $name', (
      tester,
    ) async {
      await start(tester, v, prefs: {'settings.textSize': 2});
      final longest = AppHarness.library.all.reduce(
        (a, b) => a.text.length >= b.text.length ? a : b,
      );
      final column = find.text(_band(longest.category, english: v.$1 == 'en'));
      await tester.tap(column);
      await AppHarness.settleWithDatabase(tester);
      expect(find.byType(ReaderScreen), findsOneWidget);
      final index = AppHarness.library[longest.category].indexOf(longest);
      for (var i = 0; i < index; i++) {
        await tester.tap(find.bySemanticsLabel(tab(v.$1, 'التالي', 'Next')));
        await tester.pumpAndSettle();
      }
      expect(find.text(longest.text), findsOneWidget);
    });

    testWidgets('reminders in both modes fit — $name', (tester) async {
      await start(
        tester,
        v,
        permissions: FakePermissionService(exactAlarms: false),
        prefs: {
          'reminders.mode': 'prayer',
          'prayer.useDeviceLocation': false,
          'prayer.manualCity': 'makkah',
        },
      );
      await tester.tap(find.text(tab(v.$1, 'التذكيرات', 'Reminders')).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(tab(v.$1, 'وقت ثابت', 'Fixed time')));
      await tester.pumpAndSettle();
    });

    testWidgets('the time sheet fits — $name', (tester) async {
      await start(tester, v);
      await tester.tap(find.text(tab(v.$1, 'التذكيرات', 'Reminders')).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).hitTestable().at(0));
      await tester.pumpAndSettle();
      // Open the first time chip wherever the list puts it.
      final chip = find.textContaining(RegExp(r'[٥5]:[٠0][٠0]'));
      await tester.tap(chip.first);
      await tester.pumpAndSettle();
    });

    testWidgets('settings, sign-in and account fit — $name', (tester) async {
      await start(tester, v);
      await tester.tap(findIcon(MIcon.settings));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.byType(SmallPillButton));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(ProviderButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ProviderButton).first);
      await AppHarness.settleWithDatabase(tester);
      // The merge sheet: this device brought two completions.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AccountAvatar));
      await AppHarness.settleWithDatabase(tester);
      await tester.scrollUntilVisible(
        find.text(tab(v.$1, 'حذف الحساب', 'Delete account')),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text(tab(v.$1, 'حذف الحساب', 'Delete account')));
      await tester.pumpAndSettle();
    });

    testWidgets('about and the athkar sources page fit — $name', (tester) async {
      await start(tester, v);
      await tester.tap(findIcon(MIcon.settings));
      await AppHarness.settleWithDatabase(tester);
      final about = find.text(tab(v.$1, 'عن التطبيق', 'About'));
      await tester.scrollUntilVisible(
        about,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(about);
      await tester.pumpAndSettle();
      await tester.tap(about);
      await AppHarness.settleWithDatabase(tester);
      final row = find.text(tab(v.$1, 'مصادر الأذكار', 'Athkar sources'));
      await tester.scrollUntilVisible(
        row,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await AppHarness.settleWithDatabase(tester);
      await tester.scrollUntilVisible(
        find.text(v.$1 == 'ar' ? 'إصدار المحتوى' : 'Content version'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
    });

    testWidgets('feedback and the owner inbox fit — $name', (tester) async {
      final h = AppHarness(
        auth: FakeAuthService(
          initialUser: const AppUser(uid: 'me', isAnonymous: false),
        ),
      );
      h.feedback
        ..admins.add('me')
        ..seed(
          FeedbackThread(
            id: 't1',
            uid: 'me',
            type: FeedbackType.thikr,
            status: FeedbackStatus.inReview,
            preview: 'التشكيل في «يَضُرُّ» يختلف عن النسخة المطبوعة لديّ',
            createdAt: DateTime(2026, 9, 6),
            updatedAt: DateTime(2026, 9, 6),
            unreadForUser: true,
            unreadForAdmin: true,
            thikrId: AppHarness.library.all.first.id,
            issues: const {ThikrIssue.text, ThikrIssue.count},
            contactEmail: 'someone.with.a.long.address@example.com',
            device: const DeviceDetails(
              appVersion: '1.2.0 (34)',
              platform: 'Android 14 · Pixel 7 Pro',
              language: 'ar',
            ),
          ),
          messages: [
            FeedbackMessage(
              id: 'a',
              from: MessageAuthor.user,
              body:
                  'التشكيل في «يَضُرُّ» يختلف عن نسخة حصن المسلم المطبوعة لديّ.',
              createdAt: DateTime(2026, 9, 6, 9, 36),
            ),
            FeedbackMessage(
              id: 'b',
              from: MessageAuthor.admin,
              body: 'Thanks — we checked the source and will add a note.',
              createdAt: DateTime(2026, 9, 6, 10, 5),
            ),
          ],
        );
      await start(tester, v, harness: h);
      await tester.tap(findIcon(MIcon.settings));
      await AppHarness.settleWithDatabase(tester);

      final feedback = find.text(tab(v.$1, 'ملاحظات واقتراحات', 'Feedback'));
      await tester.scrollUntilVisible(
        feedback,
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(feedback);
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.byType(ThreadRow).first);
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.bySemanticsLabel(tab(v.$1, 'رجوع', 'Back')).last);
      await AppHarness.settleWithDatabase(tester);

      await tester.tap(find.byType(PrimaryButton).last);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(tab(v.$1, 'رجوع', 'Back')).last);
      await AppHarness.settleWithDatabase(tester);

      final inbox = find.text(tab(v.$1, 'صندوق الوارد', 'Inbox'));
      await tester.scrollUntilVisible(
        inbox,
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(inbox);
      await tester.pumpAndSettle();
      await tester.tap(inbox);
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.byType(ThreadRow).first);
      await AppHarness.settleWithDatabase(tester);
    });

    testWidgets('the reader menu and a thikr report fit — $name', (
      tester,
    ) async {
      await start(tester, v);
      await tester.tap(find.text(tab(v.$1, 'صباح', 'Morning')).first);
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.bySemanticsLabel(tab(v.$1, 'المزيد', 'More')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(
          tab(
            v.$1,
            'الإبلاغ عن خطأ في هذا الذكر',
            'Report a problem with this thikr',
          ),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('progress and favourites fit — $name', (tester) async {
      await start(tester, v);
      await tester.tap(find.text(tab(v.$1, 'التقدّم', 'Progress')).last);
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text(tab(v.$1, 'المفضلة', 'Saved')).last);
      await AppHarness.settleWithDatabase(tester);
    });

    testWidgets('the OEM and share sheets fit — $name', (tester) async {
      await start(
        tester,
        v,
        permissions: FakePermissionService(batteryExempt: false),
      );
      await tester.tap(find.text(tab(v.$1, 'التذكيرات', 'Reminders')).last);
      await tester.pumpAndSettle();
      final oem = find.text(
        tab(v.$1, 'التذكيرات لا تصل؟', 'Reminders not arriving?'),
      );
      await tester.scrollUntilVisible(oem, 200);
      await tester.tap(oem);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(160, 20)); // dismiss
      await tester.pumpAndSettle();

      await tester.tap(find.text(tab(v.$1, 'الرئيسية', 'Home')).last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(_band(ThikrCategory.evening, english: v.$1 == 'en')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(tab(v.$1, 'مشاركة', 'Share')));
      await tester.pumpAndSettle();
      expect(find.byType(ShareSheet), findsOneWidget);
    });

    testWidgets('onboarding fits — $name', (tester) async {
      await start(tester, v, onboarding: false);
      await tester.tap(find.text(tab(v.$1, 'لنبدأ', 'Get started')));
      await tester.pumpAndSettle();
    });

    testWidgets('the tasbih fits — $name', (tester) async {
      await start(tester, v);
      final tasbih = find.text(tab(v.$1, 'السبحة', 'Tasbih'));
      await tester.scrollUntilVisible(tasbih, 200);
      await tester.tap(tasbih);
      await tester.pumpAndSettle();
    });
  }
}

/// The day-band label that opens [c].
String _band(ThikrCategory c, {required bool english}) => switch (c) {
  ThikrCategory.wake => english ? 'Waking' : 'استيقاظ',
  ThikrCategory.morning => english ? 'Morning' : 'صباح',
  ThikrCategory.evening => english ? 'Evening' : 'مساء',
  ThikrCategory.sleep => english ? 'Sleep' : 'نوم',
  _ => throw ArgumentError('$c has no day-band column'),
};
