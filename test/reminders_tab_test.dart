import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/segmented_control.dart';
import 'package:mishkat/core/widgets/surfaces.dart';
import 'package:mishkat/features/reminders/oem_sheet.dart';
import 'package:mishkat/features/reminders/reminders_tab.dart';
import 'package:mishkat/features/reminders/slot_time_sheet.dart';
import 'package:mishkat/features/shell/app_shell.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  Future<void> openReminders(WidgetTester tester) async {
    await tester.tap(find.text('التذكيرات').last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows the four slots with their default times', (tester) async {
    await harness.pump(tester);
    await openReminders(tester);

    expect(find.text('الاستيقاظ'), findsOneWidget);
    expect(find.text('٥:٠٠ ص'), findsOneWidget);
    expect(find.text('٦:٣٠ ص'), findsOneWidget);
    expect(find.text('٥:٣٠ م'), findsOneWidget);
    expect(find.text('١٠:٣٠ م'), findsOneWidget);
  });

  testWidgets('fixed mode says it never needs the app opened', (tester) async {
    await harness.pump(tester);
    await openReminders(tester);

    expect(
      find.textContaining('مجدولة يومياً — لا تحتاج فتح التطبيق'),
      findsOneWidget,
    );
  });

  testWidgets('toggling a slot reschedules', (tester) async {
    await harness.pump(tester);
    await openReminders(tester);
    final before = harness.notifications.applied.last.entries.length;

    // Sleep is off by default; turning it on adds a reminder. Targeted by
    // widget rather than semantics label, which the row's own text also carries.
    final sleepSwitch = find.byType(AppSwitch).at(3);
    await tester.scrollUntilVisible(sleepSwitch, 120);
    await tester.tap(sleepSwitch);
    await tester.pumpAndSettle();

    expect(harness.notifications.applied.last.entries, hasLength(before + 1));
  });

  testWidgets('the time sheet edits a slot and reschedules', (tester) async {
    await harness.pump(tester);
    await openReminders(tester);

    await tester.tap(find.text('٦:٣٠ ص'));
    await tester.pumpAndSettle();
    expect(find.byType(SlotTimeSheet), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('زيادة الدقائق'));
    await tester.pumpAndSettle();

    // Minutes step in fives.
    expect(find.text('٣٥'), findsOneWidget);

    await tester.tap(find.text('حفظ وإعادة الجدولة'));
    await tester.pumpAndSettle();
    expect(find.text('٦:٣٥ ص'), findsOneWidget);
  });

  testWidgets('hours wrap around midnight', (tester) async {
    await harness.pump(tester);
    await openReminders(tester);

    await tester.tap(find.text('١٠:٣٠ م')); // sleep, 22:30
    await tester.pumpAndSettle();

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.bySemanticsLabel('زيادة الساعة'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('حفظ وإعادة الجدولة'));
    await tester.pumpAndSettle();

    // 22:30 + 2h = 00:30, shown as 12:30 ص.
    expect(find.text('١٢:٣٠ ص'), findsOneWidget);
  });

  testWidgets('prayer mode locks the anchored slots', (tester) async {
    await harness.pump(tester);
    await openReminders(tester);

    await tester.tap(find.text('حسب الصلاة'));
    await tester.pumpAndSettle();

    // The three anchored slots have no clock time of their own to edit;
    // only sleep keeps a time chip.
    expect(find.byType(TimeChip), findsOneWidget);
    expect(find.textContaining('قبل الفجر بـ ١٥ د'), findsOneWidget);
    expect(find.textContaining('بعد العصر بـ ٤٥ د'), findsOneWidget);
    expect(find.text('١٠:٣٠ م'), findsOneWidget);
  });

  testWidgets('prayer mode without prayer times says so plainly', (
    tester,
  ) async {
    await harness.pump(tester);
    await openReminders(tester);
    await tester.tap(find.text('حسب الصلاة'));
    await tester.pumpAndSettle();

    // No position yet: the UI must not pretend to have prayer times.
    final notice = find.text(
      'تعذّر حساب المواقيت — تُستخدم الأوقات الثابتة مؤقتاً',
    );
    await tester.scrollUntilVisible(notice, 200);
    expect(notice, findsOneWidget);
  });

  testWidgets('denied exact alarms raise a persistent notice', (tester) async {
    harness = AppHarness(
      permissions: FakePermissionService(exactAlarms: false),
    );
    await harness.pump(tester);
    await openReminders(tester);

    final banner = find.textContaining(
      'التنبيهات الدقيقة غير مسموحة',
      findRichText: true,
    );
    expect(banner, findsOneWidget);
    // The inline «السماح» action is part of the banner's sentence.
    await tester.tap(banner);
    await tester.pumpAndSettle();

    expect(harness.permissions.exactAlarms, isTrue);
    expect(banner, findsNothing);
  });

  testWidgets('blocked notifications are called out above everything else', (
    tester,
  ) async {
    harness = AppHarness(
      permissions: FakePermissionService(notifications: false),
    );
    await harness.pump(tester);
    await openReminders(tester);

    expect(find.text('التنبيهات معطّلة'), findsOneWidget);
    // It takes the place of the exact-alarm notice rather than stacking.
    expect(
      find.textContaining('التنبيهات الدقيقة', findRichText: true),
      findsNothing,
    );
  });

  testWidgets('the OEM sheet names the device vendor', (tester) async {
    harness = AppHarness(
      permissions: FakePermissionService(
        batteryExempt: false,
        vendor: 'Xiaomi',
      ),
    );
    await harness.pump(tester);
    await openReminders(tester);

    await tester.scrollUntilVisible(find.text('التذكيرات لا تصل؟'), 200);
    await tester.tap(find.text('التذكيرات لا تصل؟'));
    await tester.pumpAndSettle();

    expect(find.byType(OemSheet), findsOneWidget);
    expect(find.text('إعدادات Xiaomi'), findsOneWidget);
    expect(find.text('التطبيق غير مستثنى حالياً'), findsOneWidget);

    await tester.tap(find.text('فتح إعدادات البطارية'));
    await tester.pumpAndSettle();
    expect(harness.permissions.batteryExempt, isTrue);
  });

  testWidgets('an unknown vendor still gets generic steps', (tester) async {
    harness = AppHarness(
      permissions: FakePermissionService(
        batteryExempt: false,
        vendor: 'Nothing',
      ),
    );
    await harness.pump(tester);
    await openReminders(tester);
    await tester.scrollUntilVisible(find.text('التذكيرات لا تصل؟'), 200);
    await tester.tap(find.text('التذكيرات لا تصل؟'));
    await tester.pumpAndSettle();

    expect(find.text('إعدادات Nothing'), findsOneWidget);
    expect(
      find.text('خطوات عامة — قد تختلف التسميات قليلاً بين الأجهزة'),
      findsOneWidget,
    );
  });

  testWidgets('reminder settings survive a restart', (tester) async {
    await harness.pump(tester);
    await openReminders(tester);
    await tester.tap(find.text('حسب الصلاة'));
    await tester.pumpAndSettle();

    await harness.pump(tester, resetPrefs: false);
    await openReminders(tester);

    // Still in prayer mode: only sleep has a clock time to edit.
    expect(find.byType(TimeChip), findsOneWidget);
  });

  testWidgets('the tab is reachable and titled', (tester) async {
    await harness.pump(tester);
    expect(find.byType(AppShell), findsOneWidget);
    await openReminders(tester);
    expect(find.byType(RemindersTab), findsOneWidget);
  });
}
