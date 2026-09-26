import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../services/app_info.dart';
import '../../services/update/app_updater.dart';
import '../../services/update/app_version.dart';
import '../../services/update/release_notes.dart';
import '../../services/update/update_config.dart';
import '../../services/update/update_policy.dart';
import '../settings/settings_controller.dart';

/// Where an update the user started has got to. The board's states: the
/// Android download card and «أعد التشغيل», the restart splash, and the
/// required screen's updating and offline cards.
enum UpdatePhase { idle, downloading, ready, restarting, updating, offline }

class UpdateState {
  const UpdateState({
    this.decision = const NoUpdate(),
    this.phase = UpdatePhase.idle,
    this.progress,
    this.readingOnly = false,
  });

  final UpdateDecision decision;
  final UpdatePhase phase;

  /// 0–1 while downloading, null when the platform does not say.
  final double? progress;

  /// «متابعة القراءة فقط» was chosen this session.
  final bool readingOnly;

  /// Sync, the account and reminder changes stop below the minimum version.
  bool get blocksWrites => decision is RequiredUpdate;

  bool get showsRequiredScreen => decision is RequiredUpdate && !readingOnly;

  UpdateState _with({
    UpdateDecision? decision,
    UpdatePhase? phase,
    double? progress,
    bool? readingOnly,
  }) => UpdateState(
    decision: decision ?? this.decision,
    phase: phase ?? this.phase,
    progress: progress,
    readingOnly: readingOnly ?? this.readingOnly,
  );
}

/// Checks the published versions on launch and resume, and runs whichever
/// update the user starts. The rules themselves are in `update_policy.dart`.
class UpdateController extends Notifier<UpdateState> {
  AppVersion? _installed;
  Future<void>? _cachedCheck;
  bool _promptedThisLaunch = false;
  StreamSubscription<double?>? _download;

  @override
  UpdateState build() {
    ref.onDispose(() => _download?.cancel());
    return const UpdateState();
  }

  AppUpdater get _updater => ref.read(appUpdaterProvider);

  Future<AppVersion?> installedVersion() async {
    if (_installed != null) return _installed;
    try {
      final info = await ref.read(appInfoProvider.future);
      return _installed = AppVersion.tryParse(info.version);
    } catch (_) {
      return null;
    }
  }

  /// Applies the values this device last activated, once per launch — what
  /// sync waits on, so an outdated build does not write before the gate is up.
  Future<void> ensureChecked() => _cachedCheck ??= () async {
    final installed = await installedVersion();
    _apply(installed, ref.read(updateConfigSourceProvider).cached());
  }();

  /// Applies the cached values at once — a required update holds offline —
  /// then whatever a fetch brings.
  Future<void> check() async {
    await ensureChecked();
    final installed = await installedVersion();
    _apply(installed, await ref.read(updateConfigSourceProvider).refresh());
  }

  void _apply(AppVersion? installed, UpdateConfig config) {
    state = state._with(
      decision: resolveUpdate(installed: installed, config: config),
      progress: state.progress,
    );
  }

  /// The optional update to offer now, if any; recording it counts as
  /// having shown it. At most once per launch, and never mid-update.
  OptionalUpdate? takePrompt({bool launchedFromReminder = false}) {
    final decision = state.decision;
    if (decision is! OptionalUpdate ||
        _promptedThisLaunch ||
        state.phase != UpdatePhase.idle) {
      return null;
    }
    final store = ref.read(settingsStoreProvider);
    final now = ref.read(clockProvider)();
    final show = shouldPromptUpdate(
      target: decision.target,
      lastPromptedVersion: AppVersion.tryParse(store.updatePromptedVersion),
      lastPromptedAt: store.updatePromptedAt,
      now: now,
      launchedFromReminder: launchedFromReminder,
    );
    if (!show) return null;
    _promptedThisLaunch = true;
    store.setUpdatePrompted(decision.target.toString(), now);
    return decision;
  }

  /// «حدّث الآن»: a background download on Play, the store page otherwise.
  Future<void> startOptionalUpdate() async {
    if (!await _updater.canUpdateInApp()) {
      await _updater.openStorePage();
      return;
    }
    state = state._with(phase: UpdatePhase.downloading);
    await _download?.cancel();
    _download = _updater.downloadInBackground().listen(
      (p) => state = state._with(phase: UpdatePhase.downloading, progress: p),
      onError: (Object _) => state = state._with(phase: UpdatePhase.idle),
      onDone: () {
        if (state.phase == UpdatePhase.downloading) {
          state = state._with(phase: UpdatePhase.ready, progress: 1);
        }
      },
      cancelOnError: true,
    );
  }

  /// «أعد التشغيل». Play restarts the app; if it is still here afterwards,
  /// the install did not happen and the card offers it again.
  Future<void> restartToUpdate() async {
    state = state._with(phase: UpdatePhase.restarting);
    try {
      await _updater.installDownloaded();
    } catch (_) {}
    state = state._with(phase: UpdatePhase.ready, progress: 1);
  }

  /// The required screen's button: Play's immediate flow where it exists,
  /// the store page otherwise, and «لا يوجد اتصال» when neither can work.
  Future<void> startRequiredUpdate() async {
    state = state._with(phase: UpdatePhase.updating);
    if (!await _updater.isOnline()) {
      state = state._with(phase: UpdatePhase.offline);
      return;
    }
    if (await _updater.canUpdateInApp()) {
      final result = await _updater.updateImmediately();
      if (result == ImmediateResult.failed) await _updater.openStorePage();
    } else {
      await _updater.openStorePage();
    }
    state = state._with(phase: UpdatePhase.idle);
  }

  /// «متابعة القراءة فقط», for this session.
  void keepReading() =>
      state = state._with(phase: UpdatePhase.idle, readingOnly: true);

  /// Back to the required screen from a banner behind it.
  void showRequired() => state = state._with(readingOnly: false);

  /// The releases to announce after an update; records the running version
  /// either way. Null on a first install or when nothing is new.
  Future<List<Release>?> takeWhatsNew() async {
    final installed = await installedVersion();
    if (installed == null) return null;
    final store = ref.read(settingsStoreProvider);
    final lastSeen = AppVersion.tryParse(store.lastSeenVersion);
    if (lastSeen == installed) return null;
    await store.setLastSeenVersion(installed.toString());
    try {
      final changelog = await ref.read(changelogProvider.future);
      return whatsNewAfterUpdate(
        lastSeen: lastSeen,
        installed: installed,
        changelog: changelog,
      );
    } catch (_) {
      return null;
    }
  }
}

final updateProvider = NotifierProvider<UpdateController, UpdateState>(
  UpdateController.new,
);

/// What the guards read: true below `min_supported_version`, whether or not
/// the user chose to keep reading.
final updateBlocksWritesProvider = Provider<bool>(
  (ref) => ref.watch(updateProvider.select((s) => s.blocksWrites)),
);
