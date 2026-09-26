import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/external_links.dart';
import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/share_link.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/repositories/progress_providers.dart';
import '../../services/auth/auth_service.dart';
import '../../services/sync/merge.dart';
import '../settings/settings_controller.dart';
import '../update/update_controller.dart';
import 'account_actions.dart';

/// Board AF 2 → 3: the sign-in sheet, then either the merge result (when
/// this device brought anything to the account) or a "signed in" toast.
///
/// Below `min_supported_version` it brings back the required screen instead:
/// an old build must not start syncing.
Future<void> showSignInFlow(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  if (container.read(updateBlocksWritesProvider)) {
    container.read(updateProvider.notifier).showRequired();
    return;
  }
  final result = await showAppSheet<_SignedIn>(
    context,
    (_) => const SignInSheet(),
  );
  if (result == null || !context.mounted) return;
  final summary = result.summary;
  if (summary != null && !summary.isEmpty) {
    await showAppSheet<void>(context, (_) => MergeResultSheet(summary));
  } else {
    showToast(context, L.of(context).signedInToast);
  }
}

class _SignedIn {
  const _SignedIn(this.summary);
  final MergeSummary? summary;
}

/// Board AF 2a/2b. Signing in is optional and says so; both providers get
/// the same size, Apple first on iOS.
class SignInSheet extends ConsumerStatefulWidget {
  const SignInSheet({super.key});

