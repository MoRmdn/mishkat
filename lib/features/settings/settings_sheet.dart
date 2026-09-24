import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/segmented_control.dart';
import '../../data/models/app_settings.dart';
import 'settings_controller.dart';

Future<void> showSettingsSheet(BuildContext context) =>
    showAppSheet(context, (_) => const SettingsSheet());

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
        Text(
          l.settings,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),

        SheetSectionLabel(l.language),
        SegmentedControl<AppLanguage>(
          value: s.language,
          onChanged: c.setLanguage,
          options: const [
            SegmentedOption(AppLanguage.ar, 'العربية'),
            SegmentedOption(AppLanguage.en, 'English'),
          ],
        ),

        SheetSectionLabel(l.appearance),
        SegmentedControl<AppearanceMode>(
          value: s.appearance,
          onChanged: c.setAppearance,
          options: [
            SegmentedOption(AppearanceMode.light, l.light),
            SegmentedOption(AppearanceMode.dark, l.dark),
            SegmentedOption(AppearanceMode.system, l.system),
          ],
        ),

        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.fontSize,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: t.muted,
                  ),
                ),
              ),
              _StepButton(label: '−', onTap: () => c.stepTextSize(-1)),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                child: Text(
                  switch (s.textSize) {
                    ThikrSize.small => l.fontSizeSmall,
                    ThikrSize.medium => l.fontSizeMedium,
                    ThikrSize.large => l.fontSizeLarge,
                  },
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StepButton(label: '+', onTap: () => c.stepTextSize(1)),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: c.toggleQuranFont,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: t.surface,
                border: Border.all(color: t.border),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.quranFont,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Live preview so the toggle shows its own effect.
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
                            style: TextStyle(
                              fontFamily: s.useQuranFont
                                  ? kQuranFont
                                  : kThikrFont,
                              fontSize: 17,
                              color: t.muted,
                            ),
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

        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l.done,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: t.onAccent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(label, style: TextStyle(fontSize: 16, color: t.ink)),
      ),
    );
  }
}
