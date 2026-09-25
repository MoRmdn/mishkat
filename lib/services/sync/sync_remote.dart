import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_models.dart';
import 'user_profile.dart';

/// The account's copy of a user's data. Firestore in the app, an in-memory
/// map in tests.
abstract class SyncRemote {
  /// Reads the account. With [completionsSince], only completions the server
  /// received after that server time are returned; favourites and settings
  /// are always read whole, since they are small.
  ///
  /// Throws [SyncOffline] when the server cannot be reached. Never answers
  /// from a local cache: a pull that silently read stale data would look like
  /// a successful sync.
  Future<RemoteState> fetch(String uid, {DateTime? completionsSince});

  /// Writes are queued by Firestore while offline, so these complete once the
  /// write is in the local queue, not when the server has it.
  Future<void> putCompletions(String uid, List<SyncCompletion> rows);
  Future<void> putFavorites(String uid, List<SyncFavorite> rows);
  Future<void> putSettings(String uid, SettingsSnapshot snapshot);

  /// Merges [profile] into `users/{uid}` and stamps the last time the app
  /// was opened. Fields the profile leaves out keep their stored value.
  Future<void> putProfile(String uid, UserProfile profile);

  /// Deletes everything under `users/{uid}`.
  Future<void> deleteAll(String uid);
}

/// The server could not be reached. The sync card shows "offline" and the
/// next resume tries again.
class SyncOffline implements Exception {
  const SyncOffline();
}

class _NoRemote implements SyncRemote {
  const _NoRemote();

  @override
  Future<RemoteState> fetch(String uid, {DateTime? completionsSince}) =>
      Future.error(const SyncOffline());

  @override
  Future<void> putCompletions(String uid, List<SyncCompletion> rows) async {}

  @override
  Future<void> putFavorites(String uid, List<SyncFavorite> rows) async {}

  @override
  Future<void> putSettings(String uid, SettingsSnapshot snapshot) async {}

  @override
  Future<void> putProfile(String uid, UserProfile profile) async {}

  @override
  Future<void> deleteAll(String uid) async {}
}

final syncRemoteProvider = Provider<SyncRemote>((ref) => const _NoRemote());
