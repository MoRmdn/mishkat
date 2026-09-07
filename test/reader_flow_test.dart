import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/features/reader/reader_controller.dart';
import 'package:mishkat/features/reader/reader_screen.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  testWidgets('home lists the athkar categories and the tasbih', (
    tester,
  ) async {
    await harness.pump(tester);

    expect(find.text('التذكير القادم'), findsOneWidget);
    expect(find.text('أذكار الصباح'), findsWidgets);
    expect(find.text('أذكار المساء'), findsOneWidget);
    expect(find.text('أذكار بعد الصلاة'), findsOneWidget);

    // The tasbih card sits below the grid.
    await tester.scrollUntilVisible(find.text('السبحة'), 200);
    expect(find.text('السبحة'), findsOneWidget);
  });

  testWidgets('opening a category starts a reading session', (tester) async {
    await harness.pump(tester);

    await tester.tap(find.text('أذكار المساء'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    // Evening has four athkar; the first opens at position 1.
    expect(find.text('١ من ٤'), findsOneWidget);
    expect(harness.screenAwake, isTrue, reason: 'screen should stay awake');
  });

  testWidgets('tapping the reader counts down', (tester) async {
    await harness.pump(tester);
    await tester.tap(find.text('أذكار المساء'));
    await tester.pumpAndSettle();

    // First evening thikr is said once; the second three times.
    expect(find.text('١'), findsWidgets);

    await tester.tap(find.byType(ReaderScreen));
    await tester.pump();
    await tester.pump(kAutoAdvanceDelay + const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.text('٢ من ٤'), findsOneWidget);
    expect(
      find.text('٣'),
      findsWidgets,
      reason: 'second thikr is said 3 times',
    );
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

    await tester.tap(find.text('أذكار المساء'));
    await tester.pumpAndSettle();

    expect(find.textContaining('We have entered a new evening'), findsNothing);
  });

  testWidgets('closing the reader releases the wakelock', (tester) async {
    await harness.pump(tester);
    await tester.tap(find.text('أذكار المساء'));
    await tester.pumpAndSettle();
    expect(harness.screenAwake, isTrue);

    await tester.tap(find.bySemanticsLabel('close'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsNothing);
    expect(harness.screenAwake, isFalse);
  });
}
