import 'dart:async';

import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/feedback/feedback_models.dart';
import 'package:mishkat/services/feedback/feedback_repository.dart';
import 'package:mishkat/services/sync/sync_models.dart';
import 'package:mishkat/services/sync/sync_remote.dart';
import 'package:mishkat/services/sync/user_profile.dart';
import 'package:mishkat/services/update/app_updater.dart';
import 'package:mishkat/services/update/update_config.dart';

/// Sign-in without Firebase. [nextUser] is who the provider sheet "returns".
class FakeAuthService implements AuthService {
  FakeAuthService({this.initialUser});

  /// Who is signed in when the test starts.
  final AppUser? initialUser;
  late AppUser? _user = initialUser;
  final _changes = StreamController<AppUser?>.broadcast();

  /// Returned by the next [signIn]. Null means the user closes the sheet.
  AppUser? nextUser = const AppUser(
    uid: 'uid-google',
    isAnonymous: false,
    displayName: 'Mohamed Ramadan',
    email: 'mohamed.r@gmail.com',
    provider: AuthProviderKind.google,
  );

  bool online = true;
  int reauthentications = 0;
  bool deleted = false;

  /// Thrown by [deleteUser] in place of deleting.
  Object? deleteError;

  void _set(AppUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  Stream<AppUser?> userChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Future<AppUser> signIn(AuthProviderKind provider) async {
    final next = nextUser;
    if (next == null) throw const SignInCancelled();
    // Linking keeps an anonymous feedback user's uid.
    final user = _user?.isAnonymous == true
        ? AppUser(
            uid: _user!.uid,
            isAnonymous: false,
            displayName: next.displayName,
            email: next.email,
            provider: provider,
          )
        : AppUser(
            uid: next.uid,
            isAnonymous: false,
            displayName: next.displayName,
            email: next.email,
            provider: provider,
          );
    _set(user);
    return user;
  }

  @override
  Future<String> ensureAnonymous() async {
    if (_user != null) return _user!.uid;
    if (!online) throw const AuthOffline();
    _set(const AppUser(uid: 'uid-anon', isAnonymous: true));
    return _user!.uid;
  }

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> reauthenticate() async => reauthentications++;

  @override
  Future<void> deleteUser() async {
    if (deleteError != null) throw deleteError!;
    deleted = true;
    _set(null);
  }
}

/// An account held in memory.
class FakeSyncRemote implements SyncRemote {
  final Map<String, Map<String, SyncCompletion>> completions = {};
  final Map<String, Map<String, SyncFavorite>> favorites = {};
  final Map<String, Map<SyncGroup, SettingsSnapshot>> settings = {};
  final Map<String, UserProfile> profiles = {};
  bool online = true;
  int fetches = 0;

  @override
  Future<RemoteState> fetch(String uid, {DateTime? completionsSince}) async {
    if (!online) throw const SyncOffline();
    fetches++;
    return RemoteState(
      completions: [...?completions[uid]?.values],
      favorites: [...?favorites[uid]?.values],
      settings: {...?settings[uid]},
    );
  }

  @override
  Future<void> putCompletions(String uid, List<SyncCompletion> rows) async {
    final mine = completions.putIfAbsent(uid, () => {});
    for (final c in rows) {
      mine[c.key] = c;
    }
  }

  @override
  Future<void> putFavorites(String uid, List<SyncFavorite> rows) async {
    final mine = favorites.putIfAbsent(uid, () => {});
    for (final f in rows) {
      mine[f.thikrId] = f;
    }
  }

  @override
  Future<void> putSettings(String uid, SettingsSnapshot snapshot) async {
    settings.putIfAbsent(uid, () => {})[snapshot.group] = snapshot;
  }

  @override
  Future<void> putProfile(String uid, UserProfile profile) async {
    profiles[uid] = profile;
  }

