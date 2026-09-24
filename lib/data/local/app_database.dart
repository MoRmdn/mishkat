import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

/// Athkar the user has kept.
class Favorites extends Table {
  TextColumn get thikrId => text()();
  DateTimeColumn get addedAt => dateTime()();

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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(readerCheckpoints);
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
  Future<void> finishReading(String key, String? category, DateTime now) =>
      transaction(() async {
        if (category != null) await recordCompletion(category, now);
        await deleteReaderCheckpoint(key);
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

  Stream<List<Favorite>> watchFavorites() => (select(
    favorites,
  )..orderBy([(f) => OrderingTerm.desc(f.addedAt)])).watch();

  Future<List<Favorite>> allFavorites() =>
      (select(favorites)..orderBy([(f) => OrderingTerm.desc(f.addedAt)])).get();

  Future<void> addFavorite(String thikrId, DateTime now) =>
      into(favorites).insertOnConflictUpdate(
        FavoritesCompanion.insert(thikrId: thikrId, addedAt: now),
      );

  Future<bool> isFavorite(String thikrId) async =>
      await (select(
        favorites,
      )..where((f) => f.thikrId.equals(thikrId))).getSingleOrNull() !=
      null;

  Future<void> removeFavorite(String thikrId) =>
      (delete(favorites)..where((f) => f.thikrId.equals(thikrId))).go();

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

  Stream<List<Completion>> watchCompletions() => select(completions).watch();
}
