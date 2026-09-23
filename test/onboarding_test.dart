import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/features/onboarding/onboarding_screen.dart';
import 'package:mishkat/features/shell/app_shell.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() {
    harness = AppHarness(
      permissions: FakePermissionService(
        notifications: false,
        exactAlarms: false,
        batteryExempt: false,
      ),
    );
  });

  Future<void> start(WidgetTester tester) =>
      harness.pump(tester, onboardingComplete: false);

  testWidgets('a first launch opens onboarding, not the shell', (tester) async {
    await start(tester);

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
    expect(find.text('اذكر الله في وقته'), findsOneWidget);
  });

  testWidgets('a returning user goes straight to the shell', (tester) async {
    await harness.pump(tester);

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('the ladder asks for one thing per screen, in order', (
    tester,
  ) async {
    await start(tester);

    // 1 — the offline promise.
    expect(find.text('بدون حساب'), findsOneWidget);
    await tester.tap(find.text('لنبدأ'));
    await tester.pumpAndSettle();

    // 2 — notifications.
    expect(find.text('نحتاج إذن التنبيهات'), findsOneWidget);
    expect(harness.permissions.notifications, isFalse);
    await tester.tap(find.text('السماح بالتنبيهات'));
    await tester.pumpAndSettle();
    expect(harness.permissions.notifications, isTrue);

    // 3 — exact alarms.
    expect(find.text('وقت دقيق للتذكير'), findsOneWidget);
    await tester.tap(find.text('السماح'));
    await tester.pumpAndSettle();
    expect(harness.permissions.exactAlarms, isTrue);

    // 4 — battery exemption, then into the app.
    expect(find.text('حرّر التطبيق من موفّر البطارية'), findsOneWidget);
    await tester.tap(find.text('استثناء التطبيق'));
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
  });

  testWidgets('skipping setup lands on a working home with nothing granted', (
    tester,
  ) async {
    await start(tester);

    await tester.tap(find.text('تخطي التهيئة'));
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(harness.permissions.notifications, isFalse);
    // Reminders are off, so nothing should have been scheduled.
    expect(harness.notifications.applied, isEmpty);
  });

  testWidgets('declining a rung advances rather than blocking', (tester) async {
    await start(tester);
    await tester.tap(find.text('لنبدأ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ليس الآن'));
    await tester.pumpAndSettle();
    expect(find.text('وقت دقيق للتذكير'), findsOneWidget);
    expect(harness.permissions.notifications, isFalse);

    // "المتابعة بدون دقة" — carry on without exact alarms.
    await tester.tap(find.text('المتابعة بدون دقة'));
    await tester.pumpAndSettle();
    expect(find.text('حرّر التطبيق من موفّر البطارية'), findsOneWidget);
    expect(harness.permissions.exactAlarms, isFalse);

    await tester.tap(find.text('لاحقاً'));
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsOneWidget);
  });

  testWidgets('completing onboarding is remembered', (tester) async {
    await start(tester);
    await tester.tap(find.text('تخطي التهيئة'));
    await tester.pumpAndSettle();

    await harness.pump(tester, resetPrefs: false);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });
}
