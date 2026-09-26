import 'package:flutter/material.dart';

import '../../core/theme/mishkat_tokens.dart';

export '../../core/theme/mishkat_tokens.dart' show ThikrSize;

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

@immutable
class AppSettings {
  const AppSettings({
    this.appearance = AppearanceMode.system,
    this.language = AppLanguage.ar,
    this.textSize = ThikrSize.medium,
    this.useQuranFont = false,
    this.onboardingComplete = false,
  });

  final AppearanceMode appearance;
  final AppLanguage language;
  final ThikrSize textSize;
  final bool useQuranFont;
  final bool onboardingComplete;

  AppSettings copyWith({
    AppearanceMode? appearance,
    AppLanguage? language,
    ThikrSize? textSize,
    bool? useQuranFont,
    bool? onboardingComplete,
  }) {
    return AppSettings(
      appearance: appearance ?? this.appearance,
      language: language ?? this.language,
      textSize: textSize ?? this.textSize,
      useQuranFont: useQuranFont ?? this.useQuranFont,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
