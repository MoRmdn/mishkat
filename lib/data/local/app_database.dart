import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Athkar the user has kept.
///
/// Removing one leaves a tombstone ([deletedAt] set) instead of deleting the
/// row, so the removal can reach the user's other devices through sync. Every
/// read the app makes filters tombstones out.
class Favorites extends Table {
  TextColumn get thikrId => text()();
  DateTimeColumn get addedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {thikrId};
}

/// One row per category completed per day.
///
/// The `(day, category)` pair is unique: finishing أذكار الصباح twice in a day
/// is one completion, not two, or the streak would be gameable.
class Completions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text()();

  /// Local calendar day as `YYYY-MM-DD`. Stored as text rather than derived
  /// from [completedAt] so day boundaries follow the user's timezone at the
  /// moment they finished, not the timezone they are in when it is read.
  TextColumn get day => text()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {day, category},
  ];
}

String dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// One durable snapshot per routine or favourite selection.
class ReaderCheckpoints extends Table {
  TextColumn get sessionKey => text()();
  TextColumn get snapshot => text()();

  @override
  Set<Column> get primaryKey => {sessionKey};
}

@DriftDatabase(tables: [Favorites, Completions, ReaderCheckpoints])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  /// In-memory database for tests.
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(readerCheckpoints);
      if (from < 3) await m.addColumn(favorites, favorites.deletedAt);
    },
  );

  Future<String?> readerCheckpoint(String key) async => (await (select(
    readerCheckpoints,
  )..where((r) => r.sessionKey.equals(key))).getSingleOrNull())?.snapshot;

  Future<void> saveReaderCheckpoint(String key, String snapshot) =>
      into(readerCheckpoints).insertOnConflictUpdate(
        ReaderCheckpointsCompanion.insert(sessionKey: key, snapshot: snapshot),
      );

  Future<void> deleteReaderCheckpoint(String key) =>
      (delete(readerCheckpoints)..where((r) => r.sessionKey.equals(key))).go();

  /// Completion and checkpoint removal either both commit or both survive
  /// for retry after a process interruption.
  ///
  /// Returns true when this recorded a new completion, as [recordCompletion].
  Future<bool> finishReading(String key, String? category, DateTime now) =>
      transaction(() async {
        final recorded =
            category != null && await recordCompletion(category, now);
        await deleteReaderCheckpoint(key);
        return recorded;
      });

  static QueryExecutor _open() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(
        File(p.join(dir.path, 'mishkat.sqlite')),
      );
    });
  }

  // ---- favourites ----

  Future<List<Favorite>> allFavorites() =>
      (select(favorites)
            ..where((f) => f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.desc(f.addedAt)]))
          .get();

  /// Every row, tombstones included. For sync only.
  Future<List<Favorite>> favoriteRows() => select(favorites).get();

  Future<Favorite?> favoriteRow(String thikrId) => (select(
    favorites,
  )..where((f) => f.thikrId.equals(thikrId))).getSingleOrNull();

  Future<void> addFavorite(String thikrId, DateTime now) =>
      into(favorites).insertOnConflictUpdate(
        FavoritesCompanion.insert(
          thikrId: thikrId,
          addedAt: now,
          deletedAt: const Value(null),
        ),
      );

  Future<bool> isFavorite(String thikrId) async {
    final row = await favoriteRow(thikrId);
    return row != null && row.deletedAt == null;
  }

  Future<void> removeFavorite(String thikrId, DateTime now) =>
      (update(favorites)..where((f) => f.thikrId.equals(thikrId))).write(
        FavoritesCompanion(deletedAt: Value(now)),
      );

  /// Writes a row exactly as another device left it. For sync only.
  Future<void> putFavoriteRow(
    String thikrId, {
    required DateTime addedAt,
    DateTime? deletedAt,
  }) => into(favorites).insertOnConflictUpdate(
    FavoritesCompanion.insert(
      thikrId: thikrId,
      addedAt: addedAt,
      deletedAt: Value(deletedAt),
    ),
  );

  // ---- completions ----

  /// Records a finished session. Returns false when that category was already
  /// completed today, so callers can tell a first completion from a repeat.
  ///
  /// Checked with an explicit read rather than the insert's return value,
  /// which reports a row id whether or not the conflicting insert was ignored.
  Future<bool> recordCompletion(String category, DateTime now) async {
    final key = dayKey(now);
    final existing =
        await (select(completions)
              ..where((c) => c.day.equals(key) & c.category.equals(category)))
            .getSingleOrNull();
    if (existing != null) return false;

    await into(completions).insert(
      CompletionsCompanion.insert(
        category: category,
        day: key,
        completedAt: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );
    return true;
  }

  Future<List<Completion>> completionsSince(DateTime from) => (select(
    completions,
  )..where((c) => c.completedAt.isBiggerOrEqualValue(from))).get();

  Future<List<Completion>> allCompletions() => select(completions).get();

  /// Adds a completion another device recorded, unless this device already
  /// has one for that day and category. For sync only.
  Future<void> putCompletion({
    required String category,
    required String day,
    required DateTime completedAt,
  }) => into(completions).insert(
    CompletionsCompanion.insert(
      category: category,
      day: day,
      completedAt: completedAt,
    ),
    mode: InsertMode.insertOrIgnore,
  );
}
