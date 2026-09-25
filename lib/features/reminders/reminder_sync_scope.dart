import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../data/models/reminder_settings.dart';
import '../../services/reminder_scheduler.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../services/diagnostics.dart';
import '../../services/permission_service.dart';
import '../reader/reader_screen.dart';
import '../settings/settings_controller.dart';
import 'reminder_controller.dart';
import 'reminder_sync.dart';

/// Keeps the OS schedule in step with app state.
///
/// Re-applies whenever the reminder settings, the granted permissions or the
/// language change, and again on resume — which is also where a prayer-mode
/// window gets topped back up and a timezone change is picked up.
class ReminderSyncScope extends ConsumerStatefulWidget {
  const ReminderSyncScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderSyncScope> createState() => _ReminderSyncScopeState();
}

class _ReminderSyncScopeState extends ConsumerState<ReminderSyncScope>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(notificationServiceProvider).onTap = _openSlot;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _sync();
      // A reminder that launched the app should land on its athkar, not home.
      final launched = await ref.read(notificationServiceProvider).launchSlot();
      if (launched != null) _openSlot(launched);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaitedSync();
  }

  void unawaitedSync() {
    () async {
      // A user who has flown somewhere should get reminders on local time.
      await ref.read(notificationServiceProvider).syncTimeZone();
      await ref.read(permissionsProvider.notifier).refresh();
      await _sync();
    }();
  }

  /// Opens the athkar for a tapped reminder.
  ///
  /// Tapping is also the moment a prayer-mode window is worth topping up: the
  /// user is demonstrably here, and it costs nothing.
  void _openSlot(ReminderSlotId slot) {
    if (!mounted) return;
    final library = ref.read(athkarLibraryProvider).value;
    if (library == null) return;

    ref.read(diagnosticsProvider).reminderOpened(slot);
    // Back to the shell first, as a share link does: a second reader stacked
    // on an open one would leave it blank when closed.
    Navigator.of(context).popUntil((route) => route.isFirst);
    openReader(context, ref, slot.category, library[slot.category]);
    unawaitedSync();
  }

  Future<void> _sync({ReminderSchedule? schedule}) async {
    if (!mounted) return;
    final library = ref.read(athkarLibraryProvider).value;
    if (library == null) return;

    final ReminderSchedule applied =
        schedule ?? ref.read(currentScheduleProvider);

    await syncReminders(
      service: ref.read(notificationServiceProvider),
      schedule: applied,
      permissions: ref.read(permissionsProvider),
      l: L.of(context),
      library: library,
      languageCode: ref.read(settingsProvider).language.name,
    );

    if (!mounted) return;
    ref.invalidate(pendingCountProvider);

    final permissions = ref.read(permissionsProvider);
    if (permissions.notifications) {
      ref
          .read(diagnosticsProvider)
          .reminderScheduled(
            mode: ref.read(reminderSettingsProvider).mode,
            pendingCount: applied.pendingCount,
            exactAlarmsAllowed: permissions.exactAlarms,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the derived schedule, not the settings it comes from: a
    // settings listener fires before dependent providers recompute, so reading
    // the schedule inside it hands back the previous value.
    ref.listen<ReminderSchedule>(
      currentScheduleProvider,
      (_, next) => _sync(schedule: next),
    );
    ref.listen<PermissionState>(permissionsProvider, (_, _) => _sync());
    ref.listen(settingsProvider.select((s) => s.language), (_, _) => _sync());
    ref.listen(athkarLibraryProvider, (_, _) => _sync());

    return widget.child;
  }
}
