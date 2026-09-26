import 'package:flutter/foundation.dart';

/// The segmented control on the feedback sheet: «اقتراح ميزة · خطأ في ذكر ·
/// مشكلة في التطبيق».
enum FeedbackType {
  feature,
  thikr,
  bug;

  static FeedbackType? fromName(Object? n) =>
      values.where((t) => t.name == n).firstOrNull;
}

/// «جديدة · قيد المراجعة · تم الرد · مغلقة». Only the owner changes it; a
/// reply from the owner sets [answered].
enum FeedbackStatus {
  /// Stored as `new`, which Dart reserves.
  open('new'),
  inReview('inReview'),
  answered('answered'),
  closed('closed');

  const FeedbackStatus(this.key);

  final String key;

  static FeedbackStatus fromKey(Object? k) =>
      values.where((s) => s.key == k).firstOrNull ?? FeedbackStatus.open;
}

/// What is wrong with a reported thikr. Several can be picked.
enum ThikrIssue {
  text,
  source,
  count,
  translation;

  static ThikrIssue? fromName(Object? n) =>
      values.where((i) => i.name == n).firstOrNull;
}

/// Attached only when the "device information" switch is on, and shown to
/// the sender exactly as sent.
@immutable
class DeviceDetails {
  const DeviceDetails({
    required this.appVersion,
    required this.platform,
    required this.language,
  });

  /// `1.2.0 (34)`.
  final String appVersion;

  /// `Android 14 · Pixel 7`.
  final String platform;

  /// The app language, `ar` or `en`.
  final String language;

  Map<String, Object?> toJson() => {
    'appVersion': appVersion,
    'platform': platform,
    'language': language,
  };

  static DeviceDetails? fromJson(Map<String, Object?> j) {
    final v = j['appVersion'], p = j['platform'], l = j['language'];
    if (v is! String || p is! String || l is! String) return null;
    return DeviceDetails(appVersion: v, platform: p, language: l);
  }
}

/// A message written on the device and not yet on the server.
///
/// Its [id] is generated up front and becomes the Firestore document id, so
/// sending it twice can only ever create one thread.
@immutable
class FeedbackDraft {
  const FeedbackDraft({
    required this.id,
    required this.type,
    required this.body,
    required this.createdAt,
    this.issues = const {},
    this.thikrId,
    this.contentVersion,
    this.contactEmail,
    this.device,
  });

  final String id;
  final FeedbackType type;
  final String body;
  final DateTime createdAt;
  final Set<ThikrIssue> issues;
  final String? thikrId;

  /// Which edition of athkar.json the reporter was reading.
  final String? contentVersion;
  final String? contactEmail;
  final DeviceDetails? device;

  static const maxBody = 1000;
  static const minBody = 10;

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'body': body,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'issues': [for (final i in issues) i.name],
    'thikrId': thikrId,
    'contentVersion': contentVersion,
    'contactEmail': contactEmail,
    'device': device?.toJson(),
  };

  static FeedbackDraft? fromJson(Map<String, Object?> j) {
    final id = j['id'], body = j['body'], at = j['createdAt'];
    final type = FeedbackType.fromName(j['type']);
    if (id is! String || body is! String || at is! int || type == null) {
      return null;
    }
    final device = j['device'];
    return FeedbackDraft(
      id: id,
      type: type,
      body: body,
      createdAt: DateTime.fromMillisecondsSinceEpoch(at),
      issues: {
        for (final i in (j['issues'] as List?) ?? const [])
          ?ThikrIssue.fromName(i),
      },
      thikrId: j['thikrId'] as String?,
      contentVersion: j['contentVersion'] as String?,
      contactEmail: j['contactEmail'] as String?,
      device: device is Map
          ? DeviceDetails.fromJson(device.cast<String, Object?>())
          : null,
    );
  }
}

/// One conversation: the first message's metadata plus its state.
@immutable
class FeedbackThread {
  const FeedbackThread({
    required this.id,
    required this.uid,
    required this.type,
    required this.status,
    required this.preview,
    required this.createdAt,
    required this.updatedAt,
    this.issues = const {},
    this.thikrId,
    this.contentVersion,
    this.contactEmail,
    this.device,
    this.number,
    this.unreadForUser = false,
    this.unreadForAdmin = false,
    this.closedAt,
    this.queued = false,
  });

  final String id;
  final String uid;
  final FeedbackType type;
  final FeedbackStatus status;

  /// The first line of the first message, for lists.
  final String preview;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Set<ThikrIssue> issues;
  final String? thikrId;
  final String? contentVersion;
  final String? contactEmail;
  final DeviceDetails? device;

  /// «رسالة #١٠٤». Given by the owner's device on first open; null before.
  final int? number;
  final bool unreadForUser;
  final bool unreadForAdmin;
  final DateTime? closedAt;

  /// Still in this device's outbox: «بانتظار الاتصال».
  final bool queued;

  bool get isClosed => status == FeedbackStatus.closed;

  factory FeedbackThread.fromDraft(FeedbackDraft d) => FeedbackThread(
    id: d.id,
    uid: '',
    type: d.type,
    status: FeedbackStatus.open,
    preview: previewOf(d.body),
    createdAt: d.createdAt,
    updatedAt: d.createdAt,
    issues: d.issues,
    thikrId: d.thikrId,
    contentVersion: d.contentVersion,
    contactEmail: d.contactEmail,
    device: d.device,
    queued: true,
  );

  static String previewOf(String body) {
    final line = body.trim().split('\n').first.trim();
    return line.length <= 140 ? line : '${line.substring(0, 140)}…';
  }
}

enum MessageAuthor { user, admin }

@immutable
class FeedbackMessage {
  const FeedbackMessage({
    required this.id,
    required this.from,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final MessageAuthor from;
  final String body;
  final DateTime createdAt;
}

/// Unread replies for the Home dot and the settings rows.
@immutable
class FeedbackBadges {
  const FeedbackBadges({this.userUnread = 0, this.adminUnread = 0});

  /// Threads with a team reply the sender has not opened.
  final int userUnread;

  /// Threads with a user message the owner has not opened. Always 0 for
  /// anyone who is not the owner.
  final int adminUnread;

  bool get any => userUnread > 0 || adminUnread > 0;

  static const none = FeedbackBadges();
}
