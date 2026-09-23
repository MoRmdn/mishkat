import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/services/diagnostics.dart';

/// Records what the app reports, so the call sites can be asserted on.
class RecordingDiagnostics implements Diagnostics {
  final List<String> events = [];

  @override
  void reminderScheduled({
    required ReminderMode mode,
    required int pendingCount,
    required bool exactAlarmsAllowed,
  }) => events.add('scheduled:${mode.name}:$pendingCount:$exactAlarmsAllowed');

  @override
  void reminderOpened(ReminderSlotId slot) => events.add('opened:${slot.key}');

  @override
  void sessionCompleted(String categoryKey) =>
      events.add('completed:$categoryKey');

  @override
  void permissionResolved({
    required String permission,
    required bool granted,
  }) => events.add('permission:$permission:$granted');

  @override
  void recordError(Object error, StackTrace? stack, {bool fatal = false}) =>
      events.add('error:$error:$fatal');
}

void main() {
  test('the no-op implementation swallows everything without throwing', () {
    const d = NoopDiagnostics();
    expect(() {
      d.reminderScheduled(
        mode: ReminderMode.fixed,
        pendingCount: 3,
        exactAlarmsAllowed: true,
      );
      d.reminderOpened(ReminderSlotId.morning);
      d.sessionCompleted('morning');
      d.permissionResolved(permission: 'notifications', granted: false);
      d.recordError(Exception('x'), StackTrace.current);
    }, returnsNormally);
  });

  test('the interface covers the delivery question and nothing more', () {
    final d = RecordingDiagnostics();

    d.reminderScheduled(
      mode: ReminderMode.prayer,
      pendingCount: 43,
      exactAlarmsAllowed: false,
    );
    d.reminderOpened(ReminderSlotId.evening);

    // Scheduled-versus-opened, split by whether exact alarms were allowed, is
    // the whole point: it is how a device that silently drops reminders is
    // detected from the field.
    expect(d.events, ['scheduled:prayer:43:false', 'opened:evening']);
  });
}
