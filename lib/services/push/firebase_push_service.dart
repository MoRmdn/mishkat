import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'push_models.dart';
import 'push_service.dart';

/// [PushService] on `firebase_messaging`.
///
/// Notification messages are drawn by the OS while the app is in the
/// background or killed, on the channel `functions/` names; there is no
/// background Dart handler because the app has nothing to do until tapped.
class FirebasePushService implements PushService {
  FirebasePushService([FirebaseMessaging? messaging])
    : _fcm = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _fcm;
  bool _started = false;

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;
    // In the foreground the app updates its own dots; no banner over it.
    await _fcm.setForegroundNotificationPresentationOptions();
  }

  @override
  Future<String?> token() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      // iOS throws until APNs has handed over its token; onTokenRefresh
      // brings it once it has.
      debugPrint('FCM token not ready: $e');
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  @override
  Future<void> subscribe(String topic) => _fcm.subscribeToTopic(topic);

  @override
  Future<void> unsubscribe(String topic) => _fcm.unsubscribeFromTopic(topic);

  @override
  Stream<PushMessage> get onForeground => FirebaseMessaging.onMessage
      .map(_parse)
      .where((m) => m != null)
      .cast<PushMessage>();

  @override
  Stream<PushMessage> get onOpened => FirebaseMessaging.onMessageOpenedApp
      .map(_parse)
      .where((m) => m != null)
      .cast<PushMessage>();

  @override
  Future<PushMessage?> initialMessage() async {
    final message = await _fcm.getInitialMessage();
    return message == null ? null : _parse(message);
  }

  @override
  String get platform => Platform.isIOS ? 'ios' : 'android';

  static PushMessage? _parse(RemoteMessage m) => PushMessage.fromData(m.data);
}
