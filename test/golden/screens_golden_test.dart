@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/app.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/core/clock.dart';
import 'package:mishkat/core/widgets/app_icons.dart';
import 'package:mishkat/data/repositories/athkar_repository.dart';
import 'package:mishkat/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'font_loader.dart';

class _NoopWakelock extends WakelockPlusPlatformInterface
    with MockPlatformInterfaceMixin {
  bool _on = false;

  @override
  Future<void> toggle({required bool enable}) async => _on = enable;

  @override
  Future<bool> get enabled async => _on;
}

late AthkarLibrary library;

Future<void> pumpApp(
  WidgetTester tester, {
  required String palette,
  required String appearance,
  required String language,
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

  SharedPreferences.setMockInitialValues({
    'flutter.settings.palette': palette,
    'flutter.settings.appearance': appearance,
    'flutter.settings.language': language,
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        athkarLibraryProvider.overrideWith((ref) => library),
        // Pinned so the reminder countdown and Hijri header do not drift the
        // golden files by the minute.
        clockProvider.overrideWithValue(() => DateTime(2026, 9, 7, 3, 18)),
      ],
      child: const MishkatApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
    library = await AthkarRepository().load();
  });

  setUp(() => wakelockPlusPlatformInstance = _NoopWakelock());

  testWidgets('home — teal light Arabic', (tester) async {
    await pumpApp(tester, palette: 'teal', appearance: 'light', language: 'ar');
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/home_teal_light_ar.png'),
    );
  });

  testWidgets('home — indigo dark English', (tester) async {
    await pumpApp(
      tester,
      palette: 'indigo',
      appearance: 'dark',
      language: 'en',
    );
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/home_indigo_dark_en.png'),
    );
  });

  testWidgets('home — olive light Arabic', (tester) async {
    await pumpApp(
      tester,
      palette: 'olive',
      appearance: 'light',
      language: 'ar',
    );
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/home_olive_light_ar.png'),
    );
  });

  testWidgets('reader — teal Arabic', (tester) async {
    await pumpApp(tester, palette: 'teal', appearance: 'light', language: 'ar');
    await tester.tap(find.text('أذكار الصباح').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reader_teal_ar.png'),
    );
  });

  testWidgets('reader — olive English shows the meaning', (tester) async {
    await pumpApp(
      tester,
      palette: 'olive',
      appearance: 'light',
      language: 'en',
    );
    await tester.tap(find.text('Morning').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reader_olive_en.png'),
    );
  });

  testWidgets('settings sheet — indigo dark Arabic', (tester) async {
    await pumpApp(
      tester,
      palette: 'indigo',
      appearance: 'dark',
      language: 'ar',
    );
    await tester.tap(find.byType(GearIcon));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/settings_indigo_dark_ar.png'),
    );
  });
}
