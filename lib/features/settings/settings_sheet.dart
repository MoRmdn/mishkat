import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/external_links.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/share_link.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/segmented_control.dart';
import '../../data/models/app_settings.dart';
import 'settings_controller.dart';

Future<void> showSettingsSheet(BuildContext context) =>
    showAppSheet(context, (_) => const SettingsSheet());

/// Board 5.4. One identity, so appearance is the only visual choice: light,
/// dark or follow the system.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final s = ref.watch(settingsProvider);
    final c = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.settings),
        SheetSectionLabel(l.language),
        SegmentedControl<AppLanguage>(
          value: s.language,
          onChanged: c.setLanguage,
          onSurface: true,
          options: [
            SegmentedOption(AppLanguage.ar, l.languageArabic),
            SegmentedOption(AppLanguage.en, l.languageEnglish),
          ],
        ),
        SheetSectionLabel(l.appearance),
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
        const SizedBox(height: 16),
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
            SizedBox(
              width: 60,
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
        const SizedBox(height: 16),
        Semantics(
          toggled: s.useQuranFont,
          button: true,
          label: l.quranFont,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: c.toggleQuranFont,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: t.bg,
                borderRadius: BorderRadius.circular(Radii.lg),
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
                        const SizedBox(height: 4),
                        // Always set in the Quranic script: it previews what
                        // the switch turns on.
                        Text(
                          'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: kQuranFont,
                            fontSize: 17,
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
        SheetSectionLabel(l.about),
        for (final page in LegalPage.values) ...[
          _LinkRow(
            label: switch (page) {
              LegalPage.privacy => l.privacyPolicy,
              LegalPage.terms => l.termsOfUse,
            },
            onTap: () => ref.read(externalLinkLauncherProvider)(
              legalPage(page, s.language.name),
            ),
          ),
          if (page != LegalPage.values.last) const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: l.done,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

/// A page on the web site: the privacy policy or the terms.
class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      link: true,
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: t.bg,
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: MishkatType.label(t).copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              MishkatIcon(MIcon.external, color: t.inkMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
