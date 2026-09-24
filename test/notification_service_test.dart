import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/services/notification_service.dart';
import 'package:mishkat/services/reminder_scheduler.dart';

const channel = MethodChannel('dexterous.com/flutter/local_notifications');
const text = ReminderContent(
  title: 'Morning',
  body: 'Remember',
  channelName: 'Reminders',
  startLabel: 'Start',
  snoozeLabel: 'Snooze 15 minutes',
  languageCode: 'en',
);

NotificationResponse action(
  String? payload,
  String? actionId, {
  NotificationResponseType type =
      NotificationResponseType.selectedNotificationAction,
}) => NotificationResponse(
  id: 1,
  payload: payload,
  actionId: actionId,
  notificationResponseType: type,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<MethodCall> calls;
  late List<Map<String, Object?>> pending;
  late bool exactAllowed;
  late bool rejectExact;
  late bool failSchedule;
  late NotificationService service;
  late List<ReminderSlotId> opened;
  late Completer<void>? scheduleGate;
  late Map<String, Object?>? launch;
  final now = DateTime.utc(2026, 9, 24, 23, 55);

  List<Map<dynamic, dynamic>> scheduled() => calls
      .where((c) => c.method == 'zonedSchedule')
      .map((c) => c.arguments as Map<dynamic, dynamic>)
      .toList();
  List<int> cancelled() => calls
      .where((c) => c.method == 'cancel')
      .map((c) => (c.arguments as Map)['id'] as int)
      .toList();

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls = [];
    pending = [];
    opened = [];
    exactAllowed = true;
    rejectExact = false;
    failSchedule = false;
    scheduleGate = null;
    launch = null;
    SharedPreferences.setMockInitialValues({'settings.language': 'en'});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'initialize':
              return true;
            case 'pendingNotificationRequests':
              return pending;
            case 'canScheduleExactNotifications':
              return exactAllowed;
            case 'getNotificationAppLaunchDetails':
              return launch;
            case 'zonedSchedule':
              if (failSchedule) {
                throw PlatformException(code: 'schedule_failed');
              }
              if (rejectExact &&
                  (call.arguments
                          as Map)['platformSpecifics']['scheduleMode'] ==
                      AndroidScheduleMode.exactAllowWhileIdle.name) {
                throw PlatformException(code: 'exact_alarms_not_permitted');
              }
              await scheduleGate?.future;
              return null;
            default:
              return null;
          }
        });
    service = NotificationService(
      clock: () => now,
      snoozeContent: (_) async => text,
    )..onTap = opened.add;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'snooze schedules one-off 15 minutes later across midnight, without opening',
    () async {
      await service.handleResponse(action('morning', kSnoozeActionId));
      final request = scheduled().single;
      expect(request['id'], snoozeNotificationId(ReminderSlotId.morning));
      expect(
        DateTime.parse(request['scheduledDateTime'] as String),
        DateTime(2026, 9, 25, 0, 10),
      );
      expect(request['matchDateTimeComponents'], isNull);
      expect(request['payload'], 'morning');
      expect(request['title'], 'Morning');
      expect(opened, isEmpty);
    },
  );

  test(
    'repeat snoozes reuse their slot ID without touching regular reminders',
    () async {
      await service.handleResponse(action('morning', kSnoozeActionId));
      await service.handleResponse(action('morning', kSnoozeActionId));
      await service.handleResponse(action('evening', kSnoozeActionId));
      expect(scheduled().map((r) => r['id']), [10001, 10001, 10002]);
      expect(cancelled(), isEmpty);
      expect(calls.any((c) => c.method == 'cancelAll'), isFalse);
    },
  );

  test(
    'Start and body taps open the correct routine; invalid actions do nothing',
    () async {
      await service.handleResponse(action('evening', kStartActionId));
      await service.handleResponse(
        action(
          'wake',
          null,
          type: NotificationResponseType.selectedNotification,
        ),
      );
      await service.handleResponse(action('invalid', kStartActionId));
      await service.handleResponse(action(null, kSnoozeActionId));
      await service.handleResponse(action('morning', 'unknown'));
      expect(opened, [ReminderSlotId.evening, ReminderSlotId.wake]);
      expect(scheduled(), isEmpty);
    },
  );

  test('denied exact permission uses inexact scheduling', () async {
    exactAllowed = false;
    await service.handleResponse(action('morning', kSnoozeActionId));
    // Plugin wire encoding uses enum names.
    expect(
      scheduled().single['platformSpecifics']['scheduleMode'],
      AndroidScheduleMode.inexactAllowWhileIdle.name,
    );
  });

  test('a failed mutation does not prevent the next snooze', () async {
    failSchedule = true;
    await expectLater(
      service.handleResponse(action('morning', kSnoozeActionId)),
      throwsA(isA<PlatformException>()),
    );
    failSchedule = false;
    await service.handleResponse(action('evening', kSnoozeActionId));
    expect(scheduled().last['id'], 10002);
  });

  test('revoking notifications cancels all pending requests', () async {
    await service.cancelAll();
    expect(calls.map((c) => c.method), contains('cancelAll'));
  });

  test('permission revoked during scheduling falls back to inexact', () async {
    rejectExact = true;
    await service.handleResponse(action('morning', kSnoozeActionId));
    expect(scheduled().map((r) => r['platformSpecifics']['scheduleMode']), [
      AndroidScheduleMode.exactAllowWhileIdle.name,
      AndroidScheduleMode.inexactAllowWhileIdle.name,
    ]);
  });

  test('disabled slot does not create a snooze', () async {
    service = NotificationService(
      clock: () => now,
      snoozeContent: (_) async => null,
    );
    await service.handleResponse(action('morning', kSnoozeActionId));
    expect(scheduled(), isEmpty);
  });

  test(
    'refresh preserves enabled snoozes, removes stale routines and disabled snoozes',
    () async {
      pending = [
        {'id': 10001, 'title': 'snooze', 'body': '', 'payload': 'morning'},
        {'id': 10003, 'title': 'snooze', 'body': '', 'payload': 'sleep'},
        {'id': 1200, 'title': 'old routine', 'body': '', 'payload': 'evening'},
      ];
      await service.apply(
        buildSchedule(settings: const ReminderSettings(), now: now),
        (_) => text,
        exactAllowed: true,
      );
      expect(cancelled(), containsAll([10003, 1200]));
      expect(cancelled(), isNot(contains(10001)));
      expect(calls.any((c) => c.method == 'cancelAll'), isFalse);
      expect(scheduled(), hasLength(3));
    },
  );

  test('refreshes are serialized behind an in-flight snooze', () async {
    scheduleGate = Completer<void>();
    final first = service.handleResponse(action('morning', kSnoozeActionId));
    for (var i = 0; i < 100 && scheduled().isEmpty; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(scheduled(), hasLength(1));
    final second = service.apply(
      buildSchedule(settings: const ReminderSettings(), now: now),
      (_) => text,
      exactAllowed: false,
    );
    await Future<void>.delayed(Duration.zero);
    expect(
      calls.where((c) => c.method == 'pendingNotificationRequests'),
      isEmpty,
    );
    scheduleGate!.complete();
    await Future.wait([first, second]);
    expect(scheduled().first['id'], 10001);
    expect(scheduled(), hasLength(4));
  });

  test(
    'cold launch never routes Snooze or invalid payloads to the reader',
    () async {
      for (final payload in ['morning', 'invalid']) {
        launch = {
          'notificationLaunchedApp': true,
          'notificationResponse': {
            'id': 1,
            'payload': payload,
            'actionId': kSnoozeActionId,
            'notificationResponseType': 1,
          },
        };
        expect(await service.launchSlot(), isNull);
      }
    },
  );

  test(
    'iOS registers both languages and attaches the category to snoozes',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      IOSFlutterLocalNotificationsPlugin.registerWith();
      service = NotificationService(
        clock: () => now,
        snoozeContent: (_) async => text,
      );
      await service.handleResponse(action('morning', kSnoozeActionId));
      final settings =
          calls.firstWhere((c) => c.method == 'initialize').arguments as Map;
      final categories = settings['notificationCategories'] as List;
      expect(categories.map((c) => c['identifier']), [
        'athkar_ar',
        'athkar_en',
      ]);
      expect(
        scheduled().single['platformSpecifics']['categoryIdentifier'],
        'athkar_en',
      );
      final actions = (categories.last as Map)['actions'] as List;
      expect(actions.map((a) => a['identifier']), ['start', 'snooze']);
      expect((actions.last as Map)['options'], isEmpty);
    },
  );

  test(
    'background entry point rebuilds localized content without the UI',
    () async {
      await notificationTapBackground(action('morning', kSnoozeActionId));
      expect(scheduled(), hasLength(1));
      expect(scheduled().single['id'], 10001);
      expect(scheduled().single['body'], isNotEmpty);
      expect(opened, isEmpty);
    },
  );

  test('background action respects persisted disabled settings', () async {
    SharedPreferences.setMockInitialValues({
      'reminders.slot.morning': '6:30:false',
    });
    await notificationTapBackground(action('morning', kSnoozeActionId));
    expect(scheduled(), isEmpty);
  });
}