  @override
  Future<void> deleteAll(String uid) async {
    if (!online) throw const SyncOffline();
    profiles.remove(uid);
    completions.remove(uid);
    favorites.remove(uid);
    settings.remove(uid);
  }

  bool holds(String uid) =>
      completions.containsKey(uid) ||
      favorites.containsKey(uid) ||
      settings.containsKey(uid) ||
      profiles.containsKey(uid);
}

/// Feedback threads held in memory, following the same rules as
/// firestore.rules for who may change what.
class FakeFeedbackRepository implements FeedbackRepository {
  FakeFeedbackRepository({this.clock});

  final DateTime Function()? clock;
  final Map<String, FeedbackThread> threads = {};
  final Map<String, List<FeedbackMessage>> messageLog = {};
  final Set<String> admins = {};
  bool online = true;

  /// Makes the next submit fail the way a rules rejection would.
  bool rejectNext = false;
  int _next = 104;

  DateTime get _now => clock?.call() ?? DateTime(2026, 9, 25, 9, 36);

  void _online() {
    if (!online) throw const FeedbackOffline();
  }

  /// Seeds a thread as though someone sent it.
  FeedbackThread seed(
    FeedbackThread thread, {
    List<FeedbackMessage> messages = const [],
  }) {
    threads[thread.id] = thread;
    messageLog[thread.id] = [...messages];
    return thread;
  }

  @override
  Future<void> submit(FeedbackDraft d, {required String uid}) async {
    _online();
    if (rejectNext) {
      rejectNext = false;
      throw StateError('permission-denied');
    }
    if (threads.containsKey(d.id)) return;
    threads[d.id] = FeedbackThread(
      id: d.id,
      uid: uid,
      type: d.type,
      status: FeedbackStatus.open,
      preview: FeedbackThread.previewOf(d.body),
      createdAt: d.createdAt,
      updatedAt: d.createdAt,
      issues: d.issues,
      thikrId: d.thikrId,
      contentVersion: d.contentVersion,
      contactEmail: d.contactEmail,
      device: d.device,
      unreadForAdmin: true,
    );
    messageLog[d.id] = [
      FeedbackMessage(
        id: 'first',
        from: MessageAuthor.user,
        body: d.body,
        createdAt: d.createdAt,
      ),
    ];
  }

  List<FeedbackThread> _sorted(Iterable<FeedbackThread> t) =>
      [...t]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Future<List<FeedbackThread>> myThreads(String uid) async {
    _online();
    return _sorted(threads.values.where((t) => t.uid == uid));
  }

  @override
  Future<List<FeedbackThread>> inbox({
    FeedbackType? type,
    FeedbackStatus? status,
  }) async {
    _online();
    return _sorted(
      threads.values.where(
        (t) =>
            (type == null || t.type == type) &&
            (status == null || t.status == status),
      ),
    );
  }

  @override
  Future<FeedbackThread?> thread(String id) async => threads[id];

  @override
  Future<List<FeedbackMessage>> messages(String threadId) async => [
    ...?messageLog[threadId],
  ];

  @override
  Future<void> reply(
    String threadId, {
    required MessageAuthor from,
    required String body,
  }) async {
    _online();
    final t = threads[threadId]!;
    messageLog[threadId]!.add(
      FeedbackMessage(
        id: 'm${messageLog[threadId]!.length}',
        from: from,
        body: body,
        createdAt: _now,
      ),
    );
    threads[threadId] = _copy(
      t,
      updatedAt: _now,
      status: from == MessageAuthor.admin ? FeedbackStatus.answered : null,
      unreadForUser: from == MessageAuthor.admin ? true : null,
      unreadForAdmin: from == MessageAuthor.user ? true : null,
    );
  }

  @override
  Future<void> markRead(
    String threadId, {
    required MessageAuthor reader,
  }) async {
    final t = threads[threadId];
    if (t == null) return;
    threads[threadId] = reader == MessageAuthor.admin
        ? _copy(t, unreadForAdmin: false)
        : _copy(t, unreadForUser: false);
  }

