import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

/// What the app is currently allowed to do. Every field can be false and the
/// app still works — each denial degrades rather than blocks.
@immutable
class PermissionState {
  const PermissionState({
    this.notifications = false,
    this.exactAlarms = false,
    this.batteryExempt = false,
    this.manufacturer = '',
  });

  final bool notifications;

  /// Android 12+. When false, reminders may land a few minutes late and the
  /// reminders tab shows a persistent notice saying so.
  final bool exactAlarms;

  final bool batteryExempt;

  /// Used to pick the right OEM guidance ("Xiaomi · MIUI", etc.).
  final String manufacturer;

  PermissionState copyWith({
    bool? notifications,
    bool? exactAlarms,
    bool? batteryExempt,
    String? manufacturer,
  }) => PermissionState(
    notifications: notifications ?? this.notifications,
    exactAlarms: exactAlarms ?? this.exactAlarms,
    batteryExempt: batteryExempt ?? this.batteryExempt,
    manufacturer: manufacturer ?? this.manufacturer,
  );
}

/// Manufacturers known to kill background apps aggressively enough that
/// scheduled alarms are dropped.
const Set<String> kAggressiveOems = {
  'xiaomi',
  'redmi',
  'poco',
  'huawei',
  'honor',
  'oppo',
  'realme',
  'oneplus',
  'vivo',
  'samsung',
  'meizu',
  'asus',
};

class PermissionService {
  PermissionService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<PermissionState> read() async {
    if (!_isMobile) return const PermissionState();

    final notifications = await Permission.notification.isGranted;
    final exact = Platform.isAndroid
        ? (await _android?.canScheduleExactNotifications() ?? false)
        // iOS has no equivalent restriction: scheduled local notifications
        // always fire at the requested time.
        : true;
    final battery = Platform.isAndroid
        ? await Permission.ignoreBatteryOptimizations.isGranted
        : true;

    return PermissionState(
      notifications: notifications,
      exactAlarms: exact,
      batteryExempt: battery,
      manufacturer: await manufacturer(),
    );
  }

  Future<bool> requestNotifications() async {
    if (!_isMobile) return false;
    if (Platform.isIOS) {
      return await _ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return await _android?.requestNotificationsPermission() ?? false;
  }

  /// Requests `SCHEDULE_EXACT_ALARM`.
  ///
  /// Never `USE_EXACT_ALARM`: Google Play restricts that to alarm, clock and
  /// calendar apps, and an athkar app claiming it risks rejection.
  Future<bool> requestExactAlarms() async {
    if (!_isMobile || !Platform.isAndroid) return true;
    await _android?.requestExactAlarmsPermission();
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  Future<bool> requestBatteryExemption() async {
    if (!_isMobile || !Platform.isAndroid) return true;
    final status = await Permission.ignoreBatteryOptimizations.request();
    return status.isGranted;
  }

  Future<String> manufacturer() async {
    if (!_isMobile || !Platform.isAndroid) return '';
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.manufacturer;
    } catch (_) {
      return '';
    }
  }

  /// Whether this device's vendor is known to need the extra autostart steps.
  static bool needsOemGuidance(String manufacturer) =>
      kAggressiveOems.contains(manufacturer.trim().toLowerCase());

  bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
