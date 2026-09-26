import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/relative_time.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../services/auth/auth_service.dart';
import '../../services/feedback/feedback_repository.dart';
import '../../services/sync/sync_remote.dart';
import '../../services/sync/sync_service.dart';
import '../settings/settings_controller.dart';
import 'account_actions.dart';

Future<void> openAccount(BuildContext context) =>
    pushPage(context, (_) => const AccountScreen());

/// Board AF 4: who is signed in, how sync stands, sign out, delete.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final account = ref.watch(accountProvider);

    // Signed out from here, or deleted: nothing left to show.
    if (account is! SignedIn) {
      return PageScaffold(title: l.account, body: const SizedBox.shrink());
    }
    final provider = switch (account.user.provider) {
      AuthProviderKind.apple => 'Apple',
      AuthProviderKind.google => 'Google',
      null => null,
    };
    final email = account.user.email;
    final title = accountTitle(account, appleAccount: l.appleAccount);

    return PageScaffold(
      title: l.account,
      body: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - 48),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: AccountAvatar(account, size: 64)),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: MishkatType.headline(t),
                  ),
                  if (email != null && email != title || provider != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          if (email != null && email != title)
                            TextSpan(text: '\u2068$email\u2069'),
                          if (email != null &&
                              email != title &&
                              provider != null)
                            const TextSpan(text: ' · '),
                          if (provider != null)
                            TextSpan(text: l.viaProvider(provider)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: MishkatType.caption(t).copyWith(fontSize: 12.5),
                    ),
                  const SizedBox(height: 14),
                  const SyncStatusCard(showScope: true),
                  const SizedBox(height: 14),
                  _SignOutRow(
                    onTap: () async {
                      await ref.read(accountActionsProvider).signOut();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                  const Spacer(),
                  const SizedBox(height: 14),
                  _DangerButton(
                    label: l.deleteAccount,
                    icon: MIcon.trash,
                    soft: true,
                    onPressed: () => showAppSheet<void>(
                      context,
                      (_) => const DeleteAccountSheet(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The initial on glowSoft: «م» for محمد, "M" for Mohamed.
class AccountAvatar extends StatelessWidget {
  const AccountAvatar(this.account, {super.key, this.size = 40});

  final SignedIn account;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = account.label.trim();
    final initial = label.isEmpty
        ? null
        : String.fromCharCode(label.runes.first).toUpperCase();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.glowSoft, shape: BoxShape.circle),
      child: initial == null
          ? MishkatIcon(MIcon.account, color: t.accentText, size: size * 0.45)
          : Text(
              initial,
              style: TextStyle(
                fontFamily: kUiFont,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w500,
                color: t.isDark ? t.accentText : t.primary,
              ),
            ),
    );
  }
}

/// Board AF 4 "sync card": synced, syncing, offline, or error with retry.
class SyncStatusCard extends ConsumerWidget {
  const SyncStatusCard({super.key, this.showScope = false});

  /// Lists what syncs and offers «زامن الآن» — on the Account screen.
  final bool showScope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final status = ref.watch(syncProvider);
    final lang = ref.watch(settingsProvider).language.name;
    final now = ref.watch(clockProvider)();
    final sync = ref.read(syncProvider.notifier);

    final last = status.lastSyncAt;
    final syncedLine = last == null
        ? l.notSyncedYet
        : l.syncedAgo(formatRelative(l, last, now, lang));
    final error = status.phase == SyncPhase.error;

    final (title, body) = switch (status.phase) {
      SyncPhase.idle => (l.syncSynced, syncedLine),
      SyncPhase.syncing => (l.syncSyncing, l.syncSyncingBody),
      SyncPhase.offline => (l.syncOffline, l.syncOfflineBody),
      SyncPhase.error => (l.syncError, l.syncErrorBody),
    };
    final Widget glyph = switch (status.phase) {
      SyncPhase.idle => MishkatIcon(
        MIcon.cloudCheck,
        color: t.isDark ? t.accentText : t.primary,
        size: 20,
      ),
      SyncPhase.syncing =>
        Motion.reduced(context)
            ? MishkatIcon(MIcon.cloudSync, color: t.accentText, size: 20)
            : SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: t.isDark ? t.accentText : t.primary,
                  backgroundColor: t.glowLine,
                ),
              ),
      SyncPhase.offline => MishkatIcon(
        MIcon.cloudOff,
        color: t.inkMuted,
        size: 20,
      ),
      SyncPhase.error => MishkatIcon(MIcon.warning, color: t.error, size: 20),
    };
    final glyphBg = switch (status.phase) {
      SyncPhase.offline => t.bg,
      SyncPhase.error => t.surfaceRaised,
      _ => t.glowSoft,
    };

    Widget scopeChip(String label) => Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(label, style: MishkatType.body(t).copyWith(fontSize: 11.5)),
      ),
    );

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsets.all(showScope ? 16 : 14),
        decoration: BoxDecoration(
          color: error ? t.errorSoft : t.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: glyphBg,
                    shape: BoxShape.circle,
                  ),
                  child: glyph,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: MishkatType.label(t).copyWith(fontSize: 14),
                      ),
                      Text(
                        body,
                        style: MishkatType.caption(
                          t,
                        ).copyWith(color: error ? t.ink : null),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showScope && !error) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  scopeChip(l.titleProgress),
                  scopeChip(l.signInFavorites),
                  scopeChip(l.settings),
                ],
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: l.syncNow,
                background: t.bg,
                onPressed: status.phase == SyncPhase.syncing
                    ? null
                    : () => sync.sync(full: true),
              ),
            ],
            if (error) ...[
              const SizedBox(height: 12),
              _DangerButton(
                label: l.retry,
                compact: true,
                onPressed: () => sync.sync(full: true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SignOutRow extends StatelessWidget {
  const _SignOutRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(Radii.lg),
      clipBehavior: Clip.antiAlias,
      child: NavRow(
        icon: MIcon.signOut,
        label: l.signOut,
        subtitle: l.signOutBody,
        onTap: onTap,
      ),
    );
  }
}

/// The destructive pill: errorSoft for "Delete account", error for the
/// final confirmation and for retry.
class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.soft = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final MIcon? icon;
  final bool soft;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bg = soft ? t.errorSoft : t.error;
    final fg = soft ? t.error : t.onError;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: SizedBox(
            height: compact ? 44 : Sizes.button,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  MishkatIcon(icon!, color: fg, size: 18),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: compact ? 13.5 : 15.5,
                      fontWeight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Board AF 5. Deletion is required by both stores; what goes and what stays
/// is spelled out, and Apple may ask the user to confirm again after this.
class DeleteAccountSheet extends ConsumerStatefulWidget {
  const DeleteAccountSheet({super.key});

  @override
  ConsumerState<DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<DeleteAccountSheet> {
  bool _busy = false;

  Future<void> _delete() async {
    setState(() => _busy = true);
    final l = L.of(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(accountActionsProvider).deleteAccount();
      navigator
        ..pop()
        ..maybePop();
      messenger.showSnackBar(SnackBar(content: Text(l.accountDeletedToast)));
    } on SignInCancelled {
      if (mounted) setState(() => _busy = false);
    } catch (e) {
      debugPrint('Account deletion failed: $e');
      if (!mounted) return;
      setState(() => _busy = false);
      final offline =
          e is AuthOffline || e is SyncOffline || e is FeedbackOffline;
      showToast(context, offline ? l.deleteFailed : l.deleteFailedTryLater);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);

    Widget item(String text) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: t.error, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: MishkatType.body(t).copyWith(fontSize: 13.5),
            ),
          ),
        ],
      ),
    );

    Widget panel(List<Widget> children) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    final heading = MishkatType.label(
      t,
    ).copyWith(fontSize: 12, color: t.inkMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.errorSoft,
              shape: BoxShape.circle,
            ),
            child: MishkatIcon(MIcon.trash, color: t.error, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            l.deleteTitle,
            textAlign: TextAlign.center,
            style: MishkatType.title(t),
          ),
        ),
        Text(
          l.deleteSubtitle,
          textAlign: TextAlign.center,
          style: MishkatType.caption(t).copyWith(fontSize: 13),
        ),
        const SizedBox(height: 14),
        panel([
          Text(l.deleteRemovedHeading, style: heading),
          item(l.deleteItemProgress),
          item(l.signInFavorites),
          item(l.settings),
          item(l.deleteItemMessages),
        ]),
        const SizedBox(height: 14),
        panel([
          Text(l.deleteKeptHeading, style: heading),
          const SizedBox(height: 6),
          Text(
            l.deleteKeptBody,
            style: MishkatType.body(t).copyWith(
              fontSize: 13.5,
              fontWeight: FontWeight.w300,
              height: 1.8,
            ),
          ),
        ]),
        const SizedBox(height: 14),
        _DangerButton(
          label: l.deleteConfirm,
          onPressed: _busy ? null : _delete,
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: l.cancel,
          background: t.bg,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
