import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
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
      expect(find.text('لا توجد أذكار محفوظة بعد'), findsOneWidget);
      expect(
        find.text('اضغط على القلب أثناء القراءة لحفظ الذكر هنا.'),
        findsOneWidget,
      );
    });

    testWidgets('a thikr favourited in the reader appears in the tab', (
      tester,
    ) async {
      await harness.pump(tester);

      await tester.tap(find.text('أذكار المساء'));
      await tester.pumpAndSettle();
      expect(find.byType(ReaderScreen), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('favorite'));
      await AppHarness.settleWithDatabase(tester);

      await tester.tap(find.bySemanticsLabel('close'));
      await tester.pumpAndSettle();
      await openTab(tester, 'المفضلة');

      expect(find.text('لا توجد أذكار محفوظة بعد'), findsNothing);
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
      await tester.tap(findIcon(MIcon.heartFilled).first);
      await AppHarness.settleWithDatabase(tester);

      expect(find.text('لا توجد أذكار محفوظة بعد'), findsOneWidget);
      expect(await harness.db.allFavorites(), isEmpty);
    });

    testWidgets('favourites survive a restart', (tester) async {
      await harness.db.addFavorite('mo2', DateTime(2026, 9, 7));
      await harness.pump(tester);
      await openTab(tester, 'المفضلة');
      expect(find.text('لا توجد أذكار محفوظة بعد'), findsNothing);
    });
  });

  group('progress', () {
    testWidgets('an untouched app shows zeroes rather than fake numbers', (
      tester,
    ) async {
      await harness.pump(tester);
      await openTab(tester, 'التقدّم');

      expect(find.byType(ProgressTab), findsOneWidget);
      expect(find.text('تتابع مستمر'), findsOneWidget);
      expect(find.textContaining('أطول تتابع: ٠'), findsOneWidget);
    });

    testWidgets('finishing a session records a streak and a completion', (
      tester,
    ) async {
      await harness.pump(tester);

      // On waking is the shortest category: two athkar, once each. `.last` is
      // the grid card — the same name now also appears in the next-reminder
      // card, since waking is genuinely the next slot at the pinned clock.
      await tester.tap(find.text('أذكار الاستيقاظ').last);
      await tester.pumpAndSettle();

      for (var i = 0; i < 2; i++) {
        await tester.tap(find.byType(ReaderScreen));
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

      expect(find.textContaining('إجمالي الجلسات: ١'), findsOneWidget);
      expect(find.textContaining('أطول تتابع: ١'), findsOneWidget);
    });

    testWidgets('the home card marks a category completed today', (
      tester,
    ) async {
      await harness.db.recordCompletion('morning', DateTime(2026, 9, 7, 7));
      await harness.pump(tester);

      expect(find.text('أُكملت اليوم'), findsOneWidget);
    });

    testWidgets('the 14-day grid renders a cell per day', (tester) async {
      await harness.pump(tester);
      await openTab(tester, 'التقدّم');

      // Cells are numbered 1..14; the last one proves the grid is complete.
      // The scrollable must be named: the inner GridView creates a second one.
      await tester.scrollUntilVisible(
        find.text('١٤'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('١٤'), findsOneWidget);
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
      expect(find.text('ذِكْر'), findsOneWidget);
    });
  });
}
