import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../data/models/reminder_settings.dart';
import '../../services/diagnostics.dart';
import '../../services/notification_service.dart';
import '../../services/permission_service.dart';
import '../../services/reminder_scheduler.dart';
import '../../services/sync/settings_codec.dart';
import '../../services/sync/sync_models.dart';
import '../../services/sync/sync_service.dart';
import '../settings/settings_controller.dart';
import 'prayer_controller.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(
    clock: ref.read(clockProvider),
    onError: (error, stack) =>
        ref.read(diagnosticsProvider).recordError(error, stack),
  ),
);

final permissionServiceProvider = Provider<PermissionService>(
  (ref) => PermissionService(),
);

/// Reminder configuration, persisted on every change.
class ReminderController extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() => ref.read(settingsStoreProvider).readReminders();

  void _update(ReminderSettings next) {
    final synced = syncedValuesDiffer(
      SettingsCodec.encodeReminders(state),
      SettingsCodec.encodeReminders(next),
    );
    state = next;
    ref.read(settingsStoreProvider).writeReminders(next);
    if (synced) {
      ref.read(syncProvider.notifier).settingsChanged(SyncGroup.reminders);
    }
  }

  /// Adopts reminders pulled from the account. The schedule follows through
  /// currentScheduleProvider like any other change.
  void replaceFromSync(ReminderSettings next) {
    state = next;
    ref.read(settingsStoreProvider).writeReminders(next);
  }

  void setMode(ReminderMode mode) => _update(state.copyWith(mode: mode));

  void toggleSlot(ReminderSlotId id) {
    final slot = state.slot(id);
    _update(state.withSlot(slot.copyWith(enabled: !slot.enabled)));
  }

  void setSlotTime(
    ReminderSlotId id, {
    required int hour,
    required int minute,
  }) {
    _update(
      state.withSlot(
        state.slot(id).copyWith(hour: hour % 24, minute: minute % 60),
      ),
    );
  }

  /// Nudges a slot's time, wrapping like the design's stepper.
  void shiftSlotTime(ReminderSlotId id, {int hours = 0, int minutes = 0}) {
    final slot = state.slot(id);
    setSlotTime(
      id,
      hour: (slot.hour + hours + 24) % 24,
      minute: (slot.minute + minutes + 60) % 60,
    );
  }
}

final reminderSettingsProvider =
    NotifierProvider<ReminderController, ReminderSettings>(
      ReminderController.new,
    );

/// What the app has been granted. Refreshed on resume and after each request,
/// because the user can change any of it in system settings behind our back.
class PermissionController extends Notifier<PermissionState> {
  @override
  PermissionState build() {
    Future.microtask(refresh);
    return const PermissionState();
  }

  Future<void> refresh() async {
    state = await ref.read(permissionServiceProvider).read();
  }

  Future<bool> requestNotifications() async {
    final granted = await ref
        .read(permissionServiceProvider)
        .requestNotifications();
    ref
        .read(diagnosticsProvider)
        .permissionResolved(permission: 'notifications', granted: granted);
    await refresh();
    return granted;
  }

  Future<bool> requestExactAlarms() async {
    final granted = await ref
        .read(permissionServiceProvider)
        .requestExactAlarms();
    ref
        .read(diagnosticsProvider)
        .permissionResolved(permission: 'exact_alarms', granted: granted);
    await refresh();
    return granted;
  }

  Future<bool> requestBatteryExemption() async {
    final granted = await ref
        .read(permissionServiceProvider)
        .requestBatteryExemption();
    ref
        .read(diagnosticsProvider)
        .permissionResolved(permission: 'battery_exemption', granted: granted);
    await refresh();
    return granted;
  }
}

final permissionsProvider =
    NotifierProvider<PermissionController, PermissionState>(
      PermissionController.new,
    );

/// Resolves prayer times for the scheduler.
///
/// Null while prayer mode has no position to compute from, which is what makes
/// [buildSchedule] fall back to the fixed clock times and say so.
final prayerTimesResolverProvider = Provider<PrayerTimesForDay?>((ref) {
  final settings = ref.watch(prayerSettingsProvider);
  if (settings.effectiveCoordinates == null) return null;
  return ref.watch(prayerTimeServiceProvider).resolver(settings);
});

/// The schedule the app believes it should have. Pure — derived from settings
/// and the clock, nothing else.
final currentScheduleProvider = Provider<ReminderSchedule>((ref) {
  return buildSchedule(
    settings: ref.watch(reminderSettingsProvider),
    now: ref.watch(clockProvider)(),
    prayerTimes: ref.watch(prayerTimesResolverProvider),
  );
});

/// What the OS actually holds. Shown in the UI in preference to what the app
/// thinks it scheduled — the design treats the schedule as visible state.
final pendingCountProvider = FutureProvider<int>((ref) async {
  ref.watch(currentScheduleProvider);
  return ref.watch(notificationServiceProvider).pendingCount();
});
