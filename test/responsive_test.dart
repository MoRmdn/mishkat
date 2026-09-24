import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
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
  }) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final h = AppHarness(permissions: permissions);
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

    testWidgets('settings sheet fits — $name', (tester) async {
      await start(tester, v);
      await tester.tap(findIcon(MIcon.settings));
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
