import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../services/permission_service.dart';
import '../settings/settings_controller.dart';
import 'reminder_controller.dart';

Future<void> showOemSheet(BuildContext context) =>
    showAppSheet(context, (_) => const OemSheet());

/// Board 4.4: guidance for vendors that kill background apps.
///
/// This is the single biggest cause of "the reminder never came", and no app —
/// native or Flutter — can fix it from code. Phrased as a one-time setup step
/// rather than an apology.
class OemSheet extends ConsumerWidget {
  const OemSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final permissions = ref.watch(permissionsProvider);

    final vendor = permissions.manufacturer;
    final steps = [l.oemStep1, l.oemStep2, l.oemStep3];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(vendor.isEmpty ? l.oemTitle : l.oemHeading(vendor)),
        const SizedBox(height: 8),
        Text(l.oemBody, style: MishkatType.bodyMuted(t).copyWith(fontSize: 13)),
        if (!PermissionService.needsOemGuidance(vendor)) ...[
          const SizedBox(height: 4),
          Text(l.oemGenericHint, style: MishkatType.caption(t)),
        ],
        const SizedBox(height: 16),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: t.bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.isDark ? t.cta : t.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    localizeDigits(i + 1, lang),
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: 12,
                      color: t.isDark ? t.onCta : t.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[i],
                    style: MishkatType.body(
                      t,
                    ).copyWith(fontSize: 13, height: 1.7),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        PrimaryButton(
          label: l.openBattery,
          icon: MIcon.external,
          trailingIcon: true,
          onPressed: () =>
              ref.read(permissionsProvider.notifier).requestBatteryExemption(),
        ),
        const SizedBox(height: 10),
        Text(
          permissions.batteryExempt ? l.batteryOn : l.batteryOff,
          textAlign: TextAlign.center,
          style: MishkatType.caption(t),
        ),
      ],
    );
  }
}
