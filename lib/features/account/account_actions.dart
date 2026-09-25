import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth/auth_service.dart';
import '../../services/feedback/feedback_providers.dart';
import '../../services/feedback/feedback_repository.dart';
import '../../services/sync/merge.dart';
import '../../services/sync/sync_remote.dart';
import '../../services/sync/sync_service.dart';

/// Signing in, out, and deleting the account — each a few steps across auth,
/// sync and feedback that the screens should not have to sequence.
class AccountActions {
  AccountActions(this._ref);

  final Ref _ref;

  AuthService get _auth => _ref.read(authServiceProvider);

  /// Signs in and merges this device with the account. Returns what this
  /// device contributed, for the first-sign-in sheet; null when the pull
  /// could not complete (the next resume retries).
  ///
  /// Throws [SignInCancelled] when the user closes the provider's sheet.
  Future<MergeSummary?> signIn(AuthProviderKind provider) async {
    final user = await _auth.signIn(provider);
    final summary = await _ref
        .read(syncProvider.notifier)
        .sync(full: true, uid: user.uid);
    refreshFeedback(_ref);
    return summary;
  }

  /// Everything stays on this device; it simply stops mirroring the account.
  Future<void> signOut() async {
    await _auth.signOut();
    await _ref.read(syncProvider.notifier).reset();
    refreshFeedback(_ref);
  }

  /// Confirms identity with the provider, removes the account's synced data
  /// and conversations, then the user. The device keeps its own data.
  ///
  /// Throws [SignInCancelled] if re-authentication is dismissed, before
  /// anything is deleted.
  Future<void> deleteAccount() async {
    final uid = _ref.read(accountProvider).uid;
    if (uid == null) return;
    await _auth.reauthenticate();
    await _ref.read(syncRemoteProvider).deleteAll(uid);
    await _ref.read(feedbackRepositoryProvider).deleteAllFor(uid);
    await _auth.deleteUser();
    await _ref.read(syncProvider.notifier).reset();
    refreshFeedback(_ref);
  }
}

final accountActionsProvider = Provider<AccountActions>(AccountActions.new);
