@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/app.dart';
import 'package:mishkat/core/widgets/app_icons.dart';

import '../support/app_harness.dart';
import 'font_loader.dart';

void main() {
  late AppHarness harness;

  setUpAll(() async {
    await loadAppFonts();
    await AppHarness.loadLibrary();
  });

  setUp(() => harness = AppHarness());

  testWidgets('home — teal light Arabic', (tester) async {
    await harness.pump(
      tester,
      palette: 'teal',
      appearance: 'light',
      language: 'ar',
    );
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/home_teal_light_ar.png'),
    );
  });

  testWidgets('home — indigo dark English', (tester) async {
    await harness.pump(
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
    await harness.pump(
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
    await harness.pump(
      tester,
      palette: 'teal',
      appearance: 'light',
      language: 'ar',
    );
    await tester.tap(find.text('أذكار الصباح').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reader_teal_ar.png'),
    );
  });

  testWidgets('reader — olive English shows the meaning', (tester) async {
    await harness.pump(
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

  testWidgets('reminders — fixed mode, teal Arabic', (tester) async {
    await harness.pump(
      tester,
      palette: 'teal',
      appearance: 'light',
      language: 'ar',
    );
    await tester.tap(find.text('التذكيرات').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reminders_fixed_ar.png'),
    );
  });

  testWidgets('reminders — exact alarms denied, indigo dark English', (
    tester,
  ) async {
    final denied = AppHarness(
      permissions: FakePermissionService(exactAlarms: false),
    );
    await denied.pump(
      tester,
      palette: 'indigo',
      appearance: 'dark',
      language: 'en',
    );
    await tester.tap(find.text('Reminders').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reminders_inexact_dark_en.png'),
    );
  });

  testWidgets('reminders — prayer mode with computed times', (tester) async {
    final prayer = AppHarness();
    await prayer.pump(
      tester,
      palette: 'teal',
      appearance: 'light',
      language: 'ar',
      extraPrefs: {
        'reminders.mode': 'prayer',
        'prayer.useDeviceLocation': false,
        'prayer.manualCity': 'makkah',
      },
    );
    await tester.tap(find.text('التذكيرات').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('الفجر'), 200);
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reminders_prayer_ar.png'),
    );
  });

  testWidgets('progress — with a streak and history', (tester) async {
    final h = AppHarness();
    // Nine consecutive days, so the ring, the grid and the bars all have
    // something real to draw.
    for (var i = 0; i < 9; i++) {
      final day = DateTime(2026, 9, 7 - i, 7);
      await h.db.recordCompletion('morning', day);
      if (i.isEven) await h.db.recordCompletion('evening', day);
    }
    await h.pump(tester, palette: 'teal', appearance: 'light', language: 'ar');
    await tester.tap(find.text('التقدّم').last);
    await AppHarness.settleWithDatabase(tester);
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/progress_teal_ar.png'),
    );
  });

  testWidgets('favourites — a saved thikr', (tester) async {
    final h = AppHarness();
    await h.db.addFavorite('mo2', DateTime(2026, 9, 7));
    await h.db.addFavorite('ev2', DateTime(2026, 9, 6));
    await h.pump(tester, palette: 'olive', appearance: 'light', language: 'ar');
    await tester.tap(find.text('المفضلة').last);
    await AppHarness.settleWithDatabase(tester);
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/favorites_olive_ar.png'),
    );
  });

  testWidgets('onboarding — permission rationale, teal Arabic', (tester) async {
    await harness.pump(
      tester,
      palette: 'teal',
      appearance: 'light',
      language: 'ar',
      onboardingComplete: false,
    );
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/onboarding_teal_ar.png'),
    );
  });

  testWidgets('settings sheet — indigo dark Arabic', (tester) async {
    await harness.pump(
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
