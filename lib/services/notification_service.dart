import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/clock.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/brand_colors.dart';
import '../data/local/settings_store.dart';
import '../data/models/reminder_settings.dart';
import '../data/repositories/athkar_repository.dart';
import 'diagnostics.dart';
import 'reminder_content.dart';
import 'reminder_scheduler.dart';

export 'reminder_content.dart' show ReminderContent;

/// Keep this ID stable: Android binds user sound/importance settings to it.
const String kReminderChannelId = 'athkar_reminders';
const String kStartActionId = 'start';
const String kSnoozeActionId = 'snooze';
const Duration kSnoozeDuration = Duration(minutes: 15);

/// Four IDs outside the routine planner's range. Re-snoozing replaces the
/// same slot's one-off and uses at most four of iOS's reserved pending slots.
const int kSnoozeIdBase = 10000;
int snoozeNotificationId(ReminderSlotId slot) => kSnoozeIdBase + slot.index;

typedef ReminderContentBuilder = ReminderContent Function(ReminderSlotId slot);
typedef ReminderTapHandler = void Function(ReminderSlotId slot);
typedef SnoozeContentLoader =
    Future<ReminderContent?> Function(ReminderSlotId slot);

/// Reads fresh persisted state in the action isolate, without needing the UI.
/// Null means the user has since disabled this slot.
Future<ReminderContent?> _loadSnoozeContent(ReminderSlotId slot) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final store = SettingsStore(prefs);
  if (!store.readReminders().slot(slot).enabled) return null;
  final language = store.read().language.name;
  return buildReminderContent(
    l: lookupL(Locale(language)),
    library: await AthkarRepository().load(),
    slot: slot,
    languageCode: language,
  );
}

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  if (response.actionId != kSnoozeActionId) return;
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  try {
    await NotificationService(
      clock: container.read(clockProvider),
    ).handleResponse(response);
  } catch (error, stack) {
    const NoopDiagnostics().recordError(error, stack);
  } finally {
    container.dispose();
  }
}

