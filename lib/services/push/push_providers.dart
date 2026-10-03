import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/settings_controller.dart';
import '../../features/update/update_controller.dart';
import '../auth/auth_service.dart';
import 'announcement_repository.dart';
import 'push_models.dart';
import 'push_service.dart';

// Device preferences, never synced: whether this phone wants announcements
// and how far it has read is a property of the phone, not the account.
const _kAnnouncementsOn = 'push.announcements';
const _kSeenUpTo = 'push.announcementsSeenAt';
const _kDeviceId = 'push.deviceId';

/// The latest announcements, newest first. Empty offline with nothing
/// cached, and when Firebase did not start.
final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  if (!ref.watch(cloudAvailableProvider)) return const [];
  try {
    return await ref.watch(announcementRepositoryProvider).latest();
  } catch (e) {
    debugPrint('Announcements unavailable: $e');
    return const [];
  }
});

/// The newest announcement the user has seen on the notifications page.
class AnnouncementsSeen extends Notifier<DateTime?> {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  DateTime? build() => switch (_prefs.getInt(_kSeenUpTo)) {
    final int ms => DateTime.fromMillisecondsSinceEpoch(ms),
    null => null,
  };

  /// Stamps the newest announcement's own time — not the phone's clock, which
  /// may be ahead of the server's and would hide the next one.
  void markSeen(List<Announcement> list) {
    if (list.isEmpty) return;
    final newest = list
        .map((a) => a.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    if (state != null && !newest.isAfter(state!)) return;
    state = newest;
    _prefs.setInt(_kSeenUpTo, newest.millisecondsSinceEpoch);
  }
}

final announcementsSeenProvider =
    NotifierProvider<AnnouncementsSeen, DateTime?>(AnnouncementsSeen.new);

/// The bell's dot on Home.
final announcementsUnreadProvider = Provider<bool>(
  (ref) => hasUnreadAnnouncements(
    ref.watch(announcementsProvider).value ?? const [],
    ref.watch(announcementsSeenProvider),
  ),
);

/// Whether this phone subscribes to announcement pushes. iOS has no
/// per-channel mute, so without this the only way to silence announcements
/// would be to silence reminders too. The page lists them either way.
class AnnouncementPushSetting extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(_kAnnouncementsOn) ?? true;

  void set(bool on) {
    state = on;
    ref.read(sharedPreferencesProvider).setBool(_kAnnouncementsOn, on);
  }
}

final announcementPushProvider =
    NotifierProvider<AnnouncementPushSetting, bool>(
      AnnouncementPushSetting.new,
    );

/// A random id for this install, made once: the document name under
/// `users/{uid}/devices`, so reinstalling or a new token replaces rather
/// than accumulates.
final pushDeviceIdProvider = Provider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final existing = prefs.getString(_kDeviceId);
  if (existing != null) return existing;
  final random = Random.secure();
  final id = base64Url
      .encode([for (var i = 0; i < 16; i++) random.nextInt(256)])
      .replaceAll('=', '');
  prefs.setString(_kDeviceId, id);
  return id;
});

/// Keeps FCM in step with the app: the topic for the chosen language, and
/// this device's token under whichever account can receive replies.
class PushRegistration {
  PushRegistration(this._ref);

  final Ref _ref;

  PushService get _push => _ref.read(pushServiceProvider);
  AnnouncementRepository get _repo => _ref.read(announcementRepositoryProvider);

  /// What was last written, so a resume with nothing changed writes nothing.
  String? _registered;

  /// Subscribes to the app language's announcements and leaves the other's,
  /// or leaves both when announcements are off. Best-effort: iOS refuses
  /// until APNs has answered, and the next launch or token refresh retries.
  Future<void> syncTopics() async {
    if (!_ref.read(cloudAvailableProvider)) return;
    final on = _ref.read(announcementPushProvider);
    final lang = _ref.read(settingsProvider).language.name;
    for (final l in kAnnouncementLanguages) {
      final topic = announcementTopic(l);
      try {
        if (on && l == lang) {
          await _push.subscribe(topic);
        } else {
          await _push.unsubscribe(topic);
        }
      } catch (e) {
        debugPrint('FCM topic $topic not updated: $e');
      }
    }
  }

  /// Records this device under the current account — anonymous included,
  /// since that is who sent the feedback a reply answers. [token] is the
  /// one [PushService.onTokenRefresh] just delivered, if any.
  Future<void> registerDevice({String? token}) async {
    if (!_ref.read(cloudAvailableProvider)) return;
    if (_ref.read(updateBlocksWritesProvider)) return;
    final uid = _ref.read(accountProvider).uid;
    if (uid == null) return;
    final t = token ?? await _push.token();
    if (t == null) return;
    final lang = _ref.read(settingsProvider).language.name;
    final key = '$uid|$t|$lang';
    if (key == _registered) return;
    try {
      await _repo.registerDevice(
        uid,
        _ref.read(pushDeviceIdProvider),
        token: t,
        languageCode: lang,
        platform: _push.platform,
      );
      _registered = key;
    } catch (e) {
      debugPrint('Device not registered for replies: $e');
    }
  }

  /// Before signing out: replies to that account stop reaching this phone.
  Future<void> unregisterDevice() async {
    final uid = _ref.read(accountProvider).uid;
    _registered = null;
    if (uid == null || !_ref.read(cloudAvailableProvider)) return;
    try {
      await _repo.removeDevice(uid, _ref.read(pushDeviceIdProvider));
    } catch (e) {
      debugPrint('Device not removed: $e');
    }
  }
}

final pushRegistrationProvider = Provider<PushRegistration>(
  PushRegistration.new,
);

/// Re-reads the announcements. Called on resume, on pull-to-refresh and
/// when a push arrives with the app open.
void refreshAnnouncements(WidgetRef ref) =>
    ref.invalidate(announcementsProvider);
