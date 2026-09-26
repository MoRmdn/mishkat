import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/settings_controller.dart';
import '../auth/auth_service.dart';
import '../diagnostics.dart';
import 'feedback_models.dart';
import 'feedback_repository.dart';

/// How a send attempt ended, for board 10's three states.
enum SendResult {
  /// «وصلتنا رسالتك».
  sent,

  /// «ستُرسل عند الاتصال»: kept on the device and retried on its own.
  queued,

  /// «تعذّر الإرسال»: kept as a draft; the user can retry.
  failed,
}

/// Feedback written on this device that the server has not confirmed.
///
/// A draft is saved here before anything touches the network, and removed
/// only when the server has it. That covers the two cases Firestore's own
/// offline queue cannot: a first message sent before any account exists
/// (creating the anonymous user needs the network), and the app being killed
/// mid-send. Drafts are retried on launch, on resume and on the next send.
class FeedbackOutbox extends Notifier<List<FeedbackDraft>> {
  static const _key = 'feedback.outbox';
  Future<void>? _flushing;

  @override
  List<FeedbackDraft> build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_key);
    if (raw == null) return const [];
    try {
      return [
        for (final j in jsonDecode(raw) as List)
          if (j is Map) ?FeedbackDraft.fromJson(j.cast<String, Object?>()),
      ];
    } on FormatException {
      return const [];
    }
  }

  Future<void> _save(List<FeedbackDraft> drafts) async {
    state = drafts;
    final prefs = ref.read(sharedPreferencesProvider);
    if (drafts.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(
        _key,
        jsonEncode([for (final d in drafts) d.toJson()]),
      );
    }
  }

  /// Saves [draft] and tries to deliver it.
  Future<SendResult> send(FeedbackDraft draft) async {
    // The conversation list watches this outbox, so saving and removing a
    // draft is all it takes to refresh it.
    await _save([...state.where((d) => d.id != draft.id), draft]);
    return _deliver(draft);
  }

  /// Retries every saved draft. Safe to call often.
  Future<void> flush() => _flushing ??= () async {
    try {
      for (final draft in [...state]) {
        if (await _deliver(draft) == SendResult.queued) break;
      }
    } finally {
      _flushing = null;
    }
  }();

  Future<SendResult> _deliver(FeedbackDraft draft) async {
    try {
      final uid = await ref.read(authServiceProvider).ensureAnonymous();
      await ref
          .read(feedbackRepositoryProvider)
          .submit(draft, uid: uid)
          .timeout(const Duration(seconds: 20));
    } on AuthOffline {
      return SendResult.queued;
    } on FeedbackOffline {
      return SendResult.queued;
    } on TimeoutException {
      return SendResult.queued;
    } catch (e, st) {
      // The error only: diagnostics never carry what the user wrote.
      ref.read(diagnosticsProvider).recordError(e, st);
      return SendResult.failed;
    }
    if (!ref.mounted) return SendResult.sent;
    await _save([...state.where((d) => d.id != draft.id)]);
    return SendResult.sent;
  }
}

final feedbackOutboxProvider =
    NotifierProvider<FeedbackOutbox, List<FeedbackDraft>>(FeedbackOutbox.new);
