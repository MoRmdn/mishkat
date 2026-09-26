import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../services/update/update_policy.dart';
import '../reminders/reminder_controller.dart';
import 'optional_update_sheet.dart';
import 'required_update_screen.dart';
import 'update_banners.dart';
import 'update_controller.dart';
import 'whats_new.dart';

/// Checks the published versions on launch and resume, and draws the
/// required screen and the restart splash over the whole app — onboarding,
/// a share link's reader and a reminder's reader included.
///
/// Sits in `MaterialApp.builder`, above the navigator. Never waits on the
/// network: cached values apply at once and a fetch only refines them.
class UpdateGate extends ConsumerStatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends ConsumerState<UpdateGate>
    with WidgetsBindingObserver {
  static const _minInterval = Duration(minutes: 1);
  DateTime? _lastCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  void _check() {
    if (!mounted) return;
    final now = ref.read(clockProvider)();
    final last = _lastCheck;
    if (last != null && now.difference(last) < _minInterval) return;
    _lastCheck = now;
    ref.read(updateProvider.notifier).check();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateProvider);
    final decision = state.decision;
    final required = state.showsRequiredScreen && decision is RequiredUpdate
        ? decision
        : null;
    final restarting = state.phase == UpdatePhase.restarting;
    final covered = required != null || restarting;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(excluding: covered, child: widget.child),
        if (required != null) RequiredUpdateScreen(update: required),
        if (restarting) const UpdateRestartingOverlay(),
      ],
    );
  }
}

/// Inside the shell, where sheets and toasts can be shown: offers an
/// optional update when the shell is on top, and says «تم التحديث إلى…»
/// on the first launch after one.
class UpdatePrompts extends ConsumerStatefulWidget {
  const UpdatePrompts({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UpdatePrompts> createState() => _UpdatePromptsState();
}

class _UpdatePromptsState extends ConsumerState<UpdatePrompts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceUpdate();
      _maybePrompt();
    });
  }

  /// Only over the shell itself: never over the reader, a page or a sheet.
  bool get _shellOnTop =>
      mounted && (ModalRoute.of(context)?.isCurrent ?? false);

  Future<void> _maybePrompt() async {
    if (!_shellOnTop) return;
    if (ref.read(updateProvider).decision is! OptionalUpdate) return;
    // A reminder that opened the app is taking the user to read.
    final fromReminder =
        await ref.read(notificationServiceProvider).launchSlot() != null;
    if (!_shellOnTop) return;
    final update = ref
        .read(updateProvider.notifier)
        .takePrompt(launchedFromReminder: fromReminder);
    if (update == null || !mounted) return;
    final go = await showOptionalUpdateSheet(context, update);
    if (go) await ref.read(updateProvider.notifier).startOptionalUpdate();
  }

  Future<void> _announceUpdate() async {
    final controller = ref.read(updateProvider.notifier);
    final releases = await controller.takeWhatsNew();
    final installed = await controller.installedVersion();
    if (releases == null || installed == null || !mounted) return;
    if (ref.read(updateProvider).showsRequiredScreen) return;
    showUpdatedToast(
      context,
      version: installed,
      onWhatsNew: () => showWhatsNewSheet(context, releases),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(updateProvider.select((s) => s.decision), (_, next) {
      if (next is OptionalUpdate) _maybePrompt();
    });
    return widget.child;
  }
}
