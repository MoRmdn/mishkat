import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/clock.dart';
import 'package:mishkat/data/local/app_database.dart';
import 'package:mishkat/data/models/app_settings.dart';
import 'package:mishkat/data/models/prayer_settings.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/progress_providers.dart';
import 'package:mishkat/features/reader/reader_controller.dart';
import 'package:mishkat/features/reminders/prayer_controller.dart';
import 'package:mishkat/features/reminders/reminder_controller.dart';
import 'package:mishkat/features/settings/settings_controller.dart';
import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/prayer_time_service.dart';
import 'package:mishkat/services/sync/sync_models.dart';
import 'package:mishkat/services/sync/sync_remote.dart';
import 'package:mishkat/services/sync/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/cloud_fakes.dart';

const _me = AppUser(
  uid: 'me',
  isAnonymous: false,
  email: 'me@example.com',
  provider: AuthProviderKind.apple,
);

/// Never finds a position, so tests never touch geolocator.
class _NoPosition extends PrayerTimeService {
  const _NoPosition();

  @override
  Future<({double latitude, double longitude})?>
  resolveDevicePosition() async => null;
}

Thikr _thikr(String id) => Thikr(
  id: id,
  category: ThikrCategory.morning,
  text: 'نص',
  count: 1,
  sourceId: 'muslim',
  reference: 1,
  meaningEn: 'meaning',
);

