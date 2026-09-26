import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../data/local/app_database.dart';
import '../../data/repositories/progress_providers.dart';
import '../../features/reminders/prayer_controller.dart';
import '../../features/reminders/reminder_controller.dart';
import '../../features/settings/settings_controller.dart';
import '../../features/update/update_controller.dart';
import '../auth/auth_service.dart';
import '../diagnostics.dart';
import 'merge.dart';
import 'settings_codec.dart';
import 'sync_models.dart';
import 'sync_remote.dart';

/// The four states the Account screen's sync card draws.
enum SyncPhase { idle, syncing, offline, error }

@immutable
class SyncStatus {
  const SyncStatus(this.phase, {this.lastSyncAt});

  final SyncPhase phase;

  /// When a pull last completed. Null when this device has never synced the
  /// current account.
  final DateTime? lastSyncAt;
}

/// Local-first sync of progress, favourites and settings.
///
/// The device's drift database and preferences stay the source of truth; the
/// account is a mirror. Every local write is pushed as it happens (Firestore
/// queues it while offline), and the account is pulled and merged on sign-in,
/// on resume and from "Sync now". The rules for what wins live in the pure
/// `merge.dart`.
class SyncController extends Notifier<SyncStatus> {
  Future<MergeSummary?>? _running;

  @override
  SyncStatus build() => SyncStatus(
    SyncPhase.idle,
    lastSyncAt: ref.read(settingsStoreProvider).lastSyncAt,
  );

  /// Null when there is nothing to sync with — signed out, or this build is
  /// below `min_supported_version` and must not write in an old format.
  String? get _uid {
    if (ref.read(updateBlocksWritesProvider)) return null;
    final account = ref.read(accountProvider);
    return account.canSync ? account.uid : null;
  }

  // ---- pushes, one per local write ----

  void completionRecorded(String category, DateTime at) {
    final uid = _uid;
    if (uid == null) return;
    _push(
      () => ref.read(syncRemoteProvider).putCompletions(uid, [
        SyncCompletion(category: category, day: dayKey(at), completedAt: at),
      ]),
    );
  }

  Future<void> favoriteChanged(String thikrId) async {
    final uid = _uid;
    if (uid == null) return;
    final row = await ref.read(appDatabaseProvider).favoriteRow(thikrId);
    if (row == null) return;
    _push(
      () => ref.read(syncRemoteProvider).putFavorites(uid, [_favorite(row)]),
    );
  }

  /// Stamps [group] as changed now and pushes it. Called by the settings
  /// controllers only when a value that syncs actually changed.
  void settingsChanged(SyncGroup group) {
    final now = ref.read(clockProvider)();
    ref.read(settingsStoreProvider).setSyncStamp(group.key, now);
    final uid = _uid;
    if (uid == null) return;
    _push(
      () =>
          ref.read(syncRemoteProvider).putSettings(uid, _snapshot(group, now)),
    );
  }

  void _push(Future<void> Function() write) {
    unawaited(
      write().catchError((Object e, StackTrace st) {
        ref.read(diagnosticsProvider).recordError(e, st);
      }),
    );
  }

  // ---- pull and merge ----

  /// Pulls the account and merges it with this device.
  ///
  /// A [full] sync compares everything both ways and is used on sign-in and
  /// from "Sync now"; its [MergeSummary] feeds the first-sign-in sheet. A
  /// resume sync reads only completions that are new on the server, since
  /// this device's own completions were already pushed as they happened.
  ///
  /// [uid] is passed right after sign-in, before [accountProvider] has seen
  /// the new user.
  Future<MergeSummary?> sync({bool full = false, String? uid}) async {
    await ref.read(updateProvider.notifier).ensureChecked();
    if (ref.read(updateBlocksWritesProvider)) return null;
    final target = uid ?? _uid;
    if (target == null) return null;
    return _running ??= _sync(target, full).whenComplete(() => _running = null);
  }

