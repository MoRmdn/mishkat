import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  testWidgets('one hour reads as ساعة, not ١ ساعات', (tester) async {
    // Wake fires at 05:00; 04:00 leaves exactly one hour.
    await harness.pump(tester, now: DateTime(2026, 9, 7, 4, 0));

    expect(find.textContaining('بعد ساعة'), findsOneWidget);
    expect(find.textContaining('١ ساعات'), findsNothing);
  });

  testWidgets('two hours reads as ساعتين', (tester) async {
    await harness.pump(tester, now: DateTime(2026, 9, 7, 3, 0));
    expect(find.textContaining('بعد ساعتين'), findsOneWidget);
  });

  testWidgets('several hours takes the plural form', (tester) async {
    await harness.pump(tester, now: DateTime(2026, 9, 7, 1, 0));
    expect(find.textContaining('٤ ساعات'), findsOneWidget);
  });

  testWidgets('under an hour omits the hour clause entirely', (tester) async {
    await harness.pump(tester, now: DateTime(2026, 9, 7, 4, 30));
    final line = tester.widgetList(find.byType(Text)).length;
    expect(line, greaterThan(0));
    expect(find.textContaining('ساعة و'), findsNothing);
    expect(find.textContaining('بعد ٣٠ دقيقة'), findsOneWidget);
  });

  testWidgets('English pluralises too', (tester) async {
    await harness.pump(tester, language: 'en', now: DateTime(2026, 9, 7, 4, 0));
    expect(find.textContaining('in 1 hour'), findsOneWidget);
    expect(find.textContaining('1 hours'), findsNothing);
  });
}
