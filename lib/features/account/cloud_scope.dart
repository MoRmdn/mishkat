import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../services/auth/auth_service.dart';
import '../../services/feedback/feedback_outbox.dart';
import '../../services/feedback/feedback_providers.dart';
import '../../services/sync/sync_service.dart';
import 'account_actions.dart';

/// Brings the account and feedback up to date on launch and on resume:
/// pulls what other devices changed, retries feedback still in the outbox,
/// and re-reads the unread-reply badges.
///
/// Does nothing visible, and nothing at all when Firebase did not start.
class CloudScope extends ConsumerStatefulWidget {
  const CloudScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CloudScope> createState() => _CloudScopeState();
}

class _CloudScopeState extends ConsumerState<CloudScope>
    with WidgetsBindingObserver {
  /// A phone switched between apps does not need a pull every time.
  static const _minInterval = Duration(minutes: 1);
  DateTime? _lastRefresh;
  bool _profileSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _refresh() {
    if (!mounted || !ref.read(cloudAvailableProvider)) return;
    final now = ref.read(clockProvider)();
    final last = _lastRefresh;
    if (last != null && now.difference(last) < _minInterval) return;
    _lastRefresh = now;

    ref.read(syncProvider.notifier).sync();
    // Once a launch: the build and language the account was last used with.
    if (!_profileSaved && ref.read(accountProvider).canSync) {
      _profileSaved = true;
      ref.read(accountActionsProvider).saveProfile();
    }
    ref.read(feedbackOutboxProvider.notifier).flush();
    refreshFeedbackFromWidget(ref);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
