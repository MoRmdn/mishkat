import 'package:flutter/foundation.dart';

import '../local/app_database.dart';
import '../models/thikr.dart';

/// How many completions a week of a category is worth.
///
/// Most categories are once a day; أذكار بعد الصلاة is said after each of the
/// five prayers, so a full week is thirty-five.
int weeklyTarget(ThikrCategory category) =>
    category == ThikrCategory.afterPrayer ? 35 : 7;

@immutable
class CategoryProgress {
  const CategoryProgress({
    required this.category,
    required this.done,
    required this.target,
  });

  final ThikrCategory category;
  final int done, target;

  double get fraction => target == 0 ? 0 : (done / target).clamp(0.0, 1.0);
}

@immutable
class ProgressStats {
  const ProgressStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSessions,
    required this.last14Days,
    required this.byCategory,
  });

  final int currentStreak, longestStreak, totalSessions;

  /// Oldest first, one entry per day, true when something was completed.
  final List<bool> last14Days;

  final List<CategoryProgress> byCategory;

  static const empty = ProgressStats(
    currentStreak: 0,
    longestStreak: 0,
    totalSessions: 0,
    last14Days: [],
    byCategory: [],
  );
}

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

/// Consecutive days completed, counting back from today.
///
/// A streak that has not been added to *today* still counts, as long as
/// yesterday was completed — otherwise every morning would show the streak as
/// broken before the user has had a chance to read anything.
@visibleForTesting
int currentStreakFrom(Set<String> days, DateTime now) {
  var cursor = _startOfDay(now);
  if (!days.contains(dayKey(cursor))) {
    cursor = DateTime(now.year, now.month, now.day - 1);
    if (!days.contains(dayKey(cursor))) return 0;
  }

  var count = 0;
  while (days.contains(dayKey(cursor))) {
    count++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  return count;
}

@visibleForTesting
int longestStreakFrom(Set<String> days) {
  if (days.isEmpty) return 0;
  final sorted = days.toList()..sort();

  var longest = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    final previous = DateTime.parse(sorted[i - 1]);
    final current = DateTime.parse(sorted[i]);
    final consecutive =
        dayKey(DateTime(previous.year, previous.month, previous.day + 1)) ==
            sorted[i] &&
        current.isAfter(previous);
    run = consecutive ? run + 1 : 1;
    if (run > longest) longest = run;
  }
  return longest;
}

/// Derives every figure the progress tab shows from the raw completion rows.
ProgressStats computeStats(List<Completion> completions, DateTime now) {
  final days = completions.map((c) => c.day).toSet();
  final today = _startOfDay(now);

  final last14 = <bool>[
    for (var i = 13; i >= 0; i--)
      days.contains(dayKey(DateTime(now.year, now.month, now.day - i))),
  ];

  final weekStart = DateTime(now.year, now.month, now.day - 6);
  final weekly = <ThikrCategory, int>{};
  for (final c in completions) {
    final day = DateTime.parse(c.day);
    if (day.isBefore(weekStart) || day.isAfter(today)) continue;
    final category = ThikrCategory.values
        .where((v) => v.key == c.category)
        .firstOrNull;
    if (category == null) continue;
    weekly[category] = (weekly[category] ?? 0) + 1;
  }

  return ProgressStats(
    currentStreak: currentStreakFrom(days, now),
    longestStreak: longestStreakFrom(days),
    totalSessions: completions.length,
    last14Days: last14,
    byCategory: [
      for (final category in ThikrCategory.homeGrid)
        CategoryProgress(
          category: category,
          done: weekly[category] ?? 0,
          target: weeklyTarget(category),
        ),
    ],
  );
}