/// Applies schedules and actions to the OS. All mutations from this instance
/// are serialized so an older refresh cannot finish after a newer refresh.
class NotificationService {
  NotificationService({
    required this._clock,
    FlutterLocalNotificationsPlugin? plugin,
    SnoozeContentLoader? snoozeContent,
    void Function(Object, StackTrace)? onError,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _snoozeContent = snoozeContent ?? _loadSnoozeContent,
       _onError =
           onError ??
           ((error, stack) =>
               const NoopDiagnostics().recordError(error, stack));

  final Clock _clock;
  final FlutterLocalNotificationsPlugin _plugin;
  final SnoozeContentLoader _snoozeContent;
  final void Function(Object, StackTrace) _onError;
  ReminderTapHandler? _onTap;
  Future<void>? _initializing;
  Future<void> _mutations = Future<void>.value();

  set onTap(ReminderTapHandler handler) => _onTap = handler;

  Future<void> _serialize(Future<void> Function() operation) {
    final next = _mutations.then((_) => operation());
    // A failed mutation reaches its caller but must not poison later work.
    _mutations = next.catchError((Object _, StackTrace _) {});
    return next;
  }

  Future<void> init() => _initializing ??= _initialize().catchError((
    Object error,
    StackTrace stack,
  ) {
    _initializing = null;
    Error.throwWithStackTrace(error, stack);
  });

  Future<void> _initialize() async {
    tzdata.initializeTimeZones();
    await syncTimeZone();
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings(
          '@drawable/ic_stat_mishkat',
        ),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: [
            for (final language in ['ar', 'en'])
              DarwinNotificationCategory(
                'athkar_$language',
                actions: [
                  DarwinNotificationAction.plain(
                    kStartActionId,
                    lookupL(Locale(language)).notifActionStart,
                    options: {DarwinNotificationActionOption.foreground},
                  ),
                  DarwinNotificationAction.plain(
                    kSnoozeActionId,
                    lookupL(Locale(language)).notifActionSnooze,
                  ),
                ],
              ),
          ],
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        unawaited(handleResponse(response).catchError(_onError));
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> syncTimeZone() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // UTC remains a valid fallback for a relative 15-minute snooze.
    }
  }

  String get currentTimeZone => tz.local.name;

  static ReminderSlotId? _slot(String? payload) =>
      ReminderSlotId.values.where((s) => s.key == payload).firstOrNull;

  static bool _opensReader(NotificationResponse response) =>
      response.notificationResponseType ==
          NotificationResponseType.selectedNotification ||
      response.actionId == kStartActionId;

  Future<void> handleResponse(NotificationResponse response) async {
    final slot = _slot(response.payload);
    if (slot == null) return;
    if (response.actionId == kSnoozeActionId) {
      // Capture the action time before any asynchronous initialization/I/O.
      final at = _clock().add(kSnoozeDuration);
      await _serialize(() async {
        await init();
        final text = await _snoozeContent(slot);
        if (text == null) return;
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final exact = await android?.canScheduleExactNotifications() ?? false;
        await _schedule(
          id: snoozeNotificationId(slot),
          slot: slot,
          at: at,
          text: text,
          exactAllowed: exact,
        );
      });
      return;
    }
    if (_opensReader(response)) _onTap?.call(slot);
  }

  /// Reconcile routine IDs without deleting snoozes for enabled slots.
  /// Disabled slots lose their pending snoozes as well as routine reminders.
  Future<void> apply(
    ReminderSchedule schedule,
    ReminderContentBuilder content, {
    required bool exactAllowed,
  }) => _serialize(() async {
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    final desiredIds = schedule.entries.map((e) => e.id).toSet();
    final enabledSlots = schedule.entries.map((e) => e.slot).toSet();
    for (final slot in ReminderSlotId.values) {
      if (!enabledSlots.contains(slot)) {
        await _plugin.cancel(id: snoozeNotificationId(slot));
      }
    }
    for (final old in pending) {
      // Only remove IDs owned by the routine planner. Never cancel a snooze
      // from this snapshot: a background action may have just replaced it.
      final isRoutine =
          (old.id >= 0 && old.id < ReminderSlotId.values.length) ||
          (old.id >= 1000 &&
              old.id < 1000 + ReminderSlotId.values.length * 100);
      if (isRoutine && !desiredIds.contains(old.id)) {
        await _plugin.cancel(id: old.id);
      }
    }
    for (final entry in schedule.entries) {
      await _schedule(
        id: entry.id,
        slot: entry.slot,
        at: entry.at,
        text: content(entry.slot),
        exactAllowed: exactAllowed,
        repeatsDaily: entry.repeatsDaily,
      );
    }
  });

  Future<void> _schedule({
    required int id,
    required ReminderSlotId slot,
    required DateTime at,
    required ReminderContent text,
    required bool exactAllowed,
    bool repeatsDaily = false,
  }) async {
    Future<void> schedule(AndroidScheduleMode mode) => _plugin.zonedSchedule(
      id: id,
      title: text.title,
      body: text.body,
      payload: slot.key,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: _details(text),
      androidScheduleMode: mode,
      matchDateTimeComponents: repeatsDaily ? DateTimeComponents.time : null,
    );
    try {
      await schedule(
        exactAllowed
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on PlatformException catch (error) {
      if (!exactAllowed || error.code != 'exact_alarms_not_permitted') rethrow;
      // Permission can be revoked between the check and scheduling.
      await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  NotificationDetails _details(ReminderContent text) => NotificationDetails(
    android: AndroidNotificationDetails(
      kReminderChannelId,
      text.channelName,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      color: BrandColors.notificationAccent,
      styleInformation: BigTextStyleInformation(text.body),
      actions: [
        AndroidNotificationAction(
          kStartActionId,
          text.startLabel,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(kSnoozeActionId, text.snoozeLabel),
      ],
    ),
    iOS: DarwinNotificationDetails(
      categoryIdentifier: 'athkar_${text.languageCode}',
      presentAlert: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    ),
  );

  Future<int> pendingCount() async =>
      (await _plugin.pendingNotificationRequests()).length;

  Future<void> cancelAll() => _serialize(() => _plugin.cancelAll());

  Future<ReminderSlotId?> launchSlot() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    final response = details?.notificationResponse;
    if (details?.didNotificationLaunchApp != true || response == null) {
      return null;
    }
    // Snooze never routes to reading, including cold-launch responses.
    if (response.actionId == kSnoozeActionId || !_opensReader(response)) {
      return null;
    }
    return _slot(response.payload);
  }
}
