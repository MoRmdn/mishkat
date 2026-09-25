import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/theme/mishkat_tokens.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  testWidgets('Arabic is the default and lays out RTL', (tester) async {
    await harness.pump(tester);

    expect(shellDirection(tester), TextDirection.rtl);
    expect(find.text('مِشْكَاة'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
  });

  testWidgets('a stored English preference opens the app LTR', (tester) async {
    await harness.pump(tester, language: 'en');

    expect(shellDirection(tester), TextDirection.ltr);
    expect(find.text('Mishkat'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a stored appearance drives the theme', (tester) async {
    await harness.pump(tester, appearance: 'dark');

    final tokens = tester.element(find.byType(Scaffold).first).tokens;
    expect(tokens.isDark, isTrue);
    expect(tokens.bg, MishkatTokens.dark.bg);
  });

  testWidgets('the settings sheet switches language live', (tester) async {
    await harness.pump(tester);
    expect(shellDirection(tester), TextDirection.rtl);

    await tester.tap(findIcon(MIcon.settings));
    await tester.pumpAndSettle();
    expect(find.text('الإعدادات'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // The whole app flips, not just the sheet.
    expect(shellDirection(tester), TextDirection.ltr);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('the settings sheet switches appearance live', (tester) async {
    await harness.pump(tester);
    expect(tester.element(find.byType(Scaffold).first).tokens.isDark, isFalse);

    await tester.tap(findIcon(MIcon.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('غامق'));
    await tester.pumpAndSettle();

    expect(tester.element(find.byType(Scaffold).first).tokens.isDark, isTrue);
  });

  testWidgets('settings survive a restart', (tester) async {
    await harness.pump(tester);
    await tester.tap(findIcon(MIcon.settings));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    // Settings is a page now: changes apply live and back returns to Home.
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(findIcon(MIcon.settings), findsOneWidget);

    // Cold launch again against the same backing store. resetPrefs: false is
    // the whole point — with a fresh store this would prove nothing.
    await harness.pump(tester, resetPrefs: false);

    expect(shellDirection(tester), TextDirection.ltr);
    expect(find.text('Mishkat'), findsOneWidget);
  });
}
