import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';

import 'golden/font_loader.dart';
import 'support/app_harness.dart';

/// Flutter's own accessibility guidelines, on the main screens in both
/// appearances: every tap target at least 48px, every tap target labelled,
/// and text contrast measured from the rendered pixels.
void main() {
  setUpAll(() async {
    await loadAppFonts();
    await AppHarness.loadLibrary();
  });

  Future<void> check(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final appearance in ['light', 'dark']) {
    group(appearance, () {
      Future<void> start(WidgetTester tester, {String lang = 'ar'}) async {
        final h = AppHarness();
        await h.db.recordCompletion('wake', DateTime(2026, 9, 7, 5, 5));
        await h.pump(
          tester,
          appearance: appearance,
          language: lang,
          now: DateTime(2026, 9, 7, 9, 41),
        );
      }

      testWidgets('home', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await check(tester);
        handle.dispose();
      });

      testWidgets('home in English', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester, lang: 'en');
        await check(tester);
        handle.dispose();
      });

      testWidgets('reader', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(find.text('ابدأ'));
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });

      testWidgets('reminders', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(find.text('التذكيرات').last);
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });

      testWidgets('settings sheet', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(findIcon(MIcon.settings));
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });

      testWidgets('progress', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(find.text('التقدّم').last);
        await AppHarness.settleWithDatabase(tester);
        await check(tester);
        handle.dispose();
      });
    });
  }
}
