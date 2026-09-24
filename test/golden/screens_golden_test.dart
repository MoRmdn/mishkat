@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:mishkat/app.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/features/share/share_card.dart';

import '../support/app_harness.dart';
import 'font_loader.dart';

void main() {
  late AppHarness harness;

  setUpAll(() async {
    await loadAppFonts();
    await AppHarness.loadLibrary();
  });

  setUp(() => harness = AppHarness());

  testWidgets('home — light Arabic', (tester) async {
    await harness.pump(tester, appearance: 'light', language: 'ar');
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/home_light_ar.png'),
    );
  });

  testWidgets('home — dark English', (tester) async {
    await harness.pump(tester, appearance: 'dark', language: 'en');
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/home_dark_en.png'),
    );
  });

  testWidgets('reader — light Arabic', (tester) async {
    await harness.pump(tester, appearance: 'light', language: 'ar');
    await tester.tap(find.text('أذكار الصباح').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reader_light_ar.png'),
    );
  });

  testWidgets('reader — light English shows the meaning', (tester) async {
    await harness.pump(tester, appearance: 'light', language: 'en');
    await tester.tap(find.text('Morning').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reader_light_en.png'),
    );
  });

  testWidgets('reminders — fixed mode, Arabic', (tester) async {
    await harness.pump(tester, appearance: 'light', language: 'ar');
    await tester.tap(find.text('التذكيرات').last);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/reminders_fixed_ar.png'),
    );
  });

  testWidgets('reminders — exact alarms denied, dark English', (tester) async {
    final denied = AppHarness(
      permissions: FakePermissionService(exactAlarms: false),
    );
    await denied.pump(tester, appearance: 'dark', language: 'en');
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
    await h.pump(tester, appearance: 'light', language: 'ar');
    await tester.tap(find.text('التقدّم').last);
    await AppHarness.settleWithDatabase(tester);
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/progress_ar.png'),
    );
  });

  testWidgets('favourites — a saved thikr', (tester) async {
    final h = AppHarness();
    await h.db.addFavorite('mo2', DateTime(2026, 9, 7));
    await h.db.addFavorite('ev2', DateTime(2026, 9, 6));
    await h.pump(tester, appearance: 'light', language: 'ar');
    await tester.tap(find.text('المفضلة').last);
    await AppHarness.settleWithDatabase(tester);
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/favorites_ar.png'),
    );
  });

  testWidgets('onboarding — permission rationale, Arabic', (tester) async {
    await harness.pump(
      tester,
      appearance: 'light',
      language: 'ar',
      onboardingComplete: false,
    );
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/onboarding_ar.png'),
    );
  });

  testWidgets('settings sheet — dark Arabic', (tester) async {
    await harness.pump(tester, appearance: 'dark', language: 'ar');
    await tester.tap(findIcon(MIcon.settings));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MishkatApp),
      matchesGoldenFile('images/settings_dark_ar.png'),
    );
  });

  group('share card', () {
    // Board 3.5's own text, and the corpus's longest-style thikr for the
    // portrait case.
    const short =
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا '
        'عَبْدُكَ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي '
        'فَاغْفِرْ لِي';

    Future<void> pumpCard(
      WidgetTester tester,
      String text,
      ShareCardStyle style,
    ) async {
      tester.view.physicalSize = const Size(1080, 1600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            child: ShareCard(
              text: text,
              reference: 'رواه البخاري ٦٣٠٦',
              brandName: 'مشكاة',
              brandWird: 'الورد',
              language: TextDirection.rtl,
              style: style,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('aubergine, square', (tester) async {
      await pumpCard(tester, short, ShareCardStyle.aubergine);
      await expectLater(
        find.byType(ShareCard),
        matchesGoldenFile('images/share_aubergine_square.png'),
      );
    });

    testWidgets('stone, the longest thikr in the corpus', (tester) async {
      final longest = [
        for (final items in AppHarness.library.byCategory.values) ...items,
      ].reduce((a, b) => a.text.length >= b.text.length ? a : b);
      await pumpCard(tester, longest.text, ShareCardStyle.stone);
      await expectLater(
        find.byType(ShareCard),
        matchesGoldenFile('images/share_stone_longest.png'),
      );
    });
  });
}
