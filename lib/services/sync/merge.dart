// Pure merge rules for account sync.
//
// Like reminder_scheduler.dart, this half is deliberately free of Firebase,
// drift and Riverpod: a sync bug is invisible until someone's streak or
// favourite quietly disappears, so every rule here is unit-tested without a
// device or a server (test/sync_merge_test.dart).
import 'sync_models.dart';

/// What one merge decided: rows the device lacks, and rows the account lacks
/// or holds an older copy of.
class MergeResult<T> {
  const MergeResult({this.toLocal = const [], this.toRemote = const []});

  final List<T> toLocal;
  final List<T> toRemote;

  bool get isEmpty => toLocal.isEmpty && toRemote.isEmpty;
}

/// Completions are a union keyed by `(day, category)`: a routine finished on
/// either device counts once, and nothing is ever removed.
///
/// When both sides hold the same key, neither copy is rewritten — the local
/// unique key already refuses a second row, and the streak reads only the day.
MergeResult<SyncCompletion> mergeCompletions(
  Iterable<SyncCompletion> local,
  Iterable<SyncCompletion> remote,
) {
  final localKeys = {for (final c in local) c.key};
  final remoteKeys = {for (final c in remote) c.key};
  return MergeResult(
    toLocal: _distinct(remote.where((c) => !localKeys.contains(c.key))),
    toRemote: _distinct(local.where((c) => !remoteKeys.contains(c.key))),
  );
}

List<SyncCompletion> _distinct(Iterable<SyncCompletion> rows) {
  final seen = <String>{};
  return [
    for (final c in rows)
      if (seen.add(c.key)) c,
  ];
}

/// Favourites: last writer wins per thikr, on the later of added and removed.
///
/// A removal travels as a tombstone, so unfavouriting on one phone removes it
/// on the other instead of being resurrected by the next union. On an exact
/// tie the kept favourite wins: losing a removal costs one tap, losing a
/// favourite costs the user something they chose to keep.
MergeResult<SyncFavorite> mergeFavorites(
  Iterable<SyncFavorite> local,
  Iterable<SyncFavorite> remote,
) {
  final mine = {for (final f in local) f.thikrId: f};
  final theirs = {for (final f in remote) f.thikrId: f};
  final toLocal = <SyncFavorite>[];
  final toRemote = <SyncFavorite>[];

  for (final id in {...mine.keys, ...theirs.keys}) {
    final l = mine[id], r = theirs[id];
    if (r == null) {
      toRemote.add(l!);
    } else if (l == null) {
      toLocal.add(r);
    } else if (l != r) {
      final winner = _newer(l, r);
      (identical(winner, l) ? toRemote : toLocal).add(winner);
    }
  }
  return MergeResult(toLocal: toLocal, toRemote: toRemote);
}

SyncFavorite _newer(SyncFavorite l, SyncFavorite r) {
  final c = l.stamp.compareTo(r.stamp);
  if (c != 0) return c > 0 ? l : r;
  if (l.isDeleted != r.isDeleted) return l.isDeleted ? r : l;
  return l;
}

/// Which way one settings group should flow.
enum SettingsDirection { none, toLocal, toRemote }

/// Settings: last writer wins per group, by the time the group last changed.
///
/// [local] is null when this device has never changed the group, so a fresh
/// install adopts the account's settings rather than overwriting them with
/// defaults. [remote] is null when the account has never stored the group.
SettingsDirection mergeSettings({
  required DateTime? local,
  required SettingsSnapshot? remote,
}) {
  if (remote == null) {
    return local == null ? SettingsDirection.none : SettingsDirection.toRemote;
  }
  if (local == null) return SettingsDirection.toLocal;
  final c = local.compareTo(remote.updatedAt);
  if (c == 0) return SettingsDirection.none;
  return c > 0 ? SettingsDirection.toRemote : SettingsDirection.toLocal;
}

/// What a first sign-in contributed from this device, for the "we merged 42
/// sessions and 6 saved athkar" sheet.
class MergeSummary {
  const MergeSummary({
    required this.sessions,
    required this.favorites,
    required this.settings,
  });

  /// Completions this device had that the account did not.
  final int sessions;

  /// Kept favourites this device had that the account did not.
  final int favorites;

  /// Whether any settings group went from this device to the account.
  final bool settings;

  bool get isEmpty => sessions == 0 && favorites == 0 && !settings;
}

MergeSummary summarize({
  required MergeResult<SyncCompletion> completions,
  required MergeResult<SyncFavorite> favorites,
  required Iterable<SettingsDirection> settings,
}) => MergeSummary(
  sessions: completions.toRemote.length,
  favorites: favorites.toRemote.where((f) => !f.isDeleted).length,
  settings: settings.contains(SettingsDirection.toRemote),
);
