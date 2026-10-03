import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../services/auth/auth_service.dart';
import '../../services/diagnostics.dart';
import '../../services/feedback/feedback_providers.dart';
import '../../services/push/push_models.dart';
import '../../services/push/push_providers.dart';
import '../../services/push/push_service.dart';
import '../feedback/thread_page.dart';
import '../reminders/reminder_controller.dart';
import '../settings/settings_controller.dart';
import 'notifications_page.dart';

/// Connects FCM to the app: the announcement topic for the chosen language,
/// this device's token for feedback replies, and where a tapped push leads.
///
/// Mounted beside `ShareLinkScope`, after onboarding, so a push never skips
/// the permission ladder — the notification permission it asks for is the
/// one pushes use too. Does nothing when Firebase did not start.
class PushScope extends ConsumerStatefulWidget {
  const PushScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PushScope> createState() => _PushScopeState();
}

class _PushScopeState extends ConsumerState<PushScope> {
  final _subscriptions = <StreamSubscription<Object>>[];

  PushRegistration get _registration => ref.read(pushRegistrationProvider);

  @override
  void initState() {
    super.initState();
    // After the first frame, so a tapped push has a navigator to push onto.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    if (!mounted || !ref.read(cloudAvailableProvider)) return;
    final push = ref.read(pushServiceProvider);
    void onError(Object error, StackTrace stack) =>
        ref.read(diagnosticsProvider).recordError(error, stack);
    _subscriptions.addAll([
      push.onOpened.listen(_open, onError: onError),
      push.onForeground.listen(_arrived, onError: onError),
      push.onTokenRefresh.listen((token) {
        _registration.syncTopics();
        _registration.registerDevice(token: token);
      }, onError: onError),
    ]);
    try {
      await push.start();
      await _nameChannel();
      final launch = await push.initialMessage();
      if (launch != null) await _open(launch);
    } catch (error, stack) {
      onError(error, stack);
    }
    await _registration.syncTopics();
    await _registration.registerDevice();
  }

  /// The Android channel's name is shown in system settings, so it follows
  /// the app's language.
  Future<void> _nameChannel() {
    final lang = ref.read(settingsProvider).language.locale;
    return ref
        .read(notificationServiceProvider)
        .ensureMessagesChannel(lookupL(lang).messagesChannelName);
  }

  /// Arrived with the app open: the OS shows nothing, so bring the dots up
  /// to date instead.
  void _arrived(PushMessage message) {
    switch (message) {
      case AnnouncementPush():
        refreshAnnouncements(ref);
      case ReplyPush():
        refreshFeedbackFromWidget(ref);
    }
  }

  Future<void> _open(PushMessage message) async {
    if (!mounted) return;
    _arrived(message);
    // A push is a fresh start, as a share link is: back to the shell first,
    // so a reader underneath is checkpointed rather than stacked on.
    Navigator.of(context).popUntil((route) => route.isFirst);
    switch (message) {
      case AnnouncementPush(:final id):
        await openNotifications(context, highlight: id);
      case ReplyPush(:final threadId):
        await openThread(context, threadId);
    }
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(cloudAvailableProvider)) {
      // The topic and the reply language follow the app's language.
      ref.listen(settingsProvider.select((s) => s.language), (_, _) {
        _nameChannel();
        _registration.syncTopics();
        _registration.registerDevice();
      });
      ref.listen(announcementPushProvider, (_, _) {
        _registration.syncTopics();
      });
      // An anonymous user is made on the first feedback, and signing in
      // changes who the device belongs to: either way, record it.
      ref.listen(accountProvider.select((a) => a.uid), (_, uid) {
        if (uid != null) _registration.registerDevice();
      });
    }
    return widget.child;
  }
}
