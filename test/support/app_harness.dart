import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/app.dart';
import 'package:mishkat/core/clock.dart';
import 'package:mishkat/data/models/reminder_settings.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/athkar_repository.dart';
import 'package:mishkat/features/reminders/reminder_controller.dart';
import 'package:mishkat/features/settings/settings_controller.dart';
import 'package:mishkat/services/notification_service.dart';
import 'package:mishkat/services/permission_service.dart';
import 'package:mishkat/services/reminder_scheduler.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

/// Records what would have been scheduled, without touching the OS.
class FakeNotificationService implements NotificationService {
  final List<ReminderSchedule> applied = [];
  bool cancelled = false;
  ReminderSlotId? launchedFrom;
  ReminderTapHandler? tapHandler;

  @override
  set onTap(ReminderTapHandler handler) => tapHandler = handler;

  @override
  Future<void> init() async {}

  @override
  Future<void> syncTimeZone() async {}

  @override
  String get currentTimeZone => 'UTC';

  @override
  Future<void> apply(
    ReminderSchedule schedule,
    ReminderContentBuilder content, {
    required bool exactAllowed,
  }) async {
    applied.add(schedule);
    lastExactAllowed = exactAllowed;
    // Exercise the content builder so a broken string blows up in tests too.
    for (final entry in schedule.entries) {
      content(entry.slot);
    }
  }

  bool? lastExactAllowed;

  @override
  Future<int> pendingCount() async =>
      applied.isEmpty ? 0 : applied.last.pendingCount;

  @override
  Future<void> cancelAll() async => cancelled = true;

  @override
  Future<ReminderSlotId?> launchSlot() async => launchedFrom;
}

/// Permissions the test decides, rather than the platform.
class FakePermissionService implements PermissionService {
  FakePermissionService({
    this.notifications = true,
    this.exactAlarms = true,
    this.batteryExempt = true,
    this.vendor = 'Xiaomi',
  });

  bool notifications, exactAlarms, batteryExempt;
  String vendor;

  @override
  Future<PermissionState> read() async => PermissionState(
    notifications: notifications,
    exactAlarms: exactAlarms,
    batteryExempt: batteryExempt,
    manufacturer: vendor,
  );

  @override
  Future<bool> requestNotifications() async => notifications = true;

  @override
  Future<bool> requestExactAlarms() async => exactAlarms = true;

  @override
  Future<bool> requestBatteryExemption() async => batteryExempt = true;

  @override
  Future<String> manufacturer() async => vendor;
}

class FakeWakelock extends WakelockPlusPlatformInterface
    with MockPlatformInterfaceMixin {
  /// Read synchronously by tests; the plugin API is async.
  bool isOn = false;

  @override
  Future<void> toggle({required bool enable}) async => isOn = enable;

  @override
  Future<bool> get enabled async => isOn;
}

/// Everything a widget test needs, wired once.
class AppHarness {
  AppHarness({
    FakeNotificationService? notifications,
    FakePermissionService? permissions,
  }) : notifications = notifications ?? FakeNotificationService(),
       permissions = permissions ?? FakePermissionService();

  final FakeNotificationService notifications;
  final FakePermissionService permissions;
  final FakeWakelock wakelock = FakeWakelock();

  bool get screenAwake => wakelock.isOn;

  static late AthkarLibrary library;

  /// Loads the athkar corpus once for the whole test file.
  static Future<void> loadLibrary() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    library = await AthkarRepository().load();
  }

  Future<void> pump(
    WidgetTester tester, {
    String language = 'ar',
    String palette = 'teal',
    String appearance = 'light',
    bool onboardingComplete = true,
    DateTime? now,
    Map<String, Object> extraPrefs = const {},

    /// Pass false to relaunch against whatever the previous pump left in the
    /// store — that is what makes a persistence test meaningful.
    bool resetPrefs = true,
  }) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    // Dispose the tree while this test's fakes are still installed.
    addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

    // WakelockPlus caches its platform object in a top-level variable on first
    // read, so this — not WakelockPlusPlatformInterface.instance — is the hook
    // that actually works per test.
    wakelockPlusPlatformInstance = wakelock;

    SharedPreferences.setMockInitialValues({
      'flutter.settings.language': language,
      'flutter.settings.palette': palette,
      'flutter.settings.appearance': appearance,
      'flutter.settings.onboardingComplete': onboardingComplete,
      for (final e in extraPrefs.entries) 'flutter.${e.key}': e.value,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Preloaded: otherwise pumpAndSettle races the asset read and
          // settles on an empty screen.
          athkarLibraryProvider.overrideWith((ref) => library),
          notificationServiceProvider.overrideWithValue(notifications),
          permissionServiceProvider.overrideWithValue(permissions),
          clockProvider.overrideWithValue(
            () => now ?? DateTime(2026, 9, 7, 3, 18),
          ),
        ],
        child: const MishkatApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}

TextDirection shellDirection(WidgetTester tester) =>
    Directionality.of(tester.element(find.byType(Scaffold).first));
