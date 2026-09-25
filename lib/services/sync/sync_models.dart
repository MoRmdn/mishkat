import 'package:flutter/foundation.dart';

/// The three settings groups that sync, each with its own last-writer-wins
/// stamp so changing the theme on one phone never reverts a reminder time
/// changed on another.
enum SyncGroup {
  app('app'),
  reminders('reminders'),
  prayer('prayer');

  const SyncGroup(this.key);

  /// The Firestore document id under `users/{uid}/settings/`.
  final String key;
}

/// A finished routine as it travels between devices. Keyed by
/// `(day, category)`, which is also the local unique key, so a union is
/// idempotent.
@immutable
class SyncCompletion {
  const SyncCompletion({
    required this.category,
    required this.day,
    required this.completedAt,
  });

  final String category;

  /// Local calendar day, `YYYY-MM-DD`, as the device that finished it saw it.
  final String day;
  final DateTime completedAt;

  String get key => '${day}_$category';

  @override
  bool operator ==(Object other) =>
      other is SyncCompletion &&
      other.category == category &&
      other.day == day &&
      other.completedAt == completedAt;

  @override
  int get hashCode => Object.hash(category, day, completedAt);

  @override
  String toString() => 'SyncCompletion($key)';
}

/// A favourite, or the tombstone left when one was removed.
@immutable
class SyncFavorite {
  const SyncFavorite({
    required this.thikrId,
    required this.addedAt,
    this.deletedAt,
  });

  final String thikrId;
  final DateTime addedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  /// When this row last changed: the later of adding and removing.
  DateTime get stamp =>
      deletedAt != null && deletedAt!.isAfter(addedAt) ? deletedAt! : addedAt;

  @override
  bool operator ==(Object other) =>
      other is SyncFavorite &&
      other.thikrId == thikrId &&
      other.addedAt == addedAt &&
      other.deletedAt == deletedAt;

  @override
  int get hashCode => Object.hash(thikrId, addedAt, deletedAt);

  @override
  String toString() =>
      'SyncFavorite($thikrId, ${isDeleted ? 'removed' : 'kept'} @ $stamp)';
}

/// One settings group as plain values, with the time it last changed.
@immutable
class SettingsSnapshot {
  const SettingsSnapshot({
    required this.group,
    required this.values,
    required this.updatedAt,
  });

  final SyncGroup group;
  final Map<String, Object?> values;
  final DateTime updatedAt;

  @override
  bool operator ==(Object other) =>
      other is SettingsSnapshot &&
      other.group == group &&
      other.updatedAt == updatedAt &&
      mapEquals(other.values, values);

  @override
  int get hashCode => Object.hash(group, updatedAt, values.length);
}

/// Everything the account holds, as last read from the server.
@immutable
class RemoteState {
  const RemoteState({
    this.completions = const [],
    this.favorites = const [],
    this.settings = const {},
    this.completionsCursor,
  });

  final List<SyncCompletion> completions;
  final List<SyncFavorite> favorites;
  final Map<SyncGroup, SettingsSnapshot> settings;

  /// The server time of the newest completion read, so the next pull can
  /// ask only for what arrived after it. Null when nothing was read.
  final DateTime? completionsCursor;
}
