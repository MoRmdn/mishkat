import 'package:flutter/painting.dart';

import 'mishkat_tokens.dart';

/// Brand colours used outside the widget tree — native launch screens, the
/// launcher icon and notification chrome — named by role and defined as
/// token values, so the identity has one source of truth.
///
/// Native files cannot import Dart, so they carry copies:
/// `android/app/src/main/res/values/colors.xml` and the
/// `flutter_native_splash` block of `pubspec.yaml`. `test/branding_test.dart`
/// fails if either drifts from these.
abstract final class BrandColors {
  /// Notification accent tint; the adaptive icon's background.
  static Color get primary => MishkatTokens.light.primary;

  /// The launcher icon's arch; the light launch screen.
  static Color get launchLight => MishkatTokens.light.bg;

  /// The dark launch screen.
  static Color get launchDark => MishkatTokens.dark.bg;

  /// The launcher icon's lamp.
  static Color get lamp => MishkatTokens.light.glow;

  static Color get notificationAccent => primary;
}
