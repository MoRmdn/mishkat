import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/palettes.dart';
import '../models/app_settings.dart';
import '../models/reminder_settings.dart';

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
  static const _kReminderMode = 'reminders.mode';
  static String _slotKey(ReminderSlotId id) => 'reminders.slot.${id.key}';

  AppSettings read() => AppSettings(
    palette: AppPalette.fromName(_prefs.getString(_kPalette)),
    appearance: AppearanceMode.fromName(_prefs.getString(_kAppearance)),
    language: AppLanguage.fromName(_prefs.getString(_kLanguage)),
    textSize: ThikrTextSize.fromIndex(_prefs.getInt(_kTextSize)),
    useQuranFont: _prefs.getBool(_kQuranFont) ?? true,
    onboardingComplete: _prefs.getBool(_kOnboarding) ?? false,
  );

  /// Reminder slots are stored as `hour:minute:enabled` — compact, readable in
  /// a prefs dump, and trivially forward-compatible.
  ReminderSettings readReminders() {
    return ReminderSettings(
      mode: ReminderMode.fromName(_prefs.getString(_kReminderMode)),
      slots: [
        for (final fallback in ReminderSettings.defaultSlots)
          _decodeSlot(_prefs.getString(_slotKey(fallback.id)), fallback),
      ],
    );
  }

  static ReminderSlot _decodeSlot(String? raw, ReminderSlot fallback) {
    if (raw == null) return fallback;
    final parts = raw.split(':');
    if (parts.length != 3) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59)
      return fallback;
    return fallback.copyWith(
      hour: hour,
      minute: minute,
      enabled: parts[2] == 'true',
    );
  }

  Future<void> writeReminders(ReminderSettings r) async {
    await _prefs.setString(_kReminderMode, r.mode.name);
    for (final slot in r.slots) {
      await _prefs.setString(
        _slotKey(slot.id),
        '${slot.hour}:${slot.minute}:${slot.enabled}',
      );
    }
  }

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
