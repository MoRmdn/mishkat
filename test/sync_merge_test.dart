import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/services/sync/merge.dart';
import 'package:mishkat/services/sync/sync_models.dart';

SyncCompletion done(String day, String category, [int hour = 6]) =>
    SyncCompletion(
      category: category,
      day: day,
      completedAt: DateTime.parse(
        '${day}T${hour.toString().padLeft(2, '0')}:00',
      ),
    );

SyncFavorite fav(String id, int added, [int? deleted]) => SyncFavorite(
  thikrId: id,
  addedAt: DateTime(2026, 9, 1, 0, added),
  deletedAt: deleted == null ? null : DateTime(2026, 9, 1, 0, deleted),
);

SettingsSnapshot snap(SyncGroup g, int minute) => SettingsSnapshot(
  group: g,
  values: const {},
  updatedAt: DateTime(2026, 9, 1, 0, minute),
);

void main() {
  group('completions', () {
    test('a union: each side gets what only the other has', () {
      final r = mergeCompletions(
        [done('2026-09-01', 'morning'), done('2026-09-02', 'evening')],
        [done('2026-09-02', 'evening'), done('2026-09-03', 'sleep')],
      );
      expect(r.toLocal, [done('2026-09-03', 'sleep')]);
      expect(r.toRemote, [done('2026-09-01', 'morning')]);
    });

    test('the same routine on the same day from two devices is one', () {
      final r = mergeCompletions(
        [done('2026-09-01', 'morning', 6)],
        [done('2026-09-01', 'morning', 9)],
      );
      expect(r.isEmpty, isTrue);
    });

    test('is idempotent: merging the result again changes nothing', () {
      final local = [done('2026-09-01', 'morning')];
      final remote = [done('2026-09-02', 'evening')];
      final r = mergeCompletions(local, remote);
      final again = mergeCompletions(
        [...local, ...r.toLocal],
        [...remote, ...r.toRemote],
      );
      expect(again.isEmpty, isTrue);
    });

    test('duplicate remote rows are applied once', () {
      final r = mergeCompletions(const [], [
        done('2026-09-01', 'morning', 6),
        done('2026-09-01', 'morning', 7),
      ]);
      expect(r.toLocal, hasLength(1));
    });
  });

  group('favourites', () {
    test('rows only one side has go to the other', () {
      final r = mergeFavorites([fav('a', 1)], [fav('b', 1)]);
      expect(r.toLocal, [fav('b', 1)]);
      expect(r.toRemote, [fav('a', 1)]);
    });

    test('a removal on one device removes it on the other', () {
      // Added at :01 everywhere, removed on the phone at :05.
      final r = mergeFavorites([fav('a', 1)], [fav('a', 1, 5)]);
      expect(r.toLocal, [fav('a', 1, 5)]);
      expect(r.toRemote, isEmpty);
    });

    test('re-adding after a remote removal wins when it is later', () {
      final r = mergeFavorites([fav('a', 9)], [fav('a', 1, 5)]);
      expect(r.toRemote, [fav('a', 9)]);
      expect(r.toLocal, isEmpty);
    });

    test('an older local removal loses to a newer remote re-add', () {
      final r = mergeFavorites([fav('a', 1, 3)], [fav('a', 7)]);
      expect(r.toLocal, [fav('a', 7)]);
    });

    test('on an exact tie the kept favourite wins', () {
      final kept = SyncFavorite(thikrId: 'a', addedAt: DateTime(2026, 9, 1, 5));
      final removed = SyncFavorite(
        thikrId: 'a',
        addedAt: DateTime(2026, 9, 1, 1),
        deletedAt: DateTime(2026, 9, 1, 5),
      );
      expect(mergeFavorites([removed], [kept]).toLocal, [kept]);
      expect(mergeFavorites([kept], [removed]).toRemote, [kept]);
    });

    test('identical rows need nothing', () {
      expect(mergeFavorites([fav('a', 1, 2)], [fav('a', 1, 2)]).isEmpty, true);
    });
  });

  group('settings', () {
    test('the later change wins, per group', () {
      expect(
        mergeSettings(
          local: DateTime(2026, 9, 1, 0, 9),
          remote: snap(SyncGroup.app, 3),
        ),
        SettingsDirection.toRemote,
      );
      expect(
        mergeSettings(
          local: DateTime(2026, 9, 1, 0, 1),
          remote: snap(SyncGroup.reminders, 3),
        ),
        SettingsDirection.toLocal,
      );
    });

    test('a device that never changed a group adopts the account', () {
      expect(
        mergeSettings(local: null, remote: snap(SyncGroup.prayer, 3)),
        SettingsDirection.toLocal,
      );
    });

    test('an account without the group takes the device copy', () {
      expect(
        mergeSettings(local: DateTime(2026), remote: null),
        SettingsDirection.toRemote,
      );
      expect(mergeSettings(local: null, remote: null), SettingsDirection.none);
    });

    test('equal stamps are already in sync', () {
      expect(
        mergeSettings(
          local: DateTime(2026, 9, 1, 0, 3),
          remote: snap(SyncGroup.app, 3),
        ),
        SettingsDirection.none,
      );
    });
  });

  test('the first-merge summary counts what this device contributed', () {
    final s = summarize(
      completions: mergeCompletions([
        done('2026-09-01', 'morning'),
        done('2026-09-02', 'morning'),
      ], const []),
      favorites: mergeFavorites([fav('a', 1), fav('b', 1, 2)], const []),
      settings: const [SettingsDirection.none, SettingsDirection.toRemote],
    );
    expect(s.sessions, 2);
    // A tombstone is not a saved thikr.
    expect(s.favorites, 1);
    expect(s.settings, isTrue);
    expect(s.isEmpty, isFalse);
  });
}
