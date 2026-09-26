import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/external_links.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/share_link.dart';
import '../../core/store_links.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart' show SheetSectionLabel;
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/surfaces.dart';
import '../../services/app_info.dart';
import '../../services/auth/auth_service.dart';
import '../update/whats_new.dart';
import 'settings_controller.dart';
import 'settings_parts.dart';
import 'sources_page.dart';

Future<void> openAbout(BuildContext context) =>
    pushPage(context, (_) => const AboutPage());

/// «عن التطبيق», opened from the last row of the settings sheet. Laid out as
/// board AF 16a: the account card, «الدعم» (feedback, and the owner's inbox),
/// rating, the legal pages and the athkar sources, and the brand with the
/// version at the foot.
class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final launch = ref.read(externalLinkLauncherProvider);
    final cloud = ref.watch(cloudAvailableProvider);
    return PageScaffold(
      title: l.about,
      divider: true,
      body: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
          child: ConstrainedBox(
            // The brand sits at the foot of the screen, as on the board,
            // and follows the rows when they are taller than the screen.
            constraints: BoxConstraints(minHeight: box.maxHeight - 34),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (cloud) ...[
                    const AccountCard(),
                    const SizedBox(height: 16),
                    SheetSectionLabel(l.settingsSupport, topPadding: 0),
                    const SupportGroup(),
                    const SizedBox(height: 16),
                    SheetSectionLabel(l.about, topPadding: 0),
                  ],
                  GroupCard(
                    children: [
                      if (kShowRateApp)
                        NavRow(
                          label: l.rateApp,
                          external: true,
                          onTap: () =>
                              launch(rateAppUri(defaultTargetPlatform)),
                        ),
                      for (final page in LegalPage.values)
                        NavRow(
                          label: switch (page) {
                            LegalPage.privacy => l.privacyPolicy,
                            LegalPage.terms => l.termsOfUse,
                          },
                          external: true,
                          onTap: () => launch(legalPage(page, lang)),
                        ),
                      NavRow(
                        label: l.thikrSources,
                        onTap: () => openSources(context),
                      ),
                      NavRow(
                        label: l.whatsNew,
                        onTap: () => openWhatsNew(context),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 28),
                  const _AppFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
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
