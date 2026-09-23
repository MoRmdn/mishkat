import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/data/local/app_database.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/progress_repository.dart';

Completion completion(String day, ThikrCategory category) => Completion(
  id: day.hashCode ^ category.key.hashCode,
  category: category.key,
  day: day,
  completedAt: DateTime.parse('$day 07:00:00'),
);

Set<String> daysBack(DateTime from, int count) => {
  for (var i = 0; i < count; i++)
    dayKey(DateTime(from.year, from.month, from.day - i)),
};

void main() {
  final now = DateTime(2026, 9, 7, 10, 0);

  group('current streak', () {
    test('counts consecutive days ending today', () {
      expect(currentStreakFrom(daysBack(now, 5), now), 5);
    });

    test('an unfinished today still counts a streak through yesterday', () {
      // Otherwise the streak would read as broken every morning, before the
      // user has had a chance to open the app.
      final days = daysBack(DateTime(2026, 9, 6), 4);
      expect(currentStreakFrom(days, now), 4);
    });

    test('a gap of one full day breaks it', () {
      final days = daysBack(DateTime(2026, 9, 5), 4);
      expect(currentStreakFrom(days, now), 0);
    });

    test('no completions at all is zero', () {
      expect(currentStreakFrom({}, now), 0);
    });

    test('only today is a streak of one', () {
      expect(currentStreakFrom({dayKey(now)}, now), 1);
    });

    test('older history does not extend a broken streak', () {
      final days = {...daysBack(now, 2), ...daysBack(DateTime(2026, 8, 1), 30)};
      expect(currentStreakFrom(days, now), 2);
    });

    test('spans a month boundary', () {
      final days = daysBack(DateTime(2026, 10, 2), 5);
      expect(currentStreakFrom(days, DateTime(2026, 10, 2, 9)), 5);
      expect(days, contains('2026-09-28'));
    });
  });

  group('longest streak', () {
    test('finds the longest run in the history', () {
      final days = {
        ...daysBack(DateTime(2026, 8, 10), 7),
        ...daysBack(DateTime(2026, 9, 7), 3),
      };
      expect(longestStreakFrom(days), 7);
    });

    test('is at least the current streak', () {
      final days = daysBack(now, 4);
      expect(longestStreakFrom(days), 4);
      expect(
        longestStreakFrom(days),
        greaterThanOrEqualTo(currentStreakFrom(days, now)),
      );
    });

    test('a single day is a streak of one', () {
      expect(longestStreakFrom({dayKey(now)}), 1);
    });

    test('empty history is zero', () {
      expect(longestStreakFrom({}), 0);
    });
  });

  group('stats', () {
    test('the 14-day grid is oldest first and marks the right days', () {
      final rows = [
        completion(dayKey(now), ThikrCategory.morning),
        completion(dayKey(DateTime(2026, 9, 5)), ThikrCategory.evening),
      ];
      final stats = computeStats(rows, now);

      expect(stats.last14Days, hasLength(14));
      expect(stats.last14Days.last, isTrue, reason: 'today');
      expect(stats.last14Days[11], isTrue, reason: 'two days ago');
      expect(stats.last14Days[12], isFalse, reason: 'yesterday');
    });

    test('total sessions counts every row, not every day', () {
      final rows = [
        completion(dayKey(now), ThikrCategory.morning),
        completion(dayKey(now), ThikrCategory.evening),
      ];
      final stats = computeStats(rows, now);
      expect(stats.totalSessions, 2);
      expect(stats.currentStreak, 1, reason: 'both are the same day');
    });

    test('weekly category counts only include the last seven days', () {
      final rows = [
        for (var i = 0; i < 10; i++)
          completion(
            dayKey(DateTime(now.year, now.month, now.day - i)),
            ThikrCategory.morning,
          ),
      ];
      final stats = computeStats(rows, now);
      final morning = stats.byCategory.firstWhere(
        (c) => c.category == ThikrCategory.morning,
      );

      expect(morning.done, 7);
      expect(morning.target, 7);
      expect(morning.fraction, 1.0);
    });

    test('after-prayer has a five-a-day target', () {
      expect(weeklyTarget(ThikrCategory.afterPrayer), 35);
      expect(weeklyTarget(ThikrCategory.morning), 7);

      final rows = [
        for (var i = 0; i < 7; i++)
          completion(
            dayKey(DateTime(now.year, now.month, now.day - i)),
            ThikrCategory.afterPrayer,
          ),
      ];
      final after = computeStats(
        rows,
        now,
      ).byCategory.firstWhere((c) => c.category == ThikrCategory.afterPrayer);
      expect(after.done, 7);
      expect(after.target, 35);
      expect(after.fraction, closeTo(0.2, 0.001));
    });

    test('an unknown category in storage is ignored, not fatal', () {
      final rows = [
        Completion(
          id: 1,
          category: 'not_a_category',
          day: dayKey(now),
          completedAt: now,
        ),
      ];
      expect(() => computeStats(rows, now), returnsNormally);
      expect(computeStats(rows, now).totalSessions, 1);
    });

    test('empty history produces zeroes rather than throwing', () {
      final stats = computeStats(const [], now);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.totalSessions, 0);
      expect(stats.last14Days.where((d) => d), isEmpty);
    });
  });

  group('the database', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.memory());
    tearDown(() => db.close());

    test('favourites round-trip', () async {
      await db.addFavorite('mo2', now);
      expect((await db.allFavorites()).map((f) => f.thikrId), ['mo2']);

      await db.removeFavorite('mo2');
      expect(await db.allFavorites(), isEmpty);
    });

    test('adding the same favourite twice keeps one row', () async {
      await db.addFavorite('mo2', now);
      await db.addFavorite('mo2', now.add(const Duration(minutes: 1)));
      expect(await db.allFavorites(), hasLength(1));
    });

    test('a category completed twice in a day counts once', () async {
      final first = await db.recordCompletion('morning', now);
      final second = await db.recordCompletion(
        'morning',
        now.add(const Duration(hours: 2)),
      );

      expect(first, isTrue);
      expect(second, isFalse, reason: 'the streak must not be gameable');
      expect(await db.allCompletions(), hasLength(1));
    });

    test('different categories on the same day are separate', () async {
      await db.recordCompletion('morning', now);
      await db.recordCompletion('evening', now);
      expect(await db.allCompletions(), hasLength(2));
    });

    test('the same category on different days are separate', () async {
      await db.recordCompletion('morning', now);
      await db.recordCompletion('morning', DateTime(2026, 9, 8, 7));
      expect(await db.allCompletions(), hasLength(2));
    });
  });
}
