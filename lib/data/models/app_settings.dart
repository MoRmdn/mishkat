import 'package:flutter/material.dart';

import '../../core/theme/palettes.dart';

enum AppearanceMode {
  light,
  dark,
  system;

  static AppearanceMode fromName(String? n) => AppearanceMode.values.firstWhere(
    (m) => m.name == n,
    orElse: () => AppearanceMode.system,
  );

  ThemeMode get themeMode => switch (this) {
    AppearanceMode.light => ThemeMode.light,
    AppearanceMode.dark => ThemeMode.dark,
    AppearanceMode.system => ThemeMode.system,
  };
}

enum AppLanguage {
  ar,
  en;

  static AppLanguage fromName(String? n) => AppLanguage.values.firstWhere(
    (l) => l.name == n,
    orElse: () => AppLanguage.ar,
  );

  Locale get locale => Locale(name);
  bool get isRtl => this == AppLanguage.ar;
}

/// Reader text size. The design uses three steps: 20 / 24 / 29 logical pixels.
enum ThikrTextSize {
  small(20),
  medium(24),
  large(29);

  const ThikrTextSize(this.fontSize);

  final double fontSize;

  static ThikrTextSize fromIndex(int? i) =>
      ThikrTextSize.values[(i ?? 1).clamp(0, ThikrTextSize.values.length - 1)];

  /// Long athkar step down one size rather than overflowing — the prototype
  /// drops 5px past 150 characters.
  double sizeFor(String text) => text.length > 150 ? fontSize - 5 : fontSize;
}

@immutable
class AppSettings {
  const AppSettings({
    this.palette = AppPalette.teal,
    this.appearance = AppearanceMode.system,
    this.language = AppLanguage.ar,
    this.textSize = ThikrTextSize.medium,
    this.useQuranFont = true,
    this.onboardingComplete = false,
  });

  final AppPalette palette;
  final AppearanceMode appearance;
  final AppLanguage language;
  final ThikrTextSize textSize;
  final bool useQuranFont;
  final bool onboardingComplete;

  AppSettings copyWith({
    AppPalette? palette,
    AppearanceMode? appearance,
    AppLanguage? language,
    ThikrTextSize? textSize,
    bool? useQuranFont,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      palette: palette ?? this.palette,
      appearance: appearance ?? this.appearance,
      language: language ?? this.language,
      textSize: textSize ?? this.textSize,
      useQuranFont: useQuranFont ?? this.useQuranFont,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
