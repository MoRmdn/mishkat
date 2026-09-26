import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feedback_models.dart';

/// Feedback threads and their messages.
///
/// ```
/// feedback/{id}               thread metadata and state (FeedbackThread)
/// feedback/{id}/messages/{m}  {from: user|admin, body, createdAt}
/// admins/{uid}                exists only for the owner; console-managed
/// counters/feedback           {next}: the owner's running message number
/// ```
///
/// Reads are one-off gets, refreshed on launch, resume, pull-to-refresh and
/// after the user acts — replies appear in the app, never as a push.
abstract class FeedbackRepository {
  /// Creates the thread, its first message and the sender's rate-limit stamp
  /// in one transaction. Transactions need the server, so this fails fast
  /// while offline ([FeedbackOffline]) and the outbox keeps the draft.
  /// Idempotent: a draft whose thread already exists is left alone.
  Future<void> submit(FeedbackDraft draft, {required String uid});

  Future<List<FeedbackThread>> myThreads(String uid);

  /// Every thread, newest activity first. Owner only.
  Future<List<FeedbackThread>> inbox({
    FeedbackType? type,
    FeedbackStatus? status,
  });

  Future<FeedbackThread?> thread(String id);

  Future<List<FeedbackMessage>> messages(String threadId);

  /// Adds a message. An owner's reply marks the thread answered and unread
  /// for the sender; a sender's reply marks it unread for the owner.
  Future<void> reply(
    String threadId, {
    required MessageAuthor from,
    required String body,
  });

  /// Clears the unread flag for whoever is reading.
  Future<void> markRead(String threadId, {required MessageAuthor reader});

  Future<void> setStatus(String threadId, FeedbackStatus status);

  /// Gives a thread its «#١٠٤» on the owner's first open. Returns the number,
  /// or null if it could not be assigned (offline).
  Future<int?> assignNumber(String threadId);

  Future<FeedbackBadges> badges(String uid, {required bool isAdmin});

  Future<bool> isAdmin(String uid);

  /// Removes every thread [uid] started, with its messages.
  Future<void> deleteAllFor(String uid);
}

/// The server could not be reached.
class FeedbackOffline implements Exception {
  const FeedbackOffline();
}

class _NoFeedback implements FeedbackRepository {
  const _NoFeedback();

  @override
  Future<void> submit(FeedbackDraft draft, {required String uid}) =>
      Future.error(const FeedbackOffline());

  @override
  Future<List<FeedbackThread>> myThreads(String uid) async => const [];

  @override
  Future<List<FeedbackThread>> inbox({
    FeedbackType? type,
    FeedbackStatus? status,
  }) async => const [];

  @override
  Future<FeedbackThread?> thread(String id) async => null;

  @override
  Future<List<FeedbackMessage>> messages(String threadId) async => const [];

  @override
  Future<void> reply(
    String threadId, {
    required MessageAuthor from,
    required String body,
  }) => Future.error(const FeedbackOffline());

  @override
  Future<void> markRead(
    String threadId, {
    required MessageAuthor reader,
  }) async {}

  @override
  Future<void> setStatus(String threadId, FeedbackStatus status) async {}

  @override
  Future<int?> assignNumber(String threadId) async => null;

  @override
  Future<FeedbackBadges> badges(String uid, {required bool isAdmin}) async =>
      FeedbackBadges.none;

  @override
  Future<bool> isAdmin(String uid) async => false;

  @override
  Future<void> deleteAllFor(String uid) async {}
}

final feedbackRepositoryProvider = Provider<FeedbackRepository>(
  (ref) => const _NoFeedback(),
);
