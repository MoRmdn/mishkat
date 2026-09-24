import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/app_sheet.dart';
import '../../data/models/reminder_settings.dart';
import '../settings/settings_controller.dart';
import 'reminder_controller.dart';
import 'reminders_tab.dart';

Future<void> showSlotTimeSheet(BuildContext context, ReminderSlotId slot) =>
    showAppSheet(context, (_) => SlotTimeSheet(slot: slot));

/// Hour and minute steppers, matching the design.
///
/// Minutes move in fives: a reminder does not need minute precision, and a
/// stepper that took sixty taps to cross an hour would be hostile.
class SlotTimeSheet extends ConsumerWidget {
  const SlotTimeSheet({super.key, required this.slot});

  final ReminderSlotId slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final current = ref.watch(reminderSettingsProvider).slot(slot);
    final controller = ref.read(reminderSettingsProvider.notifier);

    final hour12 = current.hour % 12 == 0 ? 12 : current.hour % 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.timeOf(slotLabel(l, slot)),
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        // Clock digits read left-to-right in both languages.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Stepper(
                value: localizeDigits(hour12, lang),
                onUp: () => controller.shiftSlotTime(slot, hours: 1),
                onDown: () => controller.shiftSlotTime(slot, hours: -1),
                semanticsPrefix: 'hour',
              ),
              const SizedBox(width: 18),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(':', style: TextStyle(fontSize: 34, color: t.s3)),
              ),
              const SizedBox(width: 18),
              _Stepper(
                value: localizeDigits(
                  current.minute.toString().padLeft(2, '0'),
                  lang,
                ),
                onUp: () => controller.shiftSlotTime(slot, minutes: 5),
                onDown: () => controller.shiftSlotTime(slot, minutes: -5),
                semanticsPrefix: 'minute',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          '${current.hour < 12 ? l.am : l.pm} · ${l.repeatsDaily}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: t.muted),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Changes are already applied and rescheduled as they are made; this
          // button just dismisses.
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: t.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l.saveReschedule,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: t.onAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onUp,
    required this.onDown,
    required this.semanticsPrefix,
  });

  final String value;
  final VoidCallback onUp, onDown;
  final String semanticsPrefix;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    Widget button(MIcon icon, VoidCallback onTap, String label) => Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: t.s2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: MishkatIcon(icon, color: t.accent, size: 18),
        ),
      ),
    );

    return Column(
      children: [
        button(MIcon.chevronUp, onUp, '$semanticsPrefix up'),
        const SizedBox(height: 8),
        SizedBox(
          width: 64,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        button(MIcon.chevronDown, onDown, '$semanticsPrefix down'),
      ],
    );
  }
}
