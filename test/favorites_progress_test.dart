import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/features/favorites/favorites_tab.dart';
import 'package:mishkat/features/progress/progress_tab.dart';
import 'package:mishkat/features/reader/reader_screen.dart';
import 'package:mishkat/features/share/share_card.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await AppHarness.settleWithDatabase(tester);
  }

  group('favourites', () {
    testWidgets('starts empty with an invitation, not a blank screen', (
      tester,
    ) async {
      await harness.pump(tester);
      await openTab(tester, 'المفضلة');

      expect(find.byType(FavoritesTab), findsOneWidget);
      expect(find.text('لا شيء محفوظ بعد'), findsOneWidget);
      expect(
        find.text('اضغط على القلب أثناء القراءة ليُحفظ الذكر هنا.'),
        findsOneWidget,
      );
    });

    testWidgets('a thikr favourited in the reader appears in the tab', (
      tester,
    ) async {
      await harness.pump(tester);

      await tester.tap(find.text('مساء'));
      await AppHarness.settleWithDatabase(tester);
      expect(find.byType(ReaderScreen), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('حفظ في المفضلة'));
      await AppHarness.settleWithDatabase(tester);

      await tester.tap(find.bySemanticsLabel('إغلاق'));
      await tester.pumpAndSettle();
      await openTab(tester, 'المفضلة');

      expect(find.text('لا شيء محفوظ بعد'), findsNothing);
      expect(find.textContaining('أَمْسَيْنَا'), findsOneWidget);
      // The card names the category it came from.
      expect(find.text('أذكار المساء'), findsWidgets);
    });

    testWidgets('unfavouriting from the tab removes it', (tester) async {
      await harness.db.addFavorite('mo2', DateTime(2026, 9, 7));
      await harness.pump(tester);
      await openTab(tester, 'المفضلة');

      expect(find.byType(FavoritesTab), findsOneWidget);
      // Targeted by widget: the favourites tab has exactly one heart per card.
      await tester.tap(find.bySemanticsLabel('إزالة من المفضلة'));
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('لا شيء محفوظ بعد'), findsOneWidget);
      expect(await harness.db.allFavorites(), isEmpty);
    });

    testWidgets('favourites survive a restart', (tester) async {
      await harness.db.addFavorite('mo2', DateTime(2026, 9, 7));
      await harness.pump(tester);
      await openTab(tester, 'المفضلة');
      expect(find.text('لا شيء محفوظ بعد'), findsNothing);
    });
  });

  group('progress', () {
    testWidgets('an untouched app shows zeroes rather than fake numbers', (
      tester,
    ) async {
      await harness.pump(tester);
      await openTab(tester, 'التقدّم');

      expect(find.byType(ProgressTab), findsOneWidget);
      expect(find.text('التتابع الحالي'), findsOneWidget);
      expect(find.text('٠ يوم'), findsOneWidget, reason: 'longest');
    });

    testWidgets('finishing a session records a streak and a completion', (
      tester,
    ) async {
      await harness.pump(tester);

      // On waking is the shortest category: two athkar, once each. `.last` is
      // the grid card — the same name now also appears in the next-reminder
      // card, since waking is genuinely the next slot at the pinned clock.
      await tester.tap(find.text('استيقاظ'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        await tester.tapAt(const Offset(195, 400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
      }

      expect(
        find.text('العودة للرئيسية'),
        findsOneWidget,
        reason: 'the session should have completed',
      );
      expect(await harness.db.allCompletions(), hasLength(1));

      await tester.tap(find.text('العودة للرئيسية'));
      await AppHarness.settleWithDatabase(tester);
      await openTab(tester, 'التقدّم');

      expect(find.text('يوم واحد'), findsOneWidget, reason: 'longest');
    });

    testWidgets('the day band ticks a routine completed today', (tester) async {
      await harness.db.recordCompletion('morning', DateTime(2026, 9, 7, 7));
      await harness.pump(tester, now: DateTime(2026, 9, 7, 9, 41));

      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp('أذكار الصباح.*تمّت')),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('the 14-day grid renders a cell per day', (tester) async {
      await harness.pump(tester);
      await openTab(tester, 'التقدّم');

      final grid = find.byType(GridView);
      expect(grid, findsOneWidget);
      expect(
        find.descendant(of: grid, matching: find.byType(Container)),
        findsNWidgets(14),
      );
    });
  });

  group('reading and sharing from new places', () {
    testWidgets('tapping a saved thikr opens just that thikr', (tester) async {
      await harness.db.addFavorite('mo2', DateTime(2026, 9, 7));
      await harness.pump(tester);
      await openTab(tester, 'المفضلة');

      await tester.tap(find.textContaining('اللَّهُمَّ أَنْتَ رَبِّي'));
      await tester.pumpAndSettle();

      expect(find.byType(ReaderScreen), findsOneWidget);
      expect(find.text('١ من ١'), findsOneWidget);
    });

    testWidgets('reading a single saved thikr records no routine', (
      tester,
    ) async {
      await harness.db.addFavorite('wa1', DateTime(2026, 9, 7));
      await harness.pump(tester);
      await openTab(tester, 'المفضلة');
      await tester.tap(find.byType(GestureDetector).hitTestable().first);
      await tester.pumpAndSettle();
      expect(find.byType(ReaderScreen), findsOneWidget);

      await tester.tapAt(const Offset(195, 400));
      await tester.pump(const Duration(milliseconds: 600));
      await AppHarness.settleWithDatabase(tester);

      // The one-thikr session did finish…
      expect(find.text('العودة للرئيسية'), findsOneWidget);
      // …but it was not the waking routine, so it counts for nothing.
      expect(await harness.db.allCompletions(), isEmpty);
    });

    testWidgets('the completion screen shares a thikr it asks for', (
      tester,
    ) async {
      await harness.pump(tester);
      await tester.tap(find.text('استيقاظ'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 2; i++) {
        await tester.tapAt(const Offset(195, 400));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pumpAndSettle();
      }
      expect(find.text('العودة للرئيسية'), findsOneWidget);

      await tester.tap(find.text('مشاركة كصورة'));
      await tester.pumpAndSettle();
      expect(find.text('اختر ذكراً للمشاركة'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector).hitTestable().last);
      await tester.pumpAndSettle();
      expect(find.byType(ShareSheet), findsOneWidget);
    });
  });

  group('sharing', () {
    testWidgets('long-pressing a favourite opens the share sheet', (
      tester,
    ) async {
      await harness.db.addFavorite('mo2', DateTime(2026, 9, 7));
      await harness.pump(tester);
      await openTab(tester, 'المفضلة');

      await tester.longPress(find.textContaining('اللَّهُمَّ أَنْتَ رَبِّي'));
      await tester.pumpAndSettle();

      expect(find.byType(ShareSheet), findsOneWidget);
      expect(find.byType(ShareCard), findsWidgets);
      expect(find.text('مشاركة الذكر'), findsOneWidget);
    });

    testWidgets('the card carries the reference with the text', (tester) async {
      await harness.db.addFavorite('mo2', DateTime(2026, 9, 7));
      await harness.pump(tester);
      await openTab(tester, 'المفضلة');
      await tester.longPress(find.textContaining('اللَّهُمَّ أَنْتَ رَبِّي'));
      await tester.pumpAndSettle();

      // A shared image without its تخريج would be worse than not sharing.
      expect(find.textContaining('رواه البخاري'), findsWidgets);
      // Branded with the wordmark from board 3.5.
      expect(
        find.textContaining('مِشْكَاةُ الوِرْدِ', findRichText: true),
        findsOneWidget,
      );
    });
  });
}