void main() {
  late AppDatabase db;
  late FakeSyncRemote remote;
  late FakeAuthService auth;
  late ProviderContainer container;
  var now = DateTime(2026, 9, 24, 6, 30);

  Future<void> start({AppUser? user = _me}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    db = AppDatabase.memory();
    remote = FakeSyncRemote();
    auth = FakeAuthService(initialUser: user);
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => now),
        authServiceProvider.overrideWithValue(auth),
        syncRemoteProvider.overrideWithValue(remote),
        prayerTimeServiceProvider.overrideWithValue(const _NoPosition()),
      ],
    );
    // accountProvider reads the auth stream; let it deliver.
    container.listen(accountProvider, (_, _) {});
    await pumpEventQueue();
  }

  SyncController sync() => container.read(syncProvider.notifier);

  setUp(() => now = DateTime(2026, 9, 24, 6, 30));
  tearDown(() async {
    await container.read(readerControllerProvider.notifier).flush();
    container.dispose();
    await db.close();
  });

  group('pushes as the user acts', () {
    test('a favourite and its removal reach the account', () async {
      await start();
      final reader = container.read(readerControllerProvider.notifier);
      await reader.toggleFavorite('mo1');
      await pumpEventQueue();
      expect(remote.favorites['me']!['mo1']!.isDeleted, isFalse);

      now = now.add(const Duration(minutes: 5));
      await reader.toggleFavorite('mo1');
      await pumpEventQueue();
      expect(remote.favorites['me']!['mo1']!.deletedAt, now);
    });

    test('a finished routine reaches the account once', () async {
      await start();
      final reader = container.read(readerControllerProvider.notifier);
      final items = [_thikr('a')];
      await reader.open(ThikrCategory.morning, items);
      reader.advance(items);
      await pumpEventQueue();
      // The same routine again today is not a second completion.
      await reader.open(ThikrCategory.morning, items);
      reader.advance(items);
      await pumpEventQueue();
      expect(remote.completions['me']!.keys, ['2026-09-24_morning']);
    });

    test('a settings change is stamped and pushed', () async {
      await start();
      container
          .read(reminderSettingsProvider.notifier)
          .setSlotTime(ReminderSlotId.morning, hour: 7, minute: 15);
      await pumpEventQueue();
      final pushed = remote.settings['me']![SyncGroup.reminders]!;
      expect(pushed.updatedAt, now);
      expect(
        (pushed.values['slots'] as List).firstWhere(
          (s) => s['id'] == 'morning',
        ),
        {'id': 'morning', 'hour': 7, 'minute': 15, 'enabled': true},
      );
    });

    test('nothing leaves the device when signed out or anonymous', () async {
      await start(user: const AppUser(uid: 'anon', isAnonymous: true));
      await container
          .read(readerControllerProvider.notifier)
          .toggleFavorite('mo1');
      container
          .read(settingsProvider.notifier)
          .setAppearance(AppearanceMode.dark);
      await pumpEventQueue();
      expect(remote.holds('anon'), isFalse);
    });

    test('onboarding and a fresh GPS fix are not synced changes', () async {
      await start();
      container.read(settingsProvider.notifier).completeOnboarding();
      await pumpEventQueue();
      expect(remote.settings['me'], isNull);
    });
  });

  group('pulling', () {
    test('a first sync merges both ways and reports what it added', () async {
      await start();
      await db.recordCompletion('morning', DateTime(2026, 9, 20, 6));
      await db.recordCompletion('evening', DateTime(2026, 9, 21, 17));
      await db.addFavorite('mo1', DateTime(2026, 9, 1));
      await remote.putCompletions('me', [
        SyncCompletion(
          category: 'sleep',
          day: '2026-09-22',
          completedAt: DateTime(2026, 9, 22, 22),
        ),
      ]);
      await remote.putFavorites('me', [
        SyncFavorite(thikrId: 'ev2', addedAt: DateTime(2026, 9, 2)),
      ]);

      final summary = await sync().sync(full: true);

      expect(summary!.sessions, 2);
      expect(summary.favorites, 1);
      expect(remote.completions['me'], hasLength(3));
      expect((await db.allCompletions()).map((c) => c.day).toSet(), {
        '2026-09-20',
        '2026-09-21',
        '2026-09-22',
      });
      expect((await db.allFavorites()).map((f) => f.thikrId).toSet(), {
        'mo1',
        'ev2',
      });
      expect(container.read(syncProvider).phase, SyncPhase.idle);
      expect(container.read(syncProvider).lastSyncAt, now);
    });

    test('a removal on another device removes it here', () async {
      await start();
      await db.addFavorite('mo1', DateTime(2026, 9, 1));
      await remote.putFavorites('me', [
        SyncFavorite(
          thikrId: 'mo1',
          addedAt: DateTime(2026, 9, 1),
          deletedAt: DateTime(2026, 9, 3),
        ),
      ]);
      await sync().sync();
      expect(await db.allFavorites(), isEmpty);
    });

    test('newer reminder times from another device are adopted', () async {
      await start();
      await remote.putSettings(
        'me',
        SettingsSnapshot(
          group: SyncGroup.reminders,
          updatedAt: DateTime(2026, 9, 23),
          values: {
            'mode': 'fixed',
            'slots': [
              {'id': 'evening', 'hour': 18, 'minute': 5, 'enabled': true},
            ],
          },
        ),
      );
      await sync().sync();

      final slot = container
          .read(reminderSettingsProvider)
          .slot(ReminderSlotId.evening);
      expect((slot.hour, slot.minute), (18, 5));
      // Adopting is not a change of this device's: nothing is pushed back.
      expect(
        remote.settings['me']![SyncGroup.reminders]!.updatedAt,
        DateTime(2026, 9, 23),
      );
    });

    test('an older account copy loses to this device', () async {
      await start();
      container
          .read(settingsProvider.notifier)
          .setAppearance(AppearanceMode.dark);
      await remote.putSettings(
        'me',
        SettingsSnapshot(
          group: SyncGroup.app,
          updatedAt: DateTime(2026, 9, 1),
          values: const {'appearance': 'light'},
        ),
      );
      await sync().sync(full: true);
      expect(container.read(settingsProvider).appearance, AppearanceMode.dark);
      expect(
        remote.settings['me']![SyncGroup.app]!.values['appearance'],
        'dark',
      );
    });

    test('prayer settings sync without coordinates', () async {
      await start();
      container.read(prayerSettingsProvider.notifier).setManualCity('cairo');
      await pumpEventQueue();
      final values = remote.settings['me']![SyncGroup.prayer]!.values;
      expect(values['manualCityId'], 'cairo');
      expect(values.keys, isNot(contains('latitude')));
      expect(values.keys, isNot(contains('longitude')));
    });

    test('offline shows as offline and keeps the last sync time', () async {
      await start();
      await sync().sync();
      final last = container.read(syncProvider).lastSyncAt;
      remote.online = false;
      now = now.add(const Duration(hours: 1));
      expect(await sync().sync(), isNull);
      expect(container.read(syncProvider).phase, SyncPhase.offline);
      expect(container.read(syncProvider).lastSyncAt, last);
    });

    test('pulled rows refresh the progress providers', () async {
      await start();
      container.listen(completionsProvider, (_, _) {});
      await container.read(completionsProvider.future);
      await remote.putCompletions('me', [
        SyncCompletion(
          category: 'morning',
          day: '2026-09-23',
          completedAt: DateTime(2026, 9, 23, 6),
        ),
      ]);
      await sync().sync();
      expect(await container.read(completionsProvider.future), hasLength(1));
    });
  });

  test('the Quranic-script and text-size choices round-trip', () async {
    await start();
    container.read(settingsProvider.notifier)
      ..toggleQuranFont()
      ..setTextSize(ThikrSize.large);
    await pumpEventQueue();
    expect(remote.settings['me']![SyncGroup.app]!.values, {
      'appearance': 'system',
      'language': 'ar',
      'textSize': ThikrSize.large.index,
      'useQuranFont': true,
    });
  });

  test('an unknown city from a newer app keeps the local one', () async {
    await start();
    await remote.putSettings(
      'me',
      SettingsSnapshot(
        group: SyncGroup.prayer,
        updatedAt: DateTime(2026, 9, 23),
        values: const {'manualCityId': 'atlantis', 'madhab': 'hanafi'},
      ),
    );
    await sync().sync();
    final prayer = container.read(prayerSettingsProvider);
    expect(prayer.manualCityId, 'makkah');
    expect(prayer.madhab, AsrMadhab.hanafi);
  });
}
