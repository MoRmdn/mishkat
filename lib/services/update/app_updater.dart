import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/store_links.dart';

/// How an immediate update ended, when the app is still running to hear it.
enum ImmediateResult { started, declined, failed }

/// Installs the new version, or sends the user to the store.
///
/// Android uses Play In-App Updates: a flexible download for the optional
/// update and the immediate flow for a required one. It only works for a
/// build installed from Play, so everything falls back to the store page.
/// iOS cannot install an update itself; both buttons open the App Store.
abstract class AppUpdater {
  /// Whether the store is reachable. Cheap; asked before a required update so
  /// the screen can say «لا يوجد اتصال» instead of failing silently.
  Future<bool> isOnline();

  /// Whether Play offers an update this build can install in place.
  Future<bool> canUpdateInApp();

  /// Starts the flexible download. Emits progress in 0–1 when the platform
  /// reports it and null when it does not; completes once the update is
  /// downloaded and errors if it fails or is declined.
  Stream<double?> downloadInBackground();

  /// Installs a downloaded flexible update. The app restarts.
  Future<void> installDownloaded();

  /// The immediate flow. On success the app restarts before this returns.
  Future<ImmediateResult> updateImmediately();

  Future<void> openStorePage();
}

/// Play In-App Updates on Android, the App Store link elsewhere.
class PlatformAppUpdater implements AppUpdater {
  PlatformAppUpdater(this.platform);

  final TargetPlatform platform;

  bool get _android => platform == TargetPlatform.android;

  @override
  Future<bool> isOnline() async {
    try {
      final hosts = await InternetAddress.lookup(
        storePageUri(platform).host,
      ).timeout(const Duration(seconds: 4));
      return hosts.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> canUpdateInApp() async {
    if (!_android) return false;
    try {
      final info = await InAppUpdate.checkForUpdate();
      return info.updateAvailability == UpdateAvailability.updateAvailable ||
          info.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress;
    } catch (e) {
      // Not installed from Play, no Play Store, or Play cannot be reached.
      debugPrint('In-app update unavailable: $e');
      return false;
    }
  }

  @override
  Stream<double?> downloadInBackground() async* {
    // Play reports the state but this plugin does not pass bytes through,
    // so the bar is indeterminate until the download lands.
    yield null;
    final result = await InAppUpdate.startFlexibleUpdate();
    if (result != AppUpdateResult.success) {
      throw StateError('Flexible update ended: $result');
    }
    yield 1;
  }

  @override
  Future<void> installDownloaded() => InAppUpdate.completeFlexibleUpdate();

  @override
  Future<ImmediateResult> updateImmediately() async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      return switch (result) {
        AppUpdateResult.success => ImmediateResult.started,
        AppUpdateResult.userDeniedUpdate => ImmediateResult.declined,
        AppUpdateResult.inAppUpdateFailed => ImmediateResult.failed,
      };
    } catch (_) {
      return ImmediateResult.failed;
    }
  }

  @override
  Future<void> openStorePage() async {
    await launchUrl(
      storePageUri(platform),
      mode: LaunchMode.externalApplication,
    );
  }
}

final appUpdaterProvider = Provider<AppUpdater>(
  (ref) => PlatformAppUpdater(defaultTargetPlatform),
);
