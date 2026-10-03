import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'push_models.dart';

/// Firebase Cloud Messaging, for the owner's announcements and feedback
/// replies only. **Reminders never come through here**: they are local
/// notifications, scheduled on the device, and fire with no network.
///
/// The default does nothing, as when Firebase could not start; `startCloud()`
/// swaps in [FirebasePushService].
abstract class PushService {
  /// Connects the message streams. Safe to call more than once.
  Future<void> start();

  /// This install's FCM token, or null while there is none yet (on iOS,
  /// before APNs has answered) — [onTokenRefresh] delivers it later.
  Future<String?> token();

  Stream<String> get onTokenRefresh;

  Future<void> subscribe(String topic);

  Future<void> unsubscribe(String topic);

  /// A push that arrived while the app was open. The OS shows nothing then;
  /// the app refreshes its dots instead.
  Stream<PushMessage> get onForeground;

  /// A push the user tapped while the app was in the background.
  Stream<PushMessage> get onOpened;

  /// The push the user tapped to launch the app, once.
  Future<PushMessage?> initialMessage();

  /// `ios` or `android`, as `users/{uid}/devices` records it.
  String get platform;
}

class _NoPush implements PushService {
  const _NoPush();

  @override
  Future<void> start() async {}

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Future<void> subscribe(String topic) async {}

  @override
  Future<void> unsubscribe(String topic) async {}

  @override
  Stream<PushMessage> get onForeground => const Stream.empty();

  @override
  Stream<PushMessage> get onOpened => const Stream.empty();

  @override
  Future<PushMessage?> initialMessage() async => null;

  @override
  String get platform => 'android';
}

final pushServiceProvider = Provider<PushService>((ref) => const _NoPush());
