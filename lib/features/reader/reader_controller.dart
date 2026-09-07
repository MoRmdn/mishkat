import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/thikr.dart';

/// Delay before a thikr whose count has reached zero advances to the next one.
/// Long enough to register the completion, short enough not to feel like a wait.
const Duration kAutoAdvanceDelay = Duration(milliseconds: 480);

@immutable
class ReaderSession {
  const ReaderSession({
    required this.category,
    required this.index,
    this.finished = false,
  });

  final ThikrCategory category;
  final int index;
  final bool finished;

  ReaderSession copyWith({int? index, bool? finished}) => ReaderSession(
    category: category,
    index: index ?? this.index,
    finished: finished ?? this.finished,
  );
}

@immutable
class AthkarState {
  const AthkarState({
    this.remaining = const {},
    this.completedToday = const {},
    this.favorites = const {},
    this.session,
  });

  /// Remaining repetitions per thikr id. Absent means "untouched".
  final Map<String, int> remaining;

  /// Categories whose session has been completed today.
  final Set<ThikrCategory> completedToday;

  /// Favourited thikr ids. In-memory for now; M6 persists these to drift.
  final Set<String> favorites;

  final ReaderSession? session;

  AthkarState copyWith({
    Map<String, int>? remaining,
    Set<ThikrCategory>? completedToday,
    Set<String>? favorites,
    ReaderSession? session,
    bool clearSession = false,
  }) {
    return AthkarState(
      remaining: remaining ?? this.remaining,
      completedToday: completedToday ?? this.completedToday,
      favorites: favorites ?? this.favorites,
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
  void open(ThikrCategory category, List<Thikr> items) {
    _advanceTimer?.cancel();
    final counts = Map<String, int>.from(state.remaining);
    for (final t in items) {
      counts[t.id] = t.count;
    }
    state = state.copyWith(
      remaining: counts,
      session: ReaderSession(category: category, index: 0),
    );
  }

  /// Counts one repetition of the current thikr.
  ///
  /// When it reaches zero the next thikr is scheduled rather than shown at
  /// once, so the completed state is visible for a beat.
  void countOne(List<Thikr> items) {
    final s = state.session;
    if (s == null || s.finished || items.isEmpty) return;

    final current = items[s.index];
    final left = (state.remainingFor(current) - 1).clamp(0, current.count);

    state = state.copyWith(remaining: {...state.remaining, current.id: left});

    if (left == 0) {
      _advanceTimer?.cancel();
      _advanceTimer = Timer(kAutoAdvanceDelay, () => advance(items));
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
    // The tasbih is an open-ended counter, so it never completes a session.
    final completed = s.category.isCountedSession
        ? {...state.completedToday, s.category}
        : state.completedToday;
    state = state.copyWith(
      completedToday: completed,
      session: s.copyWith(finished: true),
    );
  }

  void close() {
    _advanceTimer?.cancel();
    state = state.copyWith(clearSession: true);
  }

  void toggleFavorite(String thikrId) {
    final favorites = {...state.favorites};
    if (!favorites.remove(thikrId)) favorites.add(thikrId);
    state = state.copyWith(favorites: favorites);
  }

  /// How many athkar in [items] are fully counted down.
  int completedCount(List<Thikr> items) =>
      items.where((t) => state.remainingFor(t) == 0).length;
}

final readerControllerProvider =
    NotifierProvider<ReaderController, AthkarState>(ReaderController.new);
