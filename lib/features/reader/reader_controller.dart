import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/theme/mishkat_tokens.dart' show Motion;
import '../../data/models/thikr.dart';
import '../../data/repositories/progress_providers.dart';
import '../../services/diagnostics.dart';

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
  });

  final ThikrCategory category;
  final int index;
  final bool finished;

  /// Set when the session reads a hand-picked subset — a saved thikr opened
  /// from Favourites — rather than the whole routine. Such a session is not
  /// the routine, so finishing it records no completion.
  final List<String>? itemIds;

  bool get isWholeRoutine => itemIds == null;

  /// The athkar this session reads, in order.
  List<Thikr> itemsFrom(AthkarLibrary library) => itemIds == null
      ? library[category]
      : [for (final id in itemIds!) ?library.byId(id)];

  ReaderSession copyWith({int? index, bool? finished}) => ReaderSession(
    category: category,
    index: index ?? this.index,
    finished: finished ?? this.finished,
    itemIds: itemIds,
  );
}

@immutable
class AthkarState {
  const AthkarState({this.remaining = const {}, this.session});

  /// Remaining repetitions per thikr id. Absent means "untouched".
  final Map<String, int> remaining;

  final ReaderSession? session;

  AthkarState copyWith({
    Map<String, int>? remaining,
    ReaderSession? session,
    bool clearSession = false,
  }) {
    return AthkarState(
      remaining: remaining ?? this.remaining,
      session: clearSession ? null : (session ?? this.session),
    );
  }

  int remainingFor(Thikr t) => remaining[t.id] ?? t.count;
}

class ReaderController extends Notifier<AthkarState> {
  Timer? _advanceTimer;

  @override
  AthkarState build() {
    ref.onDispose(() => _advanceTimer?.cancel());
    return const AthkarState();
  }

  /// Opens [category] as a fresh session with every count restored.
  ///
  /// Pass [subset] to read only those athkar, as Favourites does.
  void open(ThikrCategory category, List<Thikr> items, {bool subset = false}) {
    _advanceTimer?.cancel();
    final counts = Map<String, int>.from(state.remaining);
    for (final t in items) {
      counts[t.id] = t.count;
    }
    state = state.copyWith(
      remaining: counts,
      session: ReaderSession(
        category: category,
        index: 0,
        itemIds: subset ? [for (final t in items) t.id] : null,
      ),
    );
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

    if (left == 0) {
      _advanceTimer?.cancel();
      _advanceTimer = Timer(advanceDelay, () => advance(items));
    }
  }

  void advance(List<Thikr> items) {
    final s = state.session;
    if (s == null || s.finished) return;
    _advanceTimer?.cancel();

    if (s.index + 1 < items.length) {
      state = state.copyWith(session: s.copyWith(index: s.index + 1));
    } else {
      _finish();
    }
  }

  void previous() {
    final s = state.session;
    if (s == null || s.index == 0) return;
    _advanceTimer?.cancel();
    state = state.copyWith(session: s.copyWith(index: s.index - 1));
  }

  /// Restores the current thikr's count to full.
  void resetCurrent(List<Thikr> items) {
    final s = state.session;
    if (s == null || items.isEmpty) return;
    _advanceTimer?.cancel();
    final current = items[s.index];
    state = state.copyWith(
      remaining: {...state.remaining, current.id: current.count},
    );
  }

  void _finish() {
    final s = state.session;
    if (s == null) return;
    state = state.copyWith(session: s.copyWith(finished: true));

    // The tasbih is an open-ended counter, so it never completes a session.
    if (s.category.isCountedSession && s.isWholeRoutine) {
      ref
          .read(appDatabaseProvider)
          .recordCompletion(s.category.key, ref.read(clockProvider)())
          .then((_) => invalidateProgress(ref));
      ref.read(diagnosticsProvider).sessionCompleted(s.category.key);
    }
  }

  void close() {
    _advanceTimer?.cancel();
    state = state.copyWith(clearSession: true);
  }

  Future<void> toggleFavorite(String thikrId) async {
    // Asks the database rather than a provider: favoriteIdsProvider only holds
    // a value while something is listening, so reading it here would silently
    // treat "not subscribed" as "not favourited".
    final db = ref.read(appDatabaseProvider);
    if (await db.isFavorite(thikrId)) {
      await db.removeFavorite(thikrId);
    } else {
      await db.addFavorite(thikrId, ref.read(clockProvider)());
    }
    invalidateProgress(ref);
  }

  /// How many athkar in [items] are fully counted down.
  int completedCount(List<Thikr> items) =>
      items.where((t) => state.remainingFor(t) == 0).length;
}

final readerControllerProvider =
    NotifierProvider<ReaderController, AthkarState>(ReaderController.new);
