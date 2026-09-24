import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/theme/mishkat_tokens.dart';
import 'package:mishkat/features/reader/reader_controller.dart';
import 'package:mishkat/features/reader/reader_screen.dart';
import 'package:mishkat/features/tasbih/tasbih_screen.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  /// Opens the evening routine from its day-band column.
  Future<void> openEvening(WidgetTester tester) async {
    await tester.tap(find.text('مساء'));
    await tester.pumpAndSettle();
  }

  testWidgets('opening a routine starts a reading session', (tester) async {
    await harness.pump(tester);
    await openEvening(tester);

    expect(find.byType(ReaderScreen), findsOneWidget);
    // Evening has four athkar; the first opens at position 1.
    expect(find.text('١ من ٤'), findsOneWidget);
    expect(harness.screenAwake, isTrue, reason: 'screen should stay awake');
  });

  testWidgets('tapping the page counts down and advances', (tester) async {
    await harness.pump(tester);
    await openEvening(tester);

    // First evening thikr is said once; the second three times.
    expect(find.text('مرة واحدة'), findsOneWidget);

    await tester.tapAt(const Offset(195, 400));
    await tester.pump();
    await tester.pump(kAutoAdvanceDelay + const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.text('٢ من ٤'), findsOneWidget);
    expect(find.text('٣'), findsOneWidget, reason: 'three repetitions left');
  });

  testWidgets('the counter announces what is left', (tester) async {
    await harness.pump(tester);
    await openEvening(tester);
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp('المتبقي ١ من ١')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('English shows the meaning under the Arabic', (tester) async {
    await harness.pump(tester, language: 'en');
    await tester.tap(find.text('Evening'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 4'), findsOneWidget);
    expect(
      find.textContaining('We have entered a new evening'),
      findsOneWidget,
    );
  });

  testWidgets('Arabic mode does not show the English meaning', (tester) async {
    await harness.pump(tester);
    await openEvening(tester);
    expect(find.textContaining('We have entered a new evening'), findsNothing);
  });

  testWidgets('the reader is dark in the dark appearance', (tester) async {
    await harness.pump(tester, appearance: 'dark');
    await openEvening(tester);
    final tokens = tester.element(find.byType(ReaderScreen)).tokens;
    expect(tokens.isDark, isTrue);
    expect(tokens.bg, MishkatTokens.dark.bg);
  });

  testWidgets('the reader is light in the light appearance', (tester) async {
    // Not forced dark any more: it follows the app like every screen.
    await harness.pump(tester, appearance: 'light');
    await openEvening(tester);
    final tokens = tester.element(find.byType(ReaderScreen)).tokens;
    expect(tokens.isDark, isFalse);
    expect(tokens.bg, MishkatTokens.light.bg);
  });

  testWidgets('text is set at the chosen size, never shrunk', (tester) async {
    await harness.pump(tester, extraPrefs: {'settings.textSize': 2});
    await openEvening(tester);
    final text = tester.widget<Text>(find.textContaining('أَمْسَيْنَا').first);
    expect(text.style!.fontSize, ThikrSize.large.px);
  });

  testWidgets('closing the reader releases the wakelock', (tester) async {
    await harness.pump(tester);
    await openEvening(tester);
    expect(harness.screenAwake, isTrue);

    await tester.tap(find.bySemanticsLabel('إغلاق'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsNothing);
    expect(harness.screenAwake, isFalse);
  });

  testWidgets('the tasbih counts up and its target resets the round', (
    tester,
  ) async {
    await harness.pump(tester);
    await tester.tap(find.text('السبحة'));
    await tester.pumpAndSettle();
    expect(find.byType(TasbihScreen), findsOneWidget);

    for (var i = 0; i < 35; i++) {
      await tester.tapAt(const Offset(195, 300));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    expect(find.text('٣٥'), findsOneWidget);
    expect(find.text('الدورة ١ · من ١٠٠'), findsOneWidget);

    await tester.tap(find.text('٣٣'));
    await tester.pumpAndSettle();
    // 35 counts at 33 a round: round two, two in.
    expect(find.text('الدورة ٢ · من ٣٣'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('تصفير'));
    await tester.pumpAndSettle();
    expect(find.text('٠'), findsOneWidget);
  });
}
