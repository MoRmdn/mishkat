import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/clock.dart';
import 'package:mishkat/data/local/app_database.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/progress_providers.dart';
import 'package:mishkat/features/reader/reader_controller.dart';

Thikr thikr(String id, int count, {String text = 'نص'}) => Thikr(
  id: id,
  category: ThikrCategory.morning,
  text: text,
  count: count,
  sourceId: 'muslim',
  reference: 1,
  meaningEn: 'meaning',
);

void main() {
  late Directory directory;
  late AppDatabase db;
  late ProviderContainer container;
  final now = DateTime(2026, 9, 24);
  ReaderController reader() =>
      container.read(readerControllerProvider.notifier);
  AthkarState state() => container.read(readerControllerProvider);
  void connect() {
    db = AppDatabase(NativeDatabase(File('${directory.path}/test.sqlite')));
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
  }

  Future<void> relaunch() async {
    await reader().flush();
    container.dispose();
    await db.close();
    connect();
  }

  setUp(() {
    directory = Directory.systemTemp.createTempSync('mishkat-reader-');
    connect();
  });
  tearDown(() async {
    await reader().flush();
    container.dispose();
    await db.close();
    directory.deleteSync(recursive: true);
  });

  test(
    'reopening the database restores position and counts without close',
    () async {
      final items = [thikr('a', 3), thikr('b', 5)];
      await reader().open(ThikrCategory.morning, items);
      reader().countOne(items);
      reader().advance(items);
      reader().countOne(items);
      await relaunch();
      await reader().open(ThikrCategory.morning, items);
      expect(state().session!.index, 1);
      expect(state().remainingFor(items[0]), 2);
      expect(state().remainingFor(items[1]), 4);
    },
  );

  test(
    'closing and switching routines preserve independent checkpoints',
    () async {
      final morning = [thikr('a', 3)];
      final evening = [thikr('e', 5)];
      await reader().open(ThikrCategory.morning, morning);
      reader().countOne(morning);
      reader().close();
      await reader().open(ThikrCategory.evening, evening);
      reader().countOne(evening);
      await relaunch();
      await reader().open(ThikrCategory.morning, morning);
      expect(state().remainingFor(morning[0]), 2);
      await reader().open(ThikrCategory.evening, evening);
      expect(state().remainingFor(evening[0]), 4);
    },
  );

  test('favourite reading cannot overwrite or credit a full routine', () async {
    final items = [thikr('a', 3)];
    await reader().open(ThikrCategory.morning, items);
    reader().countOne(items);
    await reader().open(ThikrCategory.morning, items, subset: true);
    reader().advance(items);
    await reader().flush();
    expect(await db.allCompletions(), isEmpty);
    await relaunch();
    await reader().open(ThikrCategory.morning, items);
    expect(state().remainingFor(items[0]), 2);
  });

  test(
    'content updates do not replace the frozen session until restart',
    () async {
      final old = [thikr('a', 3, text: 'النص الأصلي')];
      await reader().open(ThikrCategory.morning, old);
      reader().countOne(old);
      await relaunch();
      final updated = [thikr('new', 7, text: 'نص جديد')];
      await reader().open(ThikrCategory.morning, updated);
      expect(state().session!.frozenItems!.single.text, 'النص الأصلي');
      expect(state().remaining['a'], 2);
      await reader().open(ThikrCategory.morning, updated, restart: true);
      expect(state().session!.frozenItems!.single.id, 'new');
      expect(state().remaining['new'], 7);
    },
  );

  test(
    'interruption during final auto-advance completes exactly once on resume',
    () async {
      final items = [thikr('a', 1)];
      await reader().open(ThikrCategory.morning, items);
      reader().countOne(items, advanceDelay: const Duration(hours: 1));
      await relaunch();
      expect(await db.allCompletions(), isEmpty);
      await reader().open(ThikrCategory.morning, items);
      expect(state().remaining['a'], 0);
      await Future<void>.delayed(
        kAutoAdvanceDelay + const Duration(milliseconds: 60),
      );
      await reader().flush();
      expect(await db.allCompletions(), hasLength(1));
      expect(await db.readerCheckpoint('routine:morning'), isNull);
      await relaunch();
      await reader().open(ThikrCategory.morning, items);
      expect(state().remaining['a'], 1);
      expect(state().session!.finished, isFalse);
      expect(await db.allCompletions(), hasLength(1));
    },
  );

  test('a manual reset cancels persisted auto-advance', () async {
    final items = [thikr('a', 1), thikr('b', 3)];
    await reader().open(ThikrCategory.morning, items);
    reader().countOne(items, advanceDelay: const Duration(hours: 1));
    reader().resetCurrent(items);
    await relaunch();
    await reader().open(ThikrCategory.morning, items);
    await Future<void>.delayed(
      kAutoAdvanceDelay + const Duration(milliseconds: 60),
    );
    expect(state().session!.index, 0);
    expect(state().remaining['a'], 1);
  });

  test(
    'corrupt checkpoints survive failed restore until explicit restart',
    () async {
      await db.saveReaderCheckpoint('routine:morning', '{broken');
      await expectLater(
        reader().open(ThikrCategory.morning, [thikr('a', 3)]),
        throwsFormatException,
      );
      expect(await db.readerCheckpoint('routine:morning'), '{broken');
      await reader().open(ThikrCategory.morning, [
        thikr('a', 3),
      ], restart: true);
      await reader().flush();
      expect(state().remaining['a'], 3);
      expect(await db.readerCheckpoint('routine:morning'), isNot('{broken'));
    },
  );

  test('schema 1 upgrades without losing favourites or completions', () async {
    final legacyFile = File('${directory.path}/legacy.sqlite');
    await reader().flush();
    container.dispose();
    await db.close();
    db = AppDatabase(
      NativeDatabase(
        legacyFile,
        setup: (raw) {
          raw.execute(
            'CREATE TABLE favorites (thikr_id TEXT NOT NULL PRIMARY KEY, added_at INTEGER NOT NULL)',
          );
          raw.execute(
            'CREATE TABLE completions (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, category TEXT NOT NULL, day TEXT NOT NULL, completed_at INTEGER NOT NULL, UNIQUE(day, category))',
          );
          raw.execute("INSERT INTO favorites VALUES ('a', 1)");
          raw.execute(
            "INSERT INTO completions (category, day, completed_at) VALUES ('morning', '2026-09-23', 1)",
          );
          raw.execute('PRAGMA user_version = 1');
        },
      ),
    );
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    {
      expect((await db.allFavorites()).single.thikrId, 'a');
      expect((await db.allCompletions()).single.day, '2026-09-23');
      await db.saveReaderCheckpoint('routine:morning', 'snapshot');
      expect(await db.readerCheckpoint('routine:morning'), 'snapshot');
    }
  });
}
