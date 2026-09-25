import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/segmented_control.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/app_settings.dart';
import '../../services/auth/auth_service.dart';
import '../../services/feedback/feedback_models.dart';
import '../../services/feedback/feedback_providers.dart';
import '../../services/sync/sync_service.dart';
import '../account/account_screen.dart';
import '../account/sign_in_sheet.dart';
import 'about_page.dart';
import 'settings_controller.dart';
import 'settings_parts.dart';

/// Home's settings button.
Future<void> openSettings(BuildContext context) =>
    showAppSheet(context, (_) => SettingsSheet(host: context));

/// Board AF 16b: the everyday settings in a sheet, with no section labels
/// and no «تم» — it closes on swipe-down or a tap on the scrim, and every
/// change applies live. Account, feedback and the legal pages live one level
/// down, on the «عن التطبيق» page.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key, required this.host});

  /// The screen that opened the sheet. What the sheet opens (sign-in,
  /// Account, «عن التطبيق») is opened from here after the sheet closes, so
  /// back returns to Home rather than to a sheet left underneath.
  final BuildContext host;

  void _thenOpen(BuildContext context, void Function(BuildContext) open) {
    Navigator.of(context).pop();
    if (host.mounted) open(host);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);
    final cloud = ref.watch(cloudAvailableProvider);
    final unread =
        cloud &&
        (ref.watch(feedbackBadgesProvider).value ?? FeedbackBadges.none).any;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.settings),
        const SizedBox(height: 14),
        if (cloud) ...[
          _SheetAccountRow(
            onSignIn: () => _thenOpen(context, showSignInFlow),
            onAccount: () => _thenOpen(context, openAccount),
          ),
          const SizedBox(height: 14),
        ],
        SegmentedControl<AppLanguage>(
          value: s.language,
          onChanged: c.setLanguage,
          onSurface: true,
          options: [
            SegmentedOption(AppLanguage.ar, l.languageArabic),
            SegmentedOption(AppLanguage.en, l.languageEnglish),
          ],
        ),
        const SizedBox(height: 14),
        SegmentedControl<AppearanceMode>(
          value: s.appearance,
          onChanged: c.setAppearance,
          onSurface: true,
          options: [
            SegmentedOption(AppearanceMode.light, l.light),
            SegmentedOption(AppearanceMode.dark, l.dark),
            SegmentedOption(AppearanceMode.system, l.system),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                l.fontSize,
                style: MishkatType.label(
                  t,
                ).copyWith(fontSize: 12, color: t.inkMuted),
              ),
            ),
            IconCircleButton(
              icon: MIcon.minus,
              iconSize: 16,
              background: t.bg,
              semanticLabel: l.textSmaller,
              onPressed: s.textSize == ThikrSize.small
                  ? null
                  : () => c.stepTextSize(-1),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 60),
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
              iconSize: 16,
              background: t.bg,
              semanticLabel: l.textLarger,
              onPressed: s.textSize == ThikrSize.large
                  ? null
                  : () => c.stepTextSize(1),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Material(
          color: t.bg,
          borderRadius: BorderRadius.circular(Radii.lg),
          clipBehavior: Clip.antiAlias,
          child: Semantics(
            toggled: s.useQuranFont,
            button: true,
            label: l.quranFont,
            excludeSemantics: true,
            child: InkWell(
              onTap: c.toggleQuranFont,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.quranFont,
                            style: MishkatType.label(t).copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          // Always in the Quranic script: it previews what
                          // the switch turns on.
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
        ),
        const SizedBox(height: 14),
        GroupCard(
          color: t.bg,
          children: [
            NavRow(
              icon: MIcon.info,
              label: l.about,
              // Feedback and the owner's inbox are on this page now, so the
              // dot Home's settings button shows leads here.
              unread: unread,
              semanticsSuffix: unread ? l.unreadReply : null,
              onTap: () => _thenOpen(context, openAbout),
            ),
          ],
        ),
      ],
    );
  }
}

/// 16b's compact account row. Signed out: «سجّل الدخول لمزامنة تقدّمك» on
/// glowSoft. Signed in: the avatar, name and sync line, opening Account.
class _SheetAccountRow extends ConsumerWidget {
  const _SheetAccountRow({required this.onSignIn, required this.onAccount});

  final VoidCallback onSignIn;
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final account = ref.watch(accountProvider);
    final signedIn = account is SignedIn;

    final String title;
    final String? line;
    if (account is SignedIn) {
      title = accountTitle(account, appleAccount: l.appleAccount);
      line = syncLine(
        l,
        ref.watch(syncProvider),
        ref.watch(clockProvider)(),
        ref.watch(settingsProvider).language.name,
      );
    } else {
      title = l.signInToSync;
      line = null;
    }

    return Material(
      color: signedIn ? t.bg : t.glowSoft,
      borderRadius: BorderRadius.circular(Radii.lg),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        label: line == null ? title : '${l.account}، $title، $line',
        excludeSemantics: true,
        child: InkWell(
          onTap: signedIn ? onAccount : onSignIn,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Sizes.touchMin),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: signedIn ? 10 : 12,
              ),
              child: Row(
                children: [
                  if (account is SignedIn)
                    AccountAvatar(account, size: 32)
                  else
                    MishkatIcon(
                      MIcon.cloudSync,
                      color: t.isDark ? t.accentText : t.primary,
                      size: 18,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: MishkatType.label(t).copyWith(fontSize: 13.5),
                        ),
                        if (line != null)
                          Text(
                            line,
                            style: MishkatType.caption(
                              t,
                            ).copyWith(fontSize: 11.5),
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
      ),
    );
  }
}
