import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/app.dart';
import 'package:mishkat/core/theme/app_theme.dart';
import 'package:mishkat/core/widgets/app_icons.dart';
import 'package:mishkat/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpApp(WidgetTester tester, Map<String, Object> prefs) async {
  // A phone-sized surface: the default 800×600 is too short for the settings
  // sheet, which silently pushes its lower controls out of hit-test range.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues(
    prefs.map((k, v) => MapEntry('flutter.$k', v)),
  );
  final instance = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(instance)],
      child: const MishkatApp(),
    ),
  );
  await tester.pumpAndSettle();
}

TextDirection shellDirection(WidgetTester tester) {
  return Directionality.of(tester.element(find.byType(Scaffold).first));
}

void main() {
  testWidgets('Arabic is the default and lays out RTL', (tester) async {
    await pumpApp(tester, {});

    expect(shellDirection(tester), TextDirection.rtl);
    expect(find.text('الأذكار'), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
  });

  testWidgets('a stored English preference opens the app LTR', (tester) async {
    await pumpApp(tester, {'settings.language': 'en'});

    expect(shellDirection(tester), TextDirection.ltr);
    expect(find.text('Athkar'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('a stored palette and appearance drive the theme', (tester) async {
    await pumpApp(tester, {
      'settings.palette': 'indigo',
      'settings.appearance': 'dark',
    });

    final tokens = tester.element(find.byType(Scaffold).first).tokens;
    expect(tokens.isDark, isTrue);
    expect(tokens.accent, const Color(0xFF5A8FB8));
  });

  testWidgets('the settings sheet switches language live', (tester) async {
    await pumpApp(tester, {});
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
    await pumpApp(tester, {});
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
    await pumpApp(tester, {});
    await tester.tap(find.byType(GearIcon));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Rebuild from the same backing store, as a cold launch would.
    final reloaded = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(reloaded)],
        child: const MishkatApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(shellDirection(tester), TextDirection.ltr);
    expect(find.text('Athkar'), findsOneWidget);
  });
}
