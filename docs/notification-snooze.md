# Notification snooze

The four existing reminder slots support Start and Snooze. Snooze requests a
one-off reminder 15 minutes after the action is handled, without opening the
reader. Android falls back to inexact delivery when exact-alarm access is
unavailable or revoked between the permission check and scheduling.

The background entry point loads fresh saved settings and bundled content;
it does not require the app's widget tree. Disabled slots are ignored. Both
Arabic and English iOS action categories are registered, and AppDelegate
registers plugins for the background engine. Existing slot-key payloads remain
compatible. Unknown payloads and actions do not open an arbitrary routine.

IDs 10000–10003 are reserved for snoozes, separate from normal reminders.
Re-snoozing a slot replaces its existing one-off. Routine reconciliation removes
stale routine IDs and disabled-slot snoozes, preserving enabled-slot snoozes.
Mutations within a NotificationService instance are serialized; this is not a
cross-isolate transaction. The existing planner reserves four positions below
iOS's 64-notification cap. This implements the current four-slot app, not the
expanded plan's future prayer-occurrence identity and completion rules.

## Validation

`flutter analyze` passes. The notification-service and scheduler suites pass
34 tests, including the background entry point, action routing, midnight
rollover, replacement IDs, disabled settings, permission fallback, mutation
serialization/recovery and iOS action/category configuration.

The arm64 iOS simulator build succeeds, including compilation of AppDelegate.
The generic Flutter simulator build hits a local SDK architecture-parsing error
on the combined `arm64 x86_64` value; building with `ARCHS=arm64` and
`ONLY_ACTIVE_ARCH=YES` succeeds without changing saved project settings.

Existing reminder UI integration tests encounter the Home header RenderFlex
overflow at `lib/features/home/home_tab.dart:128`, also observed before this
change. The header was not changed as part of snooze work.

## Physical-device checks still required

- On Android and iOS, receive a reminder with the screen locked and the app
  backgrounded/terminated, tap Snooze, and verify delivery about 15 minutes
  later without the reader opening. Repeat with Arabic and English settings.
- Open/resume the app while a snooze is pending; verify it survives refresh.
- Disable that slot before the snooze fires; verify it is cancelled.
- Tap Start and the notification body; verify the correct routine opens.
- Test Android with exact alarms denied, after reboot, and under battery-saving
  restrictions. OS-delayed delivery must not be mistaken for an exact timer.

Mock platform tests and a simulator build cannot certify locked-device delivery.