  Future<MergeSummary?> _sync(String uid, bool full) async {
    state = SyncStatus(SyncPhase.syncing, lastSyncAt: state.lastSyncAt);
    final store = ref.read(settingsStoreProvider);
    final db = ref.read(appDatabaseProvider);
    final remoteApi = ref.read(syncRemoteProvider);
    try {
      final remote = await remoteApi.fetch(
        uid,
        completionsSince: full ? null : store.completionsCursor(uid),
      );

      final localCompletions = [
        for (final c in await db.allCompletions())
          SyncCompletion(
            category: c.category,
            day: c.day,
            completedAt: c.completedAt,
          ),
      ];
      final merged = mergeCompletions(localCompletions, remote.completions);
      final completions = full
          ? merged
          : MergeResult<SyncCompletion>(toLocal: merged.toLocal);
      final favorites = mergeFavorites([
        for (final f in await db.favoriteRows()) _favorite(f),
      ], remote.favorites);
      final settings = {
        for (final g in SyncGroup.values)
          g: mergeSettings(
            local: store.syncStamp(g.key),
            remote: remote.settings[g],
          ),
      };

      // This device first, so the user sees the merged state even if the
      // pushes below are still queued.
      for (final c in completions.toLocal) {
        await db.putCompletion(
          category: c.category,
          day: c.day,
          completedAt: c.completedAt,
        );
      }
      for (final f in favorites.toLocal) {
        await db.putFavoriteRow(
          f.thikrId,
          addedAt: f.addedAt,
          deletedAt: f.deletedAt,
        );
      }
      for (final MapEntry(key: group, value: direction) in settings.entries) {
        if (direction == SettingsDirection.toLocal) {
          await _applySettings(remote.settings[group]!);
        }
      }
      if (completions.toLocal.isNotEmpty || favorites.toLocal.isNotEmpty) {
        invalidateProgress(ref);
      }

      final pushes = [
        if (completions.toRemote.isNotEmpty)
          remoteApi.putCompletions(uid, completions.toRemote),
        if (favorites.toRemote.isNotEmpty)
          remoteApi.putFavorites(uid, favorites.toRemote),
        for (final MapEntry(key: group, value: direction) in settings.entries)
          if (direction == SettingsDirection.toRemote)
            remoteApi.putSettings(
              uid,
              _snapshot(group, store.syncStamp(group.key)!),
            ),
      ];
      // A write that has not reached the server within the timeout is still
      // queued by Firestore and will land on its own.
      await Future.wait(
        pushes,
      ).timeout(const Duration(seconds: 20), onTimeout: () => const []);

      if (remote.completionsCursor != null) {
        await store.setCompletionsCursor(uid, remote.completionsCursor!);
      }
      final now = ref.read(clockProvider)();
      await store.setLastSyncAt(now);
      state = SyncStatus(SyncPhase.idle, lastSyncAt: now);
      return summarize(
        completions: completions,
        favorites: favorites,
        settings: settings.values,
      );
    } on SyncOffline {
      state = SyncStatus(SyncPhase.offline, lastSyncAt: state.lastSyncAt);
      return null;
    } catch (e, st) {
      ref.read(diagnosticsProvider).recordError(e, st);
      state = SyncStatus(SyncPhase.error, lastSyncAt: state.lastSyncAt);
      return null;
    }
  }

  Future<void> _applySettings(SettingsSnapshot s) async {
    switch (s.group) {
      case SyncGroup.app:
        ref
            .read(settingsProvider.notifier)
            .replaceFromSync(
              SettingsCodec.decodeApp(s.values, ref.read(settingsProvider)),
            );
      case SyncGroup.reminders:
        // Flows through reminderSettingsProvider, so currentScheduleProvider
        // recomputes and ReminderSyncScope reschedules the OS as usual.
        ref
            .read(reminderSettingsProvider.notifier)
            .replaceFromSync(
              SettingsCodec.decodeReminders(
                s.values,
                ref.read(reminderSettingsProvider),
              ),
            );
      case SyncGroup.prayer:
        ref
            .read(prayerSettingsProvider.notifier)
            .replaceFromSync(
              SettingsCodec.decodePrayer(
                s.values,
                ref.read(prayerSettingsProvider),
              ),
            );
    }
    await ref
        .read(settingsStoreProvider)
        .setSyncStamp(s.group.key, s.updatedAt);
  }

  SettingsSnapshot _snapshot(SyncGroup group, DateTime at) => SettingsSnapshot(
    group: group,
    updatedAt: at,
    values: switch (group) {
      SyncGroup.app => SettingsCodec.encodeApp(ref.read(settingsProvider)),
      SyncGroup.reminders => SettingsCodec.encodeReminders(
        ref.read(reminderSettingsProvider),
      ),
      SyncGroup.prayer => SettingsCodec.encodePrayer(
        ref.read(prayerSettingsProvider),
      ),
    },
  );

  static SyncFavorite _favorite(Favorite f) => SyncFavorite(
    thikrId: f.thikrId,
    addedAt: f.addedAt,
    deletedAt: f.deletedAt,
  );

  /// After sign-out or deletion: this device keeps its data but no longer
  /// mirrors an account.
  Future<void> reset() async {
    await ref.read(settingsStoreProvider).setLastSyncAt(null);
    state = const SyncStatus(SyncPhase.idle);
  }
}

final syncProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);

/// True when a settings group's synced values differ between [a] and [b].
/// Changes that stay on the device (onboarding, a fresh GPS fix) must not
/// stamp the group, or they would overwrite another device's real change.
bool syncedValuesDiffer(Map<String, Object?> a, Map<String, Object?> b) =>
    jsonEncode(a) != jsonEncode(b);
