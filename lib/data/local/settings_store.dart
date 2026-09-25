import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/prayer_settings.dart';
import '../models/reminder_settings.dart';

/// Reads and writes [AppSettings] to shared preferences.
///
/// Deliberately synchronous on read: [SharedPreferences] is loaded once during
/// bootstrap so the very first frame already has the right theme and language,
/// with no flash of the wrong appearance.
class SettingsStore {
  SettingsStore(this._prefs);

  final SharedPreferences _prefs;

  /// Retired with the three-palette themes in the 2a redesign. Only
  /// [migrate] reads it, to delete it.
  static const _kLegacyPalette = 'settings.palette';
  static const _kAppearance = 'settings.appearance';
  static const _kLanguage = 'settings.language';
  static const _kTextSize = 'settings.textSize';
  static const _kQuranFont = 'settings.quranFont';
  static const _kOnboarding = 'settings.onboardingComplete';
  static const _kReminderMode = 'reminders.mode';
  static String _slotKey(ReminderSlotId id) => 'reminders.slot.${id.key}';
  static const _kPrayerMethod = 'prayer.method';
  static const _kPrayerMadhab = 'prayer.madhab';
  static const _kPrayerUseDevice = 'prayer.useDeviceLocation';
  static const _kPrayerCity = 'prayer.manualCity';
  static const _kPrayerLat = 'prayer.latitude';
  static const _kPrayerLng = 'prayer.longitude';

  PrayerSettings readPrayer() => PrayerSettings(
    method: PrayerCalculationMethod.fromName(_prefs.getString(_kPrayerMethod)),
    madhab: AsrMadhab.fromName(_prefs.getString(_kPrayerMadhab)),
    useDeviceLocation: _prefs.getBool(_kPrayerUseDevice) ?? true,
    manualCityId: _prefs.getString(_kPrayerCity) ?? 'makkah',
    latitude: _prefs.getDouble(_kPrayerLat),
    longitude: _prefs.getDouble(_kPrayerLng),
  );

  Future<void> writePrayer(PrayerSettings p) async {
    await _prefs.setString(_kPrayerMethod, p.method.name);
    await _prefs.setString(_kPrayerMadhab, p.madhab.name);
    await _prefs.setBool(_kPrayerUseDevice, p.useDeviceLocation);
    await _prefs.setString(_kPrayerCity, p.manualCityId);
    // Caching the last fix means prayer mode still works before, or without, a
    // fresh position.
    if (p.latitude != null) await _prefs.setDouble(_kPrayerLat, p.latitude!);
    if (p.longitude != null) await _prefs.setDouble(_kPrayerLng, p.longitude!);
  }

  /// One-time clean-up of keys earlier versions wrote. Idempotent, and never
  /// touches a preference the current version still reads.
  Future<void> migrate() async {
    if (_prefs.containsKey(_kLegacyPalette)) {
      await _prefs.remove(_kLegacyPalette);
    }
  }

  AppSettings read() => AppSettings(
    appearance: AppearanceMode.fromName(_prefs.getString(_kAppearance)),
    language: AppLanguage.fromName(_prefs.getString(_kLanguage)),
    textSize: ThikrSize.fromIndex(_prefs.getInt(_kTextSize)),
    // Scheherazade New is the default athkar face since the redesign; a user
    // who chose either option keeps their choice.
    useQuranFont: _prefs.getBool(_kQuranFont) ?? false,
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
    if (raw == null) {
      return fallback;
    }
    final parts = raw.split(':');
    if (parts.length != 3) {
      return fallback;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return fallback;
    }
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

  // ---- account sync ----
  //
  // Per-group "last changed" stamps for last-writer-wins, as milliseconds
  // since the epoch. Absent until the user first changes that group, so a
  // fresh install adopts an account's settings instead of overwriting them.

  static String _stampKey(String group) => 'sync.updatedAt.$group';
  static String _cursorKey(String uid) => 'sync.completionsCursor.$uid';
  static const _kLastSync = 'sync.lastSyncAt';
  static const _kNudgeDismissed = 'nudge.saveStreak.dismissedAt';

  DateTime? syncStamp(String group) => _date(_prefs.getInt(_stampKey(group)));

  Future<void> setSyncStamp(String group, DateTime at) =>
      _prefs.setInt(_stampKey(group), at.millisecondsSinceEpoch);

  /// Server time of the newest completion pulled for [uid].
  DateTime? completionsCursor(String uid) =>
      _date(_prefs.getInt(_cursorKey(uid)));

  Future<void> setCompletionsCursor(String uid, DateTime at) =>
      _prefs.setInt(_cursorKey(uid), at.millisecondsSinceEpoch);

  DateTime? get lastSyncAt => _date(_prefs.getInt(_kLastSync));

  Future<void> setLastSyncAt(DateTime? at) => at == null
      ? _prefs.remove(_kLastSync)
      : _prefs.setInt(_kLastSync, at.millisecondsSinceEpoch);

  /// When the "save your streak" card on Progress was last dismissed.
  DateTime? get streakNudgeDismissedAt =>
      _date(_prefs.getInt(_kNudgeDismissed));

  Future<void> dismissStreakNudge(DateTime at) =>
      _prefs.setInt(_kNudgeDismissed, at.millisecondsSinceEpoch);

  // ---- app updates ----

  static const _kUpdatePromptedVersion = 'update.prompted.version';
  static const _kUpdatePromptedAt = 'update.prompted.at';
  static const _kLastSeenVersion = 'update.lastSeenVersion';

  /// The version the optional-update sheet last offered, and when.
  String? get updatePromptedVersion =>
      _prefs.getString(_kUpdatePromptedVersion);
  DateTime? get updatePromptedAt => _date(_prefs.getInt(_kUpdatePromptedAt));

  Future<void> setUpdatePrompted(String version, DateTime at) async {
    await _prefs.setString(_kUpdatePromptedVersion, version);
    await _prefs.setInt(_kUpdatePromptedAt, at.millisecondsSinceEpoch);
  }

  /// The version that last ran, for «تم التحديث إلى…» after an update.
  String? get lastSeenVersion => _prefs.getString(_kLastSeenVersion);

  Future<void> setLastSeenVersion(String version) =>
      _prefs.setString(_kLastSeenVersion, version);

  static DateTime? _date(int? ms) =>
      ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);

  Future<void> write(AppSettings s) async {
    await Future.wait([
      _prefs.setString(_kAppearance, s.appearance.name),
      _prefs.setString(_kLanguage, s.language.name),
      _prefs.setInt(_kTextSize, s.textSize.index),
      _prefs.setBool(_kQuranFont, s.useQuranFont),
      _prefs.setBool(_kOnboarding, s.onboardingComplete),
    ]);
  }
}