  @override
  Future<void> setStatus(String threadId, FeedbackStatus status) async {
    _online();
    threads[threadId] = _copy(threads[threadId]!, status: status);
  }

  @override
  Future<int?> assignNumber(String threadId) async {
    final t = threads[threadId]!;
    if (t.number != null) return t.number;
    final n = _next++;
    threads[threadId] = _copy(t, number: n);
    return n;
  }

  @override
  Future<FeedbackBadges> badges(String uid, {required bool isAdmin}) async {
    _online();
    return FeedbackBadges(
      userUnread: threads.values
          .where((t) => t.uid == uid && t.unreadForUser)
          .length,
      adminUnread: isAdmin
          ? threads.values.where((t) => t.unreadForAdmin).length
          : 0,
    );
  }

  @override
  Future<bool> isAdmin(String uid) async => admins.contains(uid);

  @override
  Future<void> deleteAllFor(String uid) async {
    final mine = threads.values.where((t) => t.uid == uid).toList();
    for (final t in mine) {
      threads.remove(t.id);
      messageLog.remove(t.id);
    }
  }

  static FeedbackThread _copy(
    FeedbackThread t, {
    FeedbackStatus? status,
    DateTime? updatedAt,
    bool? unreadForUser,
    bool? unreadForAdmin,
    int? number,
  }) => FeedbackThread(
    id: t.id,
    uid: t.uid,
    type: t.type,
    status: status ?? t.status,
    preview: t.preview,
    createdAt: t.createdAt,
    updatedAt: updatedAt ?? t.updatedAt,
    issues: t.issues,
    thikrId: t.thikrId,
    contentVersion: t.contentVersion,
    contactEmail: t.contactEmail,
    device: t.device,
    number: number ?? t.number,
    unreadForUser: unreadForUser ?? t.unreadForUser,
    unreadForAdmin: unreadForAdmin ?? t.unreadForAdmin,
    closedAt: status == FeedbackStatus.closed
        ? updatedAt ?? t.updatedAt
        : t.closedAt,
  );
}

/// Published versions without Remote Config. [cachedConfig] is what the
/// device last activated; [fetched] is what a refresh brings, or null for a
/// fetch that fails (offline) and leaves the cached values.
class FakeUpdateConfigSource implements UpdateConfigSource {
  FakeUpdateConfigSource([this.cachedConfig = UpdateConfig.none]);

  UpdateConfig cachedConfig;
  UpdateConfig? fetched;
  int refreshes = 0;

  @override
  UpdateConfig cached() => cachedConfig;

  @override
  Future<UpdateConfig> refresh() async {
    refreshes++;
    if (fetched != null) cachedConfig = fetched!;
    return cachedConfig;
  }
}

/// Play and the store, recorded. [inApp] false is an iOS device or a build
/// not installed from Play.
class FakeAppUpdater implements AppUpdater {
  bool online = true;
  bool inApp = true;

  /// What the flexible download reports before it completes.
  List<double?> progress = [0.4];

  /// Completes the download; left open, it stays at the last [progress].
  bool finishDownload = true;
  ImmediateResult immediateResult = ImmediateResult.declined;

  int downloads = 0;
  int installs = 0;
  int immediateUpdates = 0;
  int storeOpens = 0;

  @override
  Future<bool> isOnline() async => online;

  @override
  Future<bool> canUpdateInApp() async => inApp;

  @override
  Stream<double?> downloadInBackground() async* {
    downloads++;
    yield* Stream.fromIterable(progress);
    if (!finishDownload) await Completer<void>().future;
  }

  @override
  Future<void> installDownloaded() async => installs++;

  @override
  Future<ImmediateResult> updateImmediately() async {
    immediateUpdates++;
    return immediateResult;
  }

  @override
  Future<void> openStorePage() async => storeOpens++;
}
