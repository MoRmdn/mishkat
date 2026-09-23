import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/clock.dart';
import 'package:mishkat/data/local/app_database.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/progress_providers.dart';
import 'package:mishkat/features/reader/reader_controller.dart';

Thikr _thikr(
  String id,
  int count, {
  ThikrCategory category = ThikrCategory.morning,
}) {
  return Thikr(
    id: id,
    category: category,
    text: 'نص',
    count: count,
    sourceId: 'muslim',
    reference: 1,
    meaningEn: 'meaning',
  );
}

/// Waits past the auto-advance delay.
Future<void> pastAutoAdvance() =>
    Future<void>.delayed(kAutoAdvanceDelay + const Duration(milliseconds: 60));

void main() {
  late ProviderContainer container;
  late AppDatabase db;
  final now = DateTime(2026, 9, 7, 6, 0);

  ReaderController controller() =>
      container.read(readerControllerProvider.notifier);
  AthkarState state() => container.read(readerControllerProvider);

  /// Completions and favourites live in the database now, so assertions read
  /// from there rather than from in-memory state.
  Future<Set<String>> completedCategories() async =>
      (await db.allCompletions()).map((c) => c.category).toSet();
  Future<Set<String>> favoriteIds() async =>
      (await db.allFavorites()).map((f) => f.thikrId).toSet();

  setUp(() {
    db = AppDatabase.memory();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('opening a session', () {
    test('starts at the first thikr with every count restored', () {
      final items = [_thikr('a', 3), _thikr('b', 1)];
      controller().open(ThikrCategory.morning, items);

      expect(state().session!.category, ThikrCategory.morning);
      expect(state().session!.index, 0);
      expect(state().session!.finished, isFalse);
      expect(state().remainingFor(items[0]), 3);
      expect(state().remainingFor(items[1]), 1);
    });

    test('reopening restores counts spent in a previous run', () {
      final items = [_thikr('a', 2)];
      controller().open(ThikrCategory.morning, items);
      controller().countOne(items);
      expect(state().remainingFor(items[0]), 1);

      controller().open(ThikrCategory.morning, items);
      expect(state().remainingFor(items[0]), 2);
      expect(state().session!.index, 0);
    });
  });

  group('counting', () {
    test('each tap removes one repetition', () {
      final items = [_thikr('a', 3)];
      controller().open(ThikrCategory.morning, items);

      controller().countOne(items);
      expect(state().remainingFor(items[0]), 2);
      controller().countOne(items);
      expect(state().remainingFor(items[0]), 1);
    });

    test('the count never goes below zero', () async {
      final items = [_thikr('a', 1), _thikr('b', 1)];
      controller().open(ThikrCategory.morning, items);

      controller().countOne(items);
      controller().countOne(items);
      expect(state().remainingFor(items[0]), 0);
    });

    test('reaching zero advances after the delay, not immediately', () async {
      final items = [_thikr('a', 1), _thikr('b', 5)];
      controller().open(ThikrCategory.morning, items);

      controller().countOne(items);
      // Still showing the completed thikr.
      expect(state().session!.index, 0);

      await pastAutoAdvance();
      expect(state().session!.index, 1);
    });

    test('a pending auto-advance is cancelled by a manual reset', () async {
      final items = [_thikr('a', 1), _thikr('b', 5)];
      controller().open(ThikrCategory.morning, items);

      controller().countOne(items);
      controller().resetCurrent(items);
      await pastAutoAdvance();

      expect(
        state().session!.index,
        0,
        reason: 'reset should cancel the advance',
      );
      expect(state().remainingFor(items[0]), 1);
    });

    test('counting does nothing once the session is finished', () async {
      final items = [_thikr('a', 1)];
      controller().open(ThikrCategory.morning, items);
      controller().countOne(items);
      await pastAutoAdvance();

      expect(state().session!.finished, isTrue);
      controller().countOne(items);
      expect(state().remainingFor(items[0]), 0);
    });
  });

  group('navigation', () {
    test('advancing past the last thikr finishes the session', () async {
      final items = [_thikr('a', 1)];
      controller().open(ThikrCategory.morning, items);

      controller().advance(items);
      expect(state().session!.finished, isTrue);
      await pumpEventQueue();
      expect(await completedCategories(), contains('morning'));
    });

    test('previous moves back but stops at the first', () {
      final items = [_thikr('a', 1), _thikr('b', 1)];
      controller().open(ThikrCategory.morning, items);
      controller().advance(items);
      expect(state().session!.index, 1);

      controller().previous();
      expect(state().session!.index, 0);
      controller().previous();
      expect(state().session!.index, 0);
    });

    test('reset restores only the current thikr', () {
      final items = [_thikr('a', 3), _thikr('b', 3)];
      controller().open(ThikrCategory.morning, items);
      controller().countOne(items);
      controller().advance(items);
      controller().countOne(items);

      controller().resetCurrent(items);
      expect(state().remainingFor(items[1]), 3);
      expect(
        state().remainingFor(items[0]),
        2,
        reason: 'earlier thikr untouched',
      );
    });
  });

  group('completion', () {
    test('the tasbih never marks a completed session', () async {
      final items = [_thikr('t', 1, category: ThikrCategory.tasbih)];
      controller().open(ThikrCategory.tasbih, items);
      controller().advance(items);

      expect(state().session!.finished, isTrue);
      await pumpEventQueue();
      expect(await completedCategories(), isEmpty);
    });

    test('completedCount reports fully counted athkar', () {
      final items = [_thikr('a', 1), _thikr('b', 2)];
      controller().open(ThikrCategory.morning, items);
      expect(controller().completedCount(items), 0);

      controller().countOne(items);
      expect(controller().completedCount(items), 1);
    });

    test('closing clears the session but keeps progress', () {
      final items = [_thikr('a', 3)];
      controller().open(ThikrCategory.morning, items);
      controller().countOne(items);
      controller().close();

      expect(state().session, isNull);
      expect(state().remainingFor(items[0]), 2);
    });
  });

  group('favorites', () {
    test('toggling adds then removes', () async {
      await controller().toggleFavorite('a');
      // The provider stream has to deliver before the toggle can invert.
      await pumpEventQueue();
      expect(await favoriteIds(), contains('a'));

      await controller().toggleFavorite('a');
      await pumpEventQueue();
      expect(await favoriteIds(), isEmpty);
    });

    test('a completed category is recorded once per day', () async {
      final items = [_thikr('a', 1)];
      controller().open(ThikrCategory.morning, items);
      controller().advance(items);
      await pumpEventQueue();

      controller().open(ThikrCategory.morning, items);
      controller().advance(items);
      await pumpEventQueue();

      expect(await db.allCompletions(), hasLength(1));
    });
  });

  test('an empty category cannot start a broken session', () {
    controller().open(ThikrCategory.misc, const []);
    controller().countOne(const []);
    expect(state().session!.index, 0);
  });
}