  @override
  ConsumerState<SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends ConsumerState<SignInSheet> {
  AuthProviderKind? _busy;
  late final _privacyLink = TapGestureRecognizer()
    ..onTap = () => ref.read(externalLinkLauncherProvider)(
      legalPage(LegalPage.privacy, ref.read(settingsProvider).language.name),
    );

  @override
  void dispose() {
    _privacyLink.dispose();
    super.dispose();
  }

  Future<void> _signIn(AuthProviderKind provider) async {
    if (_busy != null) return;
    setState(() => _busy = provider);
    try {
      final summary = await ref.read(accountActionsProvider).signIn(provider);
      if (mounted) Navigator.of(context).pop(_SignedIn(summary));
    } on SignInCancelled {
      if (mounted) setState(() => _busy = null);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = null);
      showToast(context, L.of(context).signInFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final appleFirst = defaultTargetPlatform == TargetPlatform.iOS;
    final apple = ProviderButton(
      provider: AuthProviderKind.apple,
      label: l.signInApple,
      busy: _busy == AuthProviderKind.apple,
      onPressed: _busy == null ? () => _signIn(AuthProviderKind.apple) : null,
    );
    final google = ProviderButton(
      provider: AuthProviderKind.google,
      label: l.signInGoogle,
      busy: _busy == AuthProviderKind.google,
      onPressed: _busy == null ? () => _signIn(AuthProviderKind.google) : null,
    );

    Widget benefit(MIcon icon, String title, String body) => Row(
      children: [
        IconChip(icon, size: 36),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: MishkatType.label(t).copyWith(fontSize: 13.5)),
              Text(body, style: MishkatType.caption(t)),
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: BrandMark(size: 44)),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(
            l.signInTitle,
            textAlign: TextAlign.center,
            style: MishkatType.title(t),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.signInSubtitle,
          textAlign: TextAlign.center,
          style: MishkatType.caption(t).copyWith(fontSize: 13, height: 1.7),
        ),
        const SizedBox(height: 18),
        benefit(MIcon.progress, l.signInStreak, l.signInStreakBody),
        const SizedBox(height: 12),
        benefit(MIcon.heartFilled, l.signInFavorites, l.signInFavoritesBody),
        const SizedBox(height: 12),
        benefit(MIcon.bell, l.settings, l.signInSettingsBody),
        const SizedBox(height: 18),
        if (appleFirst) apple else google,
        const SizedBox(height: 10),
        if (appleFirst) google else apple,
        const SizedBox(height: 10),
        _AccentTextAction(
          label: l.notNow,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${l.signInPrivacy} '),
              TextSpan(
                text: l.privacyPolicy,
                style: TextStyle(color: t.accentText),
                recognizer: _privacyLink,
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: MishkatType.caption(t).copyWith(fontSize: 11.5, height: 1.7),
        ),
      ],
    );
  }
}

/// "ليس الآن" in accentText, 48px tall.
class _AccentTextAction extends StatelessWidget {
  const _AccentTextAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    excludeSemantics: true,
    label: label,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 48,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kUiFont,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: context.tokens.accentText,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The providers' own buttons, drawn to their published guidelines: black
/// (white in dark) for Apple; white with a grey outline (near-black in dark)
/// for Google, with its four-colour mark. These are brand assets, not app
/// tokens, so their colours live here and nowhere else.
class ProviderButton extends StatelessWidget {
  const ProviderButton({
    super.key,
    required this.provider,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final AuthProviderKind provider;
  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  static const _appleLight = (bg: Color(0xFF000000), fg: Color(0xFFFFFFFF));
  static const _appleDark = (bg: Color(0xFFFFFFFF), fg: Color(0xFF000000));
  static const _googleLight = (
    bg: Color(0xFFFFFFFF),
    fg: Color(0xFF1F1F1F),
    border: Color(0xFF747775),
  );
  static const _googleDark = (
    bg: Color(0xFF131314),
    fg: Color(0xFFE3E3E3),
    border: Color(0xFF8E918F),
  );

  @override
  Widget build(BuildContext context) {
    final dark = context.tokens.isDark;
    final Color bg, fg;
    Color? border;
    if (provider == AuthProviderKind.apple) {
      (bg, fg) = dark
          ? (_appleDark.bg, _appleDark.fg)
          : (_appleLight.bg, _appleLight.fg);
    } else {
      final c = dark ? _googleDark : _googleLight;
      (bg, fg, border) = (c.bg, c.fg, c.border);
    }
    final mark = provider == AuthProviderKind.apple
        ? SvgPicture.asset(
            'assets/branding/providers/apple.svg',
            width: 17,
            height: 17,
            colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
          )
        : SvgPicture.asset(
            'assets/branding/providers/google.svg',
            width: 18,
            height: 18,
          );
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: StadiumBorder(
          side: border == null ? BorderSide.none : BorderSide(color: border),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: SizedBox(
            height: Sizes.button,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  )
                else
                  mark,
                SizedBox(width: provider == AuthProviderKind.apple ? 8 : 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: 14.5,
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

/// Board AF 3: shown once, after a first sign-in that brought this device's
/// sessions, favourites or settings to the account.
class MergeResultSheet extends ConsumerWidget {
  const MergeResultSheet(this.summary, {super.key});

  final MergeSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final streak = ref.watch(progressStatsProvider).currentStreak;
    String d(int n) => localizeDigits(n, lang);

    final parts = [
      if (summary.sessions > 0)
        l.mergeSessions(summary.sessions, d(summary.sessions)),
      if (summary.favorites > 0)
        l.mergeFavorites(summary.favorites, d(summary.favorites)),
    ];
    final body = switch (parts) {
      [] => l.mergeSettingsOnly,
      [final one] => l.mergeBody(one),
      [final a, final b, ...] => l.mergeBody(l.mergeAnd(a, b)),
    };

    Widget chip(String label) => Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(label, style: MishkatType.body(t).copyWith(fontSize: 12.5)),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Center(
          child: IconHalo(icon: MIcon.cloudCheck, size: 60, iconSize: 26),
        ),
        const SizedBox(height: 14),
        Semantics(
          header: true,
          child: Text(
            l.mergeTitle,
            textAlign: TextAlign.center,
            style: MishkatType.title(t),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          body,
          textAlign: TextAlign.center,
          style: MishkatType.bodyMuted(t),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (summary.sessions > 0)
              chip(l.sessionsChip(summary.sessions, d(summary.sessions))),
            if (summary.favorites > 0)
              chip(l.favoritesChip(summary.favorites, d(summary.favorites))),
            if (summary.settings) chip(l.settings),
          ],
        ),
        if (streak > 0) ...[
          const SizedBox(height: 14),
          Text(
            l.currentStreakLine(l.daysCount(streak, d(streak))),
            textAlign: TextAlign.center,
            style: MishkatType.caption(t),
          ),
        ],
        const SizedBox(height: 20),
        PrimaryButton(
          label: l.continueLabel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
