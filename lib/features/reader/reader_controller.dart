import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/theme/mishkat_tokens.dart' show Motion;
import '../../data/models/thikr.dart';
import '../../data/repositories/progress_providers.dart';
import '../../services/diagnostics.dart';
import '../../services/sync/sync_service.dart';

/// Delay before a thikr whose count has reached zero advances to the next one.
/// Long enough to register the completion, short enough not to feel like a wait.
const Duration kAutoAdvanceDelay = Motion.autoAdvance;

@immutable
class ReaderSession {
  const ReaderSession({
    required this.category,
    required this.index,
    this.finished = false,
    this.itemIds,
    this.frozenItems,
  });

  final ThikrCategory category;
  final int index;
  final bool finished;
  final List<Thikr>? frozenItems;

  /// Set when the session reads a hand-picked subset — a saved thikr opened
  /// from Favourites — rather than the whole routine. Such a session is not
  /// the routine, so finishing it records no completion.
  final List<String>? itemIds;

  bool get isWholeRoutine => itemIds == null;

  /// The athkar this session reads, in order.
  List<Thikr> itemsFrom(AthkarLibrary library) =>
      frozenItems ??
      (itemIds == null
          ? library[category]
          : [for (final id in itemIds!) ?library.byId(id)]);

  ReaderSession copyWith({int? index, bool? finished}) => ReaderSession(
    category: category,
    index: index ?? this.index,
    finished: finished ?? this.finished,
    itemIds: itemIds,
    frozenItems: frozenItems,
  );
}

@immutable
class AthkarState {
  const AthkarState({
    this.remaining = const {},
    this.session,
    this.saveFailed = false,
  });

  /// Remaining repetitions per thikr id. Absent means "untouched".
  final Map<String, int> remaining;

  final ReaderSession? session;
  final bool saveFailed;

  AthkarState copyWith({
    Map<String, int>? remaining,
    ReaderSession? session,
    bool clearSession = false,
    bool? saveFailed,
  }) {
    return AthkarState(
      remaining: remaining ?? this.remaining,
      saveFailed: saveFailed ?? this.saveFailed,
      session: clearSession ? null : (session ?? this.session),
    );
  }

  int remainingFor(Thikr t) => remaining[t.id] ?? t.count;
}

class ReaderController extends Notifier<AthkarState> {
  Timer? _advanceTimer;
  Future<void> _writes = Future<void>.value();
  String? _sessionKey;
  bool _advancePending = false;
  int _openRevision = 0;

  /// Lets lifecycle handlers/tests wait until all queued checkpoints commit.
  Future<void> flush() => _writes;

  Future<void> retrySave() {
    if (state.session?.finished == true) {
      _finish();
    } else {
      _save();
    }
    return flush();
  }

  void _enqueue(Future<void> Function() write) {
    final diagnostics = ref.read(diagnosticsProvider);
    _writes = _writes
        .then((_) => write())
        .then((_) {
          if (ref.mounted && state.saveFailed) {
            state = state.copyWith(saveFailed: false);
          }
        })
        .catchError((Object error, StackTrace stack) {
          diagnostics.recordError(error, stack);
          if (ref.mounted) state = state.copyWith(saveFailed: true);
        });
  }

  void _save() {
    final session = state.session;
    final key = _sessionKey;
    if (session == null || session.finished || key == null) return;
    final db = ref.read(appDatabaseProvider);
    final snapshot = jsonEncode({
      'version': 1,
      'category': session.category.key,
      'subset': !session.isWholeRoutine,
      'index': session.index,
      'advancePending': _advancePending,
      'remaining': {
        for (final t in session.frozenItems!) t.id: state.remainingFor(t),
      },
      'items': [
        for (final t in session.frozenItems!)
          {
            'id': t.id,
            'text': t.text,
            'count': t.count,
            'source': t.sourceId,
            'reference': t.reference,
            'meaningEn': t.meaningEn,
            if (t.hasVirtue) 'virtue': {'ar': t.virtueAr, 'en': t.virtueEn},
          },
      ],
    });
    _enqueue(() => db.saveReaderCheckpoint(key, snapshot));
  }

  @override
  AthkarState build() {
    ref.onDispose(() => _advanceTimer?.cancel());
    return const AthkarState();
  }

