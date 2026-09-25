import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// The app's version and the device, for the About group and for feedback
/// sent with device information switched on.
class AppInfo {
  const AppInfo({required this.version, required this.platform});

  /// `1.2.0 (34)`.
  final String version;

  /// `Android 14 · Pixel 7`, `iOS 18.2 · iPhone`.
  final String platform;

  static Future<AppInfo> load() async {
    final package = await PackageInfo.fromPlatform();
    final version = package.buildNumber.isEmpty
        ? package.version
        : '${package.version} (${package.buildNumber})';
    final device = DeviceInfoPlugin();
    String platform;
    try {
      if (Platform.isAndroid) {
        final a = await device.androidInfo;
        platform = 'Android ${a.version.release} · ${a.model}';
      } else if (Platform.isIOS) {
        final i = await device.iosInfo;
        platform = '${i.systemName} ${i.systemVersion} · ${i.model}';
      } else {
        platform = Platform.operatingSystem;
      }
    } catch (_) {
      platform = Platform.operatingSystem;
    }
    return AppInfo(version: version, platform: platform);
  }
}

final appInfoProvider = FutureProvider<AppInfo>((ref) => AppInfo.load());
