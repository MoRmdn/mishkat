import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/features/reader/reader_screen.dart';
import 'package:mishkat/features/reminders/reminders_tab.dart';

import 'support/app_harness.dart';

/// Home's actions (boards 2.1–2.3) and its states, from real data.
void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  final morning941 = DateTime(2026, 9, 7, 9, 41);

  testWidgets('"Begin" opens the routine that is due now', (tester) async {
    await harness.db.recordCompletion('wake', DateTime(2026, 9, 7, 5, 10));
    await harness.pump(tester, now: morning941);

    expect(find.text('الآن'), findsOneWidget);
    expect(find.text('أذكار الصباح'), findsOneWidget);
    await tester.tap(find.text('ابدأ'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.text('أذكار الصباح'), findsOneWidget);
  });

  testWidgets('a day-band column opens its own routine', (tester) async {
    await harness.pump(tester, now: morning941);
    await tester.tap(find.text('نوم'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.text('أذكار النوم'), findsOneWidget);
  });

  testWidgets('"Edit times" opens Reminders', (tester) async {
    await harness.pump(tester, now: morning941);
    await tester.tap(find.text('تعديل الأوقات'));
    await tester.pumpAndSettle();

    expect(find.byType(RemindersTab), findsOneWidget);
    expect(find.text('وقت ثابت'), findsOneWidget);
  });

  testWidgets('the band shows the real slot times, not the board\'s', (
    tester,
  ) async {
    await harness.pump(
      tester,
      now: morning941,
      extraPrefs: {'reminders.slot.morning': '7:15:true'},
    );
    expect(find.text('٧:١٥'), findsOneWidget);
    expect(find.text('٦:٣٠'), findsNothing);
  });

  testWidgets('a zero streak invites rather than printing "· يوم"', (
    tester,
  ) async {
    await harness.pump(tester, now: morning941);
    expect(find.text('ابدأ تتابعك اليوم'), findsOneWidget);
    // The old chip printed a unit with no number.
    expect(find.textContaining('· يوم'), findsNothing);
    expect(find.textContaining(RegExp('^[٠0] ')), findsNothing);
  });

  testWidgets('a streak agrees in number', (tester) async {
    for (var i = 1; i <= 3; i++) {
      await harness.db.recordCompletion('morning', DateTime(2026, 9, 7 - i, 7));
    }
    await harness.pump(tester, now: morning941);
    expect(find.text('٣ أيام متتالية'), findsOneWidget);
  });

  testWidgets('with everything done it says so and names tomorrow', (
    tester,
  ) async {
    for (final c in ['wake', 'morning', 'evening', 'sleep']) {
      await harness.db.recordCompletion(c, DateTime(2026, 9, 7, 6));
    }
    await harness.pump(tester, now: DateTime(2026, 9, 7, 22, 50));

    expect(find.text('أتممت أذكار اليوم'), findsOneWidget);
    expect(find.text('أذكار الاستيقاظ غداً ٥:٠٠ ص'), findsOneWidget);
    expect(find.text('ابدأ'), findsNothing);
  });

  testWidgets('blocked notifications raise the banner on Home', (tester) async {
    harness = AppHarness(
      permissions: FakePermissionService(notifications: false),
    );
    await harness.pump(tester, now: morning941);
    expect(find.text('التنبيهات معطّلة'), findsOneWidget);

    await tester.tap(find.text('فتح الإعدادات'));
    await tester.pumpAndSettle();
    expect(harness.permissions.notifications, isTrue);
    expect(find.text('التنبيهات معطّلة'), findsNothing);
  });

  testWidgets('a load failure never shows the raw exception', (tester) async {
    await harness.pump(tester, libraryError: StateError('secret detail'));

    expect(find.text('تعذّر تحميل الأذكار'), findsOneWidget);
    expect(find.textContaining('secret detail'), findsNothing);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });
}