  /// Resumes an unfinished session, or starts a fresh one after completion.
  /// Frozen items keep content updates from changing an in-progress routine.
  Future<bool> open(
    ThikrCategory category,
    List<Thikr> items, {
    bool subset = false,
    bool restart = false,
  }) async {
    if (items.isEmpty) return false;
    final revision = ++_openRevision;
    _advanceTimer?.cancel();
    _save();
    await flush();
    if (!ref.mounted || revision != _openRevision) return false;
    final key = subset
        ? 'subset:${category.key}:${jsonEncode(items.map((t) => t.id).toList())}'
        : 'routine:${category.key}';
    final raw = restart
        ? null
        : await ref.read(appDatabaseProvider).readerCheckpoint(key);
    if (!ref.mounted || revision != _openRevision) return false;
    var frozen = List<Thikr>.unmodifiable(items);
    var index = 0;
    var counts = {for (final t in frozen) t.id: t.count};
    var advancePending = false;
    if (raw != null) {
      // Treat an unreadable checkpoint as an error, not permission to silently
      // overwrite it. The caller can explicitly choose to start again.
      final saved = jsonDecode(raw) as Map<String, dynamic>;
      if (saved['version'] != 1 ||
          saved['category'] != category.key ||
          saved['subset'] != subset) {
        throw const FormatException('Unsupported reading checkpoint');
      }
      frozen = List<Thikr>.unmodifiable([
        for (final item in saved['items'] as List)
          Thikr.fromJson(category, item as Map<String, dynamic>),
      ]);
      index = saved['index'] as int;
      counts = Map<String, int>.from(saved['remaining'] as Map);
      advancePending = saved['advancePending'] as bool;
      if (frozen.isEmpty ||
          index < 0 ||
          index >= frozen.length ||
          frozen.map((t) => t.id).toSet().length != frozen.length ||
          frozen.any(
            (t) =>
                t.count <= 0 ||
                t.text.trim().isEmpty ||
                counts[t.id] == null ||
                counts[t.id]! < 0 ||
                counts[t.id]! > t.count,
          ) ||
          (advancePending && counts[frozen[index].id] != 0)) {
        throw const FormatException('Invalid reading checkpoint');
      }
    }
    _sessionKey = key;
    _advancePending = advancePending;
    state = AthkarState(
      remaining: counts,
      session: ReaderSession(
        category: category,
        index: index,
        itemIds: subset ? [for (final t in frozen) t.id] : null,
        frozenItems: frozen,
      ),
    );
    _save();
    if (_advancePending) {
      _advanceTimer = Timer(kAutoAdvanceDelay, () => advance(frozen));
    }
    return true;
  }

  /// Counts one repetition of the current thikr.
  ///
  /// When it reaches zero the next thikr is scheduled rather than shown at
  /// once, so the completed state is visible for a beat.
  ///
  /// [advanceDelay] is the pause before moving on; the reader passes zero
  /// when the system asks for reduced motion.
  void countOne(
    List<Thikr> items, {
    Duration advanceDelay = kAutoAdvanceDelay,
  }) {
    final s = state.session;
    if (s == null || s.finished || items.isEmpty) return;

    final current = items[s.index];
    final left = (state.remainingFor(current) - 1).clamp(0, current.count);

    state = state.copyWith(remaining: {...state.remaining, current.id: left});

    _advancePending = left == 0;
    _save();

    if (left == 0) {
      _advanceTimer?.cancel();
      _advanceTimer = Timer(advanceDelay, () => advance(items));
    }
  }

  void advance(List<Thikr> items) {
    final s = state.session;
    if (s == null || s.finished || items.isEmpty) return;
    _advanceTimer?.cancel();
    _advancePending = false;

    if (s.index + 1 < items.length) {
      state = state.copyWith(session: s.copyWith(index: s.index + 1));
      _save();
    } else {
      _finish();
    }
  }

  void previous() {
    final s = state.session;
    if (s == null || s.index == 0) return;
    _advanceTimer?.cancel();
    _advancePending = false;
    state = state.copyWith(session: s.copyWith(index: s.index - 1));
    _save();
  }

  /// Restores the current thikr's count to full.
  void resetCurrent(List<Thikr> items) {
    final s = state.session;
    if (s == null || items.isEmpty) return;
    _advanceTimer?.cancel();
    final current = items[s.index];
    _advancePending = false;
    state = state.copyWith(
      remaining: {...state.remaining, current.id: current.count},
    );
    _save();
  }

  void _finish() {
    final s = state.session;
    if (s == null) return;
    state = state.copyWith(session: s.copyWith(finished: true));

    final key = _sessionKey!;
    final db = ref.read(appDatabaseProvider);
    final now = ref.read(clockProvider)();
    final category = s.category.isCountedSession && s.isWholeRoutine
        ? s.category.key
        : null;
    final diagnostics = ref.read(diagnosticsProvider);
    final sync = ref.read(syncProvider.notifier);
    _enqueue(() async {
      final recorded = await db.finishReading(key, category, now);
      if (ref.mounted) invalidateProgress(ref);
      if (category != null) diagnostics.sessionCompleted(category);
      if (recorded) sync.completionRecorded(category!, now);
    });
  }

  void close() {
    ++_openRevision;
    _advanceTimer?.cancel();
    _save();
    _sessionKey = null;
    state = state.copyWith(clearSession: true);
  }

  Future<void> toggleFavorite(String thikrId) async {
    // Asks the database rather than a provider: favoriteIdsProvider only holds
    // a value while something is listening, so reading it here would silently
    // treat "not subscribed" as "not favourited".
    final db = ref.read(appDatabaseProvider);
    final now = ref.read(clockProvider)();
    if (await db.isFavorite(thikrId)) {
      await db.removeFavorite(thikrId, now);
    } else {
      await db.addFavorite(thikrId, now);
    }
    invalidateProgress(ref);
    await ref.read(syncProvider.notifier).favoriteChanged(thikrId);
  }

  /// How many athkar in [items] are fully counted down.
  int completedCount(List<Thikr> items) =>
      items.where((t) => state.remainingFor(t) == 0).length;
}

final readerControllerProvider =
    NotifierProvider<ReaderController, AthkarState>(ReaderController.new);
