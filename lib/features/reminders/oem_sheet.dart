import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_sheet.dart';
import '../../services/permission_service.dart';
import '../settings/settings_controller.dart';
import 'reminder_controller.dart';

Future<void> showOemSheet(BuildContext context) =>
    showAppSheet(context, (_) => const OemSheet());

/// Guidance for vendors that kill background apps.
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
    final steps = [l.oemStep1, l.oemStep2, l.oemStep3, l.oemStep4];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          vendor.isEmpty ? l.oemTitle : l.oemHeading(vendor),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Text(
          l.oemBody,
          style: TextStyle(fontSize: 13.5, height: 1.9, color: t.muted),
        ),
        if (!PermissionService.needsOemGuidance(vendor)) ...[
          const SizedBox(height: 8),
          Text(
            l.oemGenericHint,
            style: TextStyle(fontSize: 12.5, height: 1.7, color: t.faint),
          ),
        ],
        const SizedBox(height: 18),
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: t.s2,
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
                    color: t.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    localizeDigits(i + 1, lang),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: t.onAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    steps[i],
                    style: const TextStyle(fontSize: 13.5, height: 1.8),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              ref.read(permissionsProvider.notifier).requestBatteryExemption(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: t.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l.openBattery,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: t.onAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          permissions.batteryExempt ? l.batteryOn : l.batteryOff,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: t.faint),
        ),
      ],
    );
  }
}
