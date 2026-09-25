@Tags(['golden'])
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/app.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/features/share/share_card.dart';

import '../support/app_harness.dart';
import 'font_loader.dart';

/// One golden per screen on the 2a design board, at the board's 340×720
/// frame and numbered to match it. Review the PNGs against
/// `assets/mishkat-2a-handoff/screens/` whenever they change.
void main() {
  const board = Size(340, 720);
  final today = DateTime(2026, 9, 7);

  setUpAll(() async {
    await loadAppFonts();
    await AppHarness.loadLibrary();
  });

  Future<void> shot(String name) => expectLater(
    find.byType(MishkatApp),
    matchesGoldenFile('images/$name.png'),
  );

  /// Nine consecutive days of every routine, ending yesterday — the board's
  /// "9-day streak" — plus whatever [todayDone] adds for today.
  Future<AppHarness> withHistory({
    List<String> todayDone = const [],
    int days = 9,
    FakePermissionService? permissions,
  }) async {
    final h = AppHarness(permissions: permissions);
    for (var i = 1; i <= days; i++) {
      final day = DateTime(today.year, today.month, today.day - i, 7);
      for (final c in ['wake', 'morning', 'evening', 'sleep']) {
        await h.db.recordCompletion(c, day);
      }
    }
    for (final c in todayDone) {
      await h.db.recordCompletion(c, DateTime(2026, 9, 7, 6));
    }
    return h;
  }

  /// Counts by tapping the page, well clear of any button.
  Future<void> countOnce(WidgetTester tester) async {
    await tester.tapAt(const Offset(170, 300));
    await tester.pump(const Duration(milliseconds: 20));
  }

  group('01 onboarding', () {
    testWidgets('1.1 welcome', (tester) async {
      await AppHarness().pump(tester, size: board, onboardingComplete: false);
      await shot('1_1_welcome_ar');
    });

    testWidgets('1.2 notifications', (tester) async {
      await AppHarness().pump(tester, size: board, onboardingComplete: false);
      await tester.tap(find.text('لنبدأ'));
      await tester.pumpAndSettle();
      await shot('1_2_notifications_ar');
    });

    testWidgets('1.4 battery', (tester) async {
      await AppHarness().pump(tester, size: board, onboardingComplete: false);
      await tester.tap(find.text('لنبدأ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ليس الآن'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('المتابعة بدون دقة'));
      await tester.pumpAndSettle();
      await shot('1_4_battery_ar');
    });
  });

  group('02 home', () {
    testWidgets('2.1 routine due, Arabic light', (tester) async {
      // Eight days plus today: the board's nine-day streak.
      final h = await withHistory(todayDone: ['wake'], days: 8);
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 9, 41));
      await shot('2_1_home_light_ar');
    });

    testWidgets('2.2 English dark', (tester) async {
      final h = await withHistory(todayDone: ['wake', 'morning'], days: 8);
      await h.pump(
        tester,
        size: board,
        language: 'en',
        appearance: 'dark',
        now: DateTime(2026, 9, 7, 17, 22),
      );
      await shot('2_2_home_dark_en');
    });

    testWidgets('2.3 all done, notifications off', (tester) async {
      final h = await withHistory(
        todayDone: ['wake', 'morning', 'evening', 'sleep'],
        permissions: FakePermissionService(notifications: false),
      );
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 22, 50));
      await shot('2_3_home_done_ar');
    });

    testWidgets('2.3b zero streak', (tester) async {
      await AppHarness().pump(
        tester,
        size: board,
        now: DateTime(2026, 9, 7, 9, 41),
      );
      await shot('2_3b_home_zero_streak_ar');
    });

    testWidgets('2.4 tasbih', (tester) async {
      await AppHarness().pump(tester, size: board);
      await tester.tap(find.text('السبحة'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 47; i++) {
        await countOnce(tester);
      }
      await tester.pumpAndSettle();
      await shot('2_4_tasbih_ar');
    });
  });

  group('03 reader', () {
    Future<void> next(WidgetTester tester, String label, int times) async {
      for (var i = 0; i < times; i++) {
        await tester.tap(find.bySemanticsLabel(label));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('3.1 Arabic light', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 9, 41));
      await tester.tap(find.text('ابدأ'));
      await AppHarness.settleWithDatabase(tester);
      await next(tester, 'التالي', 2);
      await countOnce(tester);
      await tester.pumpAndSettle();
      await shot('3_1_reader_light_ar');
    });

    testWidgets('3.2 long thikr, dark, large text scrolls', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(
        tester,
        size: board,
        appearance: 'dark',
        now: DateTime(2026, 9, 7, 9, 41),
        extraPrefs: {'settings.textSize': 2},
      );
      final longest = AppHarness.library.all.reduce(
        (a, b) => a.text.length >= b.text.length ? a : b,
      );
      final index = AppHarness.library[longest.category].indexOf(longest);
      await tester.tap(find.text(_bandLabel(longest.category)));
      await AppHarness.settleWithDatabase(tester);
      await next(tester, 'التالي', index);
      expect(find.text('مرّر للمتابعة'), findsOneWidget);
      await shot('3_2_reader_long_dark_ar');
    });

    testWidgets('3.3 English shows the meaning', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(
        tester,
        size: board,
        language: 'en',
        now: DateTime(2026, 9, 7, 9, 41),
      );
      await tester.tap(find.text('Begin'));
      await AppHarness.settleWithDatabase(tester);
      await next(tester, 'Next', 2);
      await countOnce(tester);
      await tester.pumpAndSettle();
      await shot('3_3_reader_light_en');
    });

    testWidgets('3.4 session complete', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 9, 41));
      await tester.tap(find.text('ابدأ'));
      await AppHarness.settleWithDatabase(tester);
      for (final thikr in AppHarness.library[ThikrCategory.morning]) {
        for (var i = 0; i < thikr.count; i++) {
          await countOnce(tester);
        }
        await tester.pump(const Duration(milliseconds: 600));
      }
      await AppHarness.settleWithDatabase(tester);
      await shot('3_4_complete_ar');
    });
  });

  group('04 reminders', () {
    testWidgets('4.1 fixed times, exact alarms denied', (tester) async {
      final h = AppHarness(
        permissions: FakePermissionService(exactAlarms: false),
      );
      await h.pump(tester, size: board);
      await tester.tap(find.text('التذكيرات').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('4_1_reminders_fixed_ar');
    });

    testWidgets('4.2 prayer mode, manual city', (tester) async {
      await AppHarness().pump(
        tester,
        size: board,
        extraPrefs: {
          'reminders.mode': 'prayer',
          'prayer.useDeviceLocation': false,
          'prayer.manualCity': 'makkah',
        },
      );
      await tester.tap(find.text('التذكيرات').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('4_2_reminders_prayer_ar');
    });

    testWidgets('4.3 time sheet', (tester) async {
      await AppHarness().pump(tester, size: board);
      await tester.tap(find.text('التذكيرات').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('٦:٣٠ ص'));
      await tester.pumpAndSettle();
      await shot('4_3_time_sheet_ar');
    });

    testWidgets('4.4 OEM sheet', (tester) async {
      final h = AppHarness(
        permissions: FakePermissionService(batteryExempt: false),
      );
      await h.pump(tester, size: board);
      await tester.tap(find.text('التذكيرات').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('التذكيرات لا تصل؟'), 200);
      await tester.tap(find.text('التذكيرات لا تصل؟'));
      await tester.pumpAndSettle();
      await shot('4_4_oem_sheet_ar');
    });
  });

  group('05 library and settings', () {
    testWidgets('5.1 favourites', (tester) async {
      final h = AppHarness();
      await h.db.addFavorite('mo2', DateTime(2026, 9, 7));
      await h.db.addFavorite('ev2', DateTime(2026, 9, 6));
      await h.pump(tester, size: board);
      await tester.tap(find.text('المفضلة').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('5_1_favorites_ar');
    });

    testWidgets('5.2 favourites, empty', (tester) async {
      await AppHarness().pump(tester, size: board);
      await tester.tap(find.text('المفضلة').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('5_2_favorites_empty_ar');
    });

    testWidgets('5.3 progress', (tester) async {
      // As on the board: nothing yet today (its cell is outlined), a run of
      // full days, one empty day and a couple of partial ones.
      final h = await withHistory(days: 7);
      await h.db.recordCompletion('morning', DateTime(2026, 8, 29, 7));
      await h.db.recordCompletion('morning', DateTime(2026, 8, 25, 7));
      for (final c in ['wake', 'morning', 'evening', 'sleep']) {
        for (final d in [24, 26, 27, 28]) {
          await h.db.recordCompletion(c, DateTime(2026, 8, d, 7));
        }
      }
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 10, 2));
      await tester.tap(find.text('التقدّم').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('5_3_progress_ar');
    });

    testWidgets('5.4 settings sheet, light', (tester) async {
      await AppHarness().pump(tester, size: board);
      await tester.tap(findIcon(MIcon.settings));
      await tester.pumpAndSettle();
      await shot('5_4_settings_light_ar');
    });

    testWidgets('5.4b settings sheet, dark', (tester) async {
      await AppHarness().pump(tester, size: board, appearance: 'dark');
      await tester.tap(findIcon(MIcon.settings));
      await tester.pumpAndSettle();
      await shot('5_4b_settings_dark_ar');
    });

    testWidgets('5.5 content failed to load', (tester) async {
      await AppHarness().pump(
        tester,
        size: board,
        libraryError: StateError('corrupt'),
      );
      await shot('5_5_error_ar');
    });
  });

  group('3.5 share card', () {
    // Board 3.5's own text.
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
              brandName: 'مِشْكَاةُ',
              brandWird: 'الوِرْدِ',
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
      final longest = AppHarness.library.all.reduce(
        (a, b) => a.text.length >= b.text.length ? a : b,
      );
      await pumpCard(tester, longest.text, ShareCardStyle.stone);
      await expectLater(
        find.byType(ShareCard),
        matchesGoldenFile('images/share_stone_longest.png'),
      );
    });
  });
}

/// The day-band label that opens [c]'s routine.
String _bandLabel(ThikrCategory c) => switch (c) {
  ThikrCategory.wake => 'استيقاظ',
  ThikrCategory.morning => 'صباح',
  ThikrCategory.evening => 'مساء',
  ThikrCategory.sleep => 'نوم',
  _ => throw ArgumentError('$c has no day-band column'),
};
