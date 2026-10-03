import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  /// On waking is the shortest routine: two athkar, once each.
  Future<void> finishWaking(WidgetTester tester) async {
    await tester.tap(find.text('استيقاظ'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await tester.tapAt(const Offset(195, 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
    }
    await AppHarness.settleWithDatabase(tester);
    expect(find.text('العودة للرئيسية'), findsOneWidget);
  }

  testWidgets('a week-long streak asks for a review once, on the done screen', (
    tester,
  ) async {
    // Six days before the harness's pinned clock (7 Sep), so today makes 7.
    for (var d = 1; d <= 6; d++) {
      await harness.db.recordCompletion('wake', DateTime(2026, 9, 7 - d, 5));
    }
    await harness.pump(tester);

    await finishWaking(tester);
    expect(harness.reviewer.requests, 0, reason: 'the done screen shows first');
    await tester.pump(const Duration(seconds: 2));
    expect(harness.reviewer.requests, 1);

    await tester.tap(find.text('العودة للرئيسية'));
    await AppHarness.settleWithDatabase(tester);
    await finishWaking(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(harness.reviewer.requests, 1, reason: 'asked already');
  });

  testWidgets('a short streak never asks', (tester) async {
    await harness.pump(tester);
    await finishWaking(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(harness.reviewer.requests, 0);
  });
}
