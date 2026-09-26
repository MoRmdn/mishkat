import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_service.dart';
import 'feedback_models.dart';
import 'feedback_outbox.dart';
import 'feedback_repository.dart';

/// Whether the signed-in account is the owner, read from `admins/{uid}`.
/// The rules check the same document, so this only decides what to show.
final isAdminProvider = FutureProvider<bool>((ref) async {
  final account = ref.watch(accountProvider);
  if (account is! SignedIn) return false;
  return ref.watch(feedbackRepositoryProvider).isAdmin(account.uid);
});

/// The Home dot and the settings rows' dot and count.
final feedbackBadgesProvider = FutureProvider<FeedbackBadges>((ref) async {
  final uid = ref.watch(accountProvider).uid;
  if (uid == null) return FeedbackBadges.none;
  final admin = await ref.watch(isAdminProvider.future);
  try {
    return await ref
        .watch(feedbackRepositoryProvider)
        .badges(uid, isAdmin: admin);
  } on FeedbackOffline {
    return FeedbackBadges.none;
  }
});

/// The sender's conversations, with drafts still in the outbox on top.
final myThreadsProvider = FutureProvider<List<FeedbackThread>>((ref) async {
  final drafts = ref.watch(feedbackOutboxProvider);
  final uid = ref.watch(accountProvider).uid;
  var sent = const <FeedbackThread>[];
  if (uid != null) {
    try {
      sent = await ref.watch(feedbackRepositoryProvider).myThreads(uid);
    } on FeedbackOffline {
      // Show what is on the device.
    }
  }
  final sentIds = {for (final t in sent) t.id};
  return [
    for (final d in drafts.reversed)
      if (!sentIds.contains(d.id)) FeedbackThread.fromDraft(d),
    ...sent,
  ];
});

/// The owner's inbox under one filter.
typedef InboxFilter = ({FeedbackType? type, FeedbackStatus? status});

final inboxProvider = FutureProvider.family<List<FeedbackThread>, InboxFilter>(
  (ref, filter) => ref
      .watch(feedbackRepositoryProvider)
      .inbox(type: filter.type, status: filter.status),
);

final threadProvider = FutureProvider.family<FeedbackThread?, String>(
  (ref, id) => ref.watch(feedbackRepositoryProvider).thread(id),
);

final messagesProvider = FutureProvider.family<List<FeedbackMessage>, String>(
  (ref, id) => ref.watch(feedbackRepositoryProvider).messages(id),
);

/// Re-reads every feedback list and badge. Called after the user acts, on
/// resume and on pull-to-refresh.
void refreshFeedback(Ref ref) {
  ref
    ..invalidate(feedbackBadgesProvider)
    ..invalidate(myThreadsProvider)
    ..invalidate(inboxProvider)
    ..invalidate(threadProvider)
    ..invalidate(messagesProvider);
}

void refreshFeedbackFromWidget(WidgetRef ref) {
  ref
    ..invalidate(feedbackBadgesProvider)
    ..invalidate(myThreadsProvider)
    ..invalidate(inboxProvider)
    ..invalidate(threadProvider)
    ..invalidate(messagesProvider);
}
