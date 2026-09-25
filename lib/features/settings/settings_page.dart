import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/external_links.dart';
import '../../core/format/relative_time.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/share_link.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart' show SheetSectionLabel;
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/segmented_control.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/app_settings.dart';
import '../../services/app_info.dart';
import '../../services/auth/auth_service.dart';
import '../../services/feedback/feedback_models.dart';
import '../../services/feedback/feedback_providers.dart';
import '../../services/sync/sync_service.dart';
import '../account/account_screen.dart';
import '../account/sign_in_sheet.dart';
import '../admin/inbox_page.dart';
import '../feedback/feedback_list_page.dart';
import 'settings_controller.dart';

Future<void> openSettings(BuildContext context) =>
    pushPage(context, (_) => const SettingsPage());

/// Board AF 16a: Settings as a grouped, scrolling page pushed from Home.
/// Changes apply live and back returns to Home, so there is no «تم».
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final cloud = ref.watch(cloudAvailableProvider);
    return PageScaffold(
      title: l.settings,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        children: [
          if (cloud) ...[const _AccountCard(), const SizedBox(height: 16)],
          _Group(label: l.settingsReading, child: const _ReadingGroup()),
          const SizedBox(height: 16),
          _Group(
            label: l.settingsLanguageAppearance,
            child: const _LanguageAppearanceGroup(),
          ),
          if (cloud) ...[
            const SizedBox(height: 16),
            _Group(label: l.settingsSupport, child: const _SupportGroup()),
          ],
          const SizedBox(height: 16),
          _Group(label: l.about, child: const _AboutGroup()),
          const SizedBox(height: 28),
          const _AppFooter(),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [SheetSectionLabel(label, topPadding: 0), child],
  );
}

/// Signed out: the glowSoft invitation. Signed in: the avatar row that
/// opens Account.
class _AccountCard extends ConsumerWidget {
  const _AccountCard();

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
      final line = switch (status.phase) {
        SyncPhase.syncing => l.syncSyncing,
        SyncPhase.offline => l.syncOfflineBody,
        SyncPhase.error => l.syncError,
        SyncPhase.idle =>
          last == null
              ? l.notSyncedYet
              : l.syncedAgo(formatRelative(l, last, now, lang)),
      };
      return Material(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          button: true,
          label: '${l.account}، ${account.label}، $line',
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
                          account.label,
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
      decoration: BoxDecoration(
        color: t.glowSoft,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
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

class _ReadingGroup extends ConsumerWidget {
  const _ReadingGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    return GroupCard(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.fontSize,
                  style: MishkatType.body(t).copyWith(fontSize: 14),
                ),
              ),
              IconCircleButton(
                icon: MIcon.minus,
                size: 40,
                iconSize: 14,
                background: t.bg,
                semanticLabel: l.textSmaller,
                onPressed: s.textSize == ThikrSize.small
                    ? null
                    : () => c.stepTextSize(-1),
              ),
              SizedBox(
                width: 52,
                child: Text(
                  switch (s.textSize) {
                    ThikrSize.small => l.fontSizeSmall,
                    ThikrSize.medium => l.fontSizeMedium,
                    ThikrSize.large => l.fontSizeLarge,
                  },
                  textAlign: TextAlign.center,
                  style: MishkatType.label(t).copyWith(fontSize: 13.5),
                ),
              ),
              IconCircleButton(
                icon: MIcon.plus,
                size: 40,
                iconSize: 14,
                background: t.bg,
                semanticLabel: l.textLarger,
                onPressed: s.textSize == ThikrSize.large
                    ? null
                    : () => c.stepTextSize(1),
              ),
            ],
          ),
        ),
        Semantics(
          toggled: s.useQuranFont,
          button: true,
          label: l.quranFont,
          excludeSemantics: true,
          child: InkWell(
            onTap: c.toggleQuranFont,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.quranFont,
                          style: MishkatType.body(t).copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        // Always in the Quranic script: it previews what the
                        // switch turns on.
                        Text(
                          'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: kQuranFont,
                            fontSize: 16,
                            color: t.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppSwitch(
                    value: s.useQuranFont,
                    onChanged: c.toggleQuranFont,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageAppearanceGroup extends ConsumerWidget {
  const _LanguageAppearanceGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedControl<AppLanguage>(
            value: s.language,
            onChanged: c.setLanguage,
            onSurface: true,
            options: [
              SegmentedOption(AppLanguage.ar, l.languageArabic),
              SegmentedOption(AppLanguage.en, l.languageEnglish),
            ],
          ),
          const SizedBox(height: 10),
          SegmentedControl<AppearanceMode>(
            value: s.appearance,
            onChanged: c.setAppearance,
            onSurface: true,
            options: [
              SegmentedOption(AppearanceMode.light, l.light, icon: MIcon.sun),
              SegmentedOption(AppearanceMode.dark, l.dark, icon: MIcon.moon),
              SegmentedOption(
                AppearanceMode.system,
                l.system,
                icon: MIcon.device,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportGroup extends ConsumerWidget {
  const _SupportGroup();

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

class _AboutGroup extends ConsumerWidget {
  const _AboutGroup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    return GroupCard(
      children: [
        for (final page in LegalPage.values)
          NavRow(
            label: switch (page) {
              LegalPage.privacy => l.privacyPolicy,
              LegalPage.terms => l.termsOfUse,
            },
            external: true,
            onTap: () =>
                ref.read(externalLinkLauncherProvider)(legalPage(page, lang)),
          ),
      ],
    );
  }
}

class _AppFooter extends ConsumerWidget {
  const _AppFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final version = ref.watch(appInfoProvider).value?.version;
    return Column(
      children: [
        const BrandMark(size: 30),
        const SizedBox(height: 6),
        Text(l.appName, style: MishkatType.label(t).copyWith(fontSize: 13)),
        if (version != null) ...[
          const SizedBox(height: 6),
          Text(
            l.versionLine('\u2066$version\u2069'),
            textAlign: TextAlign.center,
            style: MishkatType.caption(t).copyWith(fontSize: 11.5),
          ),
        ],
      ],
    );
  }
}
