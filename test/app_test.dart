import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/theme/app_theme.dart';
import 'package:mishkat/core/widgets/app_icons.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  testWidgets('Arabic is the default and lays out RTL', (tester) async {
    await harness.pump(tester);

    expect(shellDirection(tester), TextDirection.rtl);
    expect(find.text('الأذكار'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
  });

  testWidgets('a stored English preference opens the app LTR', (tester) async {
    await harness.pump(tester, language: 'en');

    expect(shellDirection(tester), TextDirection.ltr);
    expect(find.text('Athkar'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a stored palette and appearance drive the theme', (
    tester,
  ) async {
    await harness.pump(tester, palette: 'indigo', appearance: 'dark');

    final tokens = tester.element(find.byType(Scaffold).first).tokens;
    expect(tokens.isDark, isTrue);
    expect(tokens.accent, const Color(0xFF5A8FB8));
  });

  testWidgets('the settings sheet switches language live', (tester) async {
    await harness.pump(tester);
    expect(shellDirection(tester), TextDirection.rtl);

    await tester.tap(find.byType(GearIcon));
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // The whole app flips, not just the sheet.
    expect(shellDirection(tester), TextDirection.ltr);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('the settings sheet switches palette live', (tester) async {
    await harness.pump(tester);
    expect(
      tester.element(find.byType(Scaffold).first).tokens.accent,
      const Color(0xFF1C6B58),
    );

    await tester.tap(find.byType(GearIcon));
    await tester.pumpAndSettle();
    await tester.tap(find.text('زيتوني'));
    await tester.pumpAndSettle();

    expect(
      tester.element(find.byType(Scaffold).first).tokens.accent,
      const Color(0xFF6B7440),
    );
  });

  testWidgets('settings survive a restart', (tester) async {
    await harness.pump(tester);
    await tester.tap(find.byType(GearIcon));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Cold launch again against the same backing store. resetPrefs: false is
    // the whole point — with a fresh store this would prove nothing.
    await harness.pump(tester, resetPrefs: false);

    expect(shellDirection(tester), TextDirection.ltr);
    expect(find.text('Athkar'), findsOneWidget);
  });
}
