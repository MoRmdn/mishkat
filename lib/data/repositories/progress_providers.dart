import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../local/app_database.dart';
import 'progress_repository.dart';

/// Overridden in tests with an in-memory database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// Futures rather than drift's watch() streams. Favourites and completions
// change only when the user acts, so a live query buys nothing — and an open
// drift subscription schedules a timer on cancellation that stalls the widget
// test binding. Writers call [invalidateProgress].

final favoritesProvider = FutureProvider<List<Favorite>>(
  (ref) => ref.watch(appDatabaseProvider).allFavorites(),
);

final favoriteIdsProvider = Provider<Set<String>>((ref) {
  final rows = ref.watch(favoritesProvider).value ?? const [];
  return rows.map((f) => f.thikrId).toSet();
});

final completionsProvider = FutureProvider<List<Completion>>(
  (ref) => ref.watch(appDatabaseProvider).allCompletions(),
);

/// Every figure the progress tab shows, derived from the raw rows.
final progressStatsProvider = Provider<ProgressStats>((ref) {
  final rows = ref.watch(completionsProvider).value;
  if (rows == null) return ProgressStats.empty;
  return computeStats(rows, ref.watch(clockProvider)());
});

/// The categories already completed today, used by the home grid.
final completedTodayProvider = Provider<Set<String>>((ref) {
  final rows = ref.watch(completionsProvider).value ?? const [];
  final today = dayKey(ref.watch(clockProvider)());
  return rows.where((c) => c.day == today).map((c) => c.category).toSet();
});

/// Re-reads everything derived from the database. Call after any write.
void invalidateProgress(Ref ref) {
  ref.invalidate(favoritesProvider);
  ref.invalidate(completionsProvider);
}
