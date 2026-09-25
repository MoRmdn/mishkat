import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/relative_time.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/surfaces.dart';
import '../../services/auth/auth_service.dart';
import '../../services/feedback/feedback_models.dart';
import '../../services/feedback/feedback_providers.dart';
import '../../services/sync/sync_service.dart';
import '../account/account_screen.dart';
import '../account/sign_in_sheet.dart';
import '../admin/inbox_page.dart';
import '../feedback/feedback_list_page.dart';
import 'settings_controller.dart';

/// The sync line under a signed-in account: «آخر مزامنة قبل ٣ دقائق».
String syncLine(L l, SyncStatus status, DateTime now, String lang) {
  final last = status.lastSyncAt;
  return switch (status.phase) {
    SyncPhase.syncing => l.syncSyncing,
    SyncPhase.offline => l.syncOfflineBody,
    SyncPhase.error => l.syncError,
    SyncPhase.idle =>
      last == null
          ? l.notSyncedYet
          : l.syncedAgo(formatRelative(l, last, now, lang)),
  };
}

/// Signed out: the glowSoft invitation. Signed in: the avatar row that
/// opens Account.
class AccountCard extends ConsumerWidget {
  const AccountCard({super.key});

  static const _cardRadius = BorderRadius.all(Radius.circular(Radii.lg));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final account = ref.watch(accountProvider);

    if (account is SignedIn) {
      final status = ref.watch(syncProvider);
      final lang = ref.watch(settingsProvider).language.name;
      final now = ref.watch(clockProvider)();
      final last = status.lastSyncAt;
      final title = accountTitle(account, appleAccount: l.appleAccount);
      final line = syncLine(l, status, now, lang);
      return Material(
        color: t.surface,
        borderRadius: _cardRadius,
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          button: true,
          label: '${l.account}، $title، $line',
          excludeSemantics: true,
          child: InkWell(
            onTap: () => openAccount(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  AccountAvatar(account),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MishkatType.label(t).copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (status.phase == SyncPhase.idle &&
                                last != null) ...[
                              MishkatIcon(
                                MIcon.check,
                                color: t.accentText,
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                            ],
                            Flexible(
                              child: Text(
                                line,
                                style: MishkatType.caption(
                                  t,
                                ).copyWith(fontSize: 11.5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  MishkatIcon(MIcon.chevronRight, color: t.inkMuted, size: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: t.glowSoft, borderRadius: _cardRadius),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: t.surface, shape: BoxShape.circle),
            child: MishkatIcon(
              MIcon.cloudSync,
              color: t.isDark ? t.accentText : t.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.accountCardTitle,
                  style: MishkatType.label(
                    t,
                  ).copyWith(fontSize: 13.5, height: 1.5),
                ),
                const SizedBox(height: 2),
                Text(
                  l.accountCardBody,
                  style: MishkatType.caption(t).copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SmallPillButton(
            label: l.signInShort,
            onPressed: () => showSignInFlow(context),
          ),
        ],
      ),
    );
  }
}

/// «الدعم»: the sender's conversations, and for the owner the inbox.
class SupportGroup extends ConsumerWidget {
  const SupportGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final badges =
        ref.watch(feedbackBadgesProvider).value ?? FeedbackBadges.none;
    final admin = ref.watch(isAdminProvider).value ?? false;
    return GroupCard(
      children: [
        NavRow(
          icon: MIcon.edit,
          label: l.feedback,
          unread: badges.userUnread > 0,
          semanticsSuffix: badges.userUnread > 0 ? l.unreadReply : null,
          onTap: () => openFeedbackList(context),
        ),
        if (admin)
          NavRow(
            icon: MIcon.inbox,
            label: l.inbox,
            count: badges.adminUnread,
            semanticsSuffix: badges.adminUnread > 0
                ? l.unreadCount(badges.adminUnread, '${badges.adminUnread}')
                : null,
            onTap: () => openInbox(context),
          ),
      ],
    );
  }
}
