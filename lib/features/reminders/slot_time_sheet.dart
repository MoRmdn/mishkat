import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/labels.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../data/models/reminder_settings.dart';
import '../settings/settings_controller.dart';
import 'reminder_controller.dart';

Future<void> showSlotTimeSheet(BuildContext context, ReminderSlotId slot) =>
    showAppSheet(context, (_) => SlotTimeSheet(slot: slot));

/// Board 4.3: hour and minute steppers with an AM/PM choice.
///
/// Minutes move in fives: a reminder does not need minute precision, and a
/// stepper that took sixty taps to cross an hour would be hostile. Changes
/// apply — and reschedule — as they are made; the button dismisses.
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
    final pm = current.hour >= 12;

    void setHalf(bool toPm) => controller.setSlotTime(
      slot,
      hour: current.hour % 12 + (toPm ? 12 : 0),
      minute: current.minute,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.timeOf(slotLabel(l, slot))),
        const SizedBox(height: 22),
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
                upLabel: l.hourUp,
                downLabel: l.hourDown,
              ),
              const SizedBox(width: 14),
              ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    ':',
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: t.trackOff,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              _Stepper(
                value: localizeDigits(
                  current.minute.toString().padLeft(2, '0'),
                  lang,
                ),
                onUp: () => controller.shiftSlotTime(slot, minutes: 5),
                onDown: () => controller.shiftSlotTime(slot, minutes: -5),
                upLabel: l.minuteUp,
                downLabel: l.minuteDown,
              ),
              const SizedBox(width: 22),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HalfChip(
                    label: l.am,
                    selected: !pm,
                    onTap: () => setHalf(false),
                  ),
                  const SizedBox(height: 6),
                  _HalfChip(
                    label: l.pm,
                    selected: pm,
                    onTap: () => setHalf(true),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l.timeSheetHint,
          textAlign: TextAlign.center,
          style: MishkatType.caption(t).copyWith(fontSize: 12.5),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: l.saveReschedule,
          onPressed: () => Navigator.of(context).pop(),
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
    required this.upLabel,
    required this.downLabel,
  });

  final String value;
  final VoidCallback onUp, onDown;
  final String upLabel, downLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    Widget button(MIcon icon, VoidCallback onTap, String label) => Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 56,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: t.bg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: MishkatIcon(
            icon,
            color: t.isDark ? t.accentText : t.primary,
            size: 16,
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(MIcon.chevronUp, onUp, upLabel),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kUiFont,
              fontSize: 44,
              fontWeight: FontWeight.w300,
              height: 1.1,
              color: t.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        button(MIcon.chevronDown, onDown, downLabel),
      ],
    );
  }
}

class _HalfChip extends StatelessWidget {
  const _HalfChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fill = selected ? (t.isDark ? t.cta : t.primary) : t.bg;
    final ink = selected ? (t.isDark ? t.onCta : t.onPrimary) : t.ink;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 40,
          constraints: const BoxConstraints(minWidth: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(fontFamily: kUiFont, fontSize: 13, color: ink),
          ),
        ),
      ),
    );
  }
}
