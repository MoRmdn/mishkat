import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../services/update/app_version.dart';
import '../../services/update/release_notes.dart';
import 'update_widgets.dart';

/// «تم التحديث إلى ١٫٣٫٠» with «ما الجديد», the first launch after an update.
///
/// The toast's own dark fill inverts the appearance, so its accent comes
/// from the opposite ramp to stay readable on it.
void showUpdatedToast(
  BuildContext context, {
  required AppVersion version,
  required VoidCallback onWhatsNew,
}) {
  final t = context.tokens;
  final l = L.of(context);
  final lang = Localizations.localeOf(context).languageCode;
  final inverse = t.isDark ? MishkatTokens.light : MishkatTokens.dark;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.ink,
        elevation: 0,
        duration: const Duration(seconds: 10),
        padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, Sizes.nav + 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        content: Row(
          children: [
            MishkatIcon(MIcon.check, color: inverse.accentText, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.updatedTo(version.display(lang)),
                style: TextStyle(
                  fontFamily: kUiFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: t.bg,
                ),
              ),
            ),
            Semantics(
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  messenger.hideCurrentSnackBar();
                  onWhatsNew();
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Sizes.touchMin),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        l.whatsNew,
                        style: TextStyle(
                          fontFamily: kUiFont,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: inverse.accentText,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IconCircleButton(
              icon: MIcon.close,
              semanticLabel: l.close,
              size: 36,
              iconSize: 12,
              background: Colors.transparent,
              color: inverse.inkMuted,
              onPressed: messenger.hideCurrentSnackBar,
            ),
          ],
        ),
      ),
    );
}

Future<void> showWhatsNewSheet(BuildContext context, List<Release> releases) =>
    showAppSheet<void>(context, (_) => WhatsNewSheet(releases: releases));

/// What the update brought, newest first, from the bundled changelog.
class WhatsNewSheet extends StatelessWidget {
  const WhatsNewSheet({super.key, required this.releases});

  final List<Release> releases;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.whatsNew),
        for (final release in releases) ..._release(l, lang, release),
        const SizedBox(height: 12),
        TextAction(
          label: l.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  List<Widget> _release(L l, String lang, Release release) => [
    const SizedBox(height: 14),
    Align(
      alignment: AlignmentDirectional.centerStart,
      child: VersionChip(l.updateVersionChip(release.version.display(lang))),
    ),
    const SizedBox(height: 10),
    ReleaseNoteList(notes: release.notes, languageCode: lang),
  ];
}

Future<void> openWhatsNew(BuildContext context) =>
    pushPage(context, (_) => const WhatsNewPage());

/// «ما الجديد» from «عن التطبيق»: every release in the bundled changelog.
class WhatsNewPage extends ConsumerWidget {
  const WhatsNewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final releases = ref.watch(changelogProvider).value?.releases ?? const [];
    return PageScaffold(
      title: l.whatsNew,
      divider: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          for (final release in releases) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: VersionChip(
                l.updateVersionChip(release.version.display(lang)),
              ),
            ),
            const SizedBox(height: 10),
            ReleaseNoteList(
              notes: release.notes,
              languageCode: lang,
              onPage: true,
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
