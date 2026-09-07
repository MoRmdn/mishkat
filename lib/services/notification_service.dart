import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/reminder_settings.dart';
import 'reminder_scheduler.dart';

/// Android channel for the athkar reminders. Its id must never change: Android
/// binds user-visible sound and importance settings to it, and a new id silently
/// resets whatever the user chose.
const String kReminderChannelId = 'athkar_reminders';

const String kStartActionId = 'start';
const String kSnoozeActionId = 'snooze';
const Duration kSnoozeDuration = Duration(minutes: 15);

/// Text for one scheduled reminder, resolved at schedule time.
///
/// The notification carries the first thikr and the session length so it has
/// value even if the user never opens the app.
@immutable
class ReminderContent {
  const ReminderContent({
    required this.title,
    required this.body,
    required this.channelName,
    required this.startLabel,
    required this.snoozeLabel,
  });

  final String title, body, channelName, startLabel, snoozeLabel;
}

typedef ReminderContentBuilder = ReminderContent Function(ReminderSlotId slot);

/// Called when the user taps a reminder. Carries the slot to open.
typedef ReminderTapHandler = void Function(ReminderSlotId slot);

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Deliberately empty. A background tap only needs to wake the app; the
  // foreground handler routes it once the UI is up. Snoozing from the
  // background is handled by the OS action, not by re-entering Dart.
}

/// Applies a [ReminderSchedule] to the operating system.
///
/// Everything about *what* to schedule lives in [buildSchedule]; this class
/// only talks to the plugin, so the interesting logic stays testable.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  ReminderTapHandler? _onTap;
  bool _initialized = false;

  /// Set once the UI is ready to route a tap.
  set onTap(ReminderTapHandler handler) => _onTap = handler;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    await syncTimeZone();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permissions are requested explicitly during onboarding, where the
        // rationale is shown first, not silently at startup.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _handleResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _initialized = true;
  }

  /// Points the `timezone` package at the device's current zone.
  ///
  /// Called again on resume: a user who flies across zones should get their
  /// reminders on local time, not the time they left.
  Future<void> syncTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Falls back to whatever `timezone` defaults to rather than failing to
      // schedule at all.
    }
  }

  String get currentTimeZone => tz.local.name;

  void _handleResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    _onTap?.call(ReminderSlotId.fromKey(payload));
  }

  /// Replaces every scheduled reminder with [schedule].
  ///
  /// Cancels first so a slot turned off, or a window that shrank, leaves
  /// nothing stale behind.
  Future<void> apply(
    ReminderSchedule schedule,
    ReminderContentBuilder content, {
    required bool exactAllowed,
  }) async {
    await init();
    await _plugin.cancelAll();

    for (final entry in schedule.entries) {
      final text = content(entry.slot);
      await _plugin.zonedSchedule(
        id: entry.id,
        title: text.title,
        body: text.body,
        payload: entry.slot.key,
        scheduledDate: tz.TZDateTime.from(entry.at, tz.local),
        notificationDetails: _details(text),
        androidScheduleMode: exactAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            // Without the exact-alarm permission the OS may delay delivery by
            // some minutes. The reminders tab says so rather than pretending.
            : AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: entry.repeatsDaily
            ? DateTimeComponents.time
            : null,
      );
    }
  }

  NotificationDetails _details(ReminderContent text) => NotificationDetails(
    android: AndroidNotificationDetails(
      kReminderChannelId,
      text.channelName,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      styleInformation: BigTextStyleInformation(text.body),
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          kStartActionId,
          text.startLabel,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(kSnoozeActionId, text.snoozeLabel),
      ],
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );

  /// What the OS actually holds. The UI prints this rather than what the app
  /// believes it scheduled.
  Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests()).length;

  Future<void> cancelAll() => _plugin.cancelAll();

  /// The notification that launched the app, if any.
  Future<ReminderSlotId?> launchSlot() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final payload = details?.notificationResponse?.payload;
    if (details?.didNotificationLaunchApp != true || payload == null)
      return null;
    return ReminderSlotId.fromKey(payload);
  }
}
