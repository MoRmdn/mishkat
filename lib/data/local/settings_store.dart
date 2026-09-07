import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/palettes.dart';
import '../models/app_settings.dart';

/// Reads and writes [AppSettings] to shared preferences.
///
/// Deliberately synchronous on read: [SharedPreferences] is loaded once during
/// bootstrap so the very first frame already has the right theme and language,
/// with no flash of the wrong appearance.
class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kPalette = 'settings.palette';
  static const _kAppearance = 'settings.appearance';
  static const _kLanguage = 'settings.language';
  static const _kTextSize = 'settings.textSize';
  static const _kQuranFont = 'settings.quranFont';
  static const _kOnboarding = 'settings.onboardingComplete';

  AppSettings read() => AppSettings(
    palette: AppPalette.fromName(_prefs.getString(_kPalette)),
    appearance: AppearanceMode.fromName(_prefs.getString(_kAppearance)),
    language: AppLanguage.fromName(_prefs.getString(_kLanguage)),
    textSize: ThikrTextSize.fromIndex(_prefs.getInt(_kTextSize)),
    useQuranFont: _prefs.getBool(_kQuranFont) ?? true,
    onboardingComplete: _prefs.getBool(_kOnboarding) ?? false,
  );

  Future<void> write(AppSettings s) async {
    await Future.wait([
      _prefs.setString(_kPalette, s.palette.name),
      _prefs.setString(_kAppearance, s.appearance.name),
      _prefs.setString(_kLanguage, s.language.name),
      _prefs.setInt(_kTextSize, s.textSize.index),
      _prefs.setBool(_kQuranFont, s.useQuranFont),
      _prefs.setBool(_kOnboarding, s.onboardingComplete),
    ]);
  }
}
