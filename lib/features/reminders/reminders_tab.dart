import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `show` because intl also exports a TextDirection that shadows Flutter's.
import 'package:intl/intl.dart' show DateFormat;

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/segmented_control.dart';
import '../../data/models/reminder_settings.dart';
import '../settings/settings_controller.dart';
import 'oem_sheet.dart';
import 'prayer_panel.dart';
import 'reminder_controller.dart';
import 'slot_time_sheet.dart';

class RemindersTab extends ConsumerWidget {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final settings = ref.watch(reminderSettingsProvider);
    final permissions = ref.watch(permissionsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      children: [
        SegmentedControl<ReminderMode>(
          value: settings.mode,
          onChanged: ref.read(reminderSettingsProvider.notifier).setMode,
          options: [
            SegmentedOption(ReminderMode.fixed, l.fixedMode),
            SegmentedOption(ReminderMode.prayer, l.prayerMode),
          ],
        ),
        if (!permissions.notifications) ...[
          const SizedBox(height: 14),
          _WarningCard(
            title: l.notificationsBlocked,
            body: l.onb2Body,
            action: l.enableNotifications,
            onAction: () =>
                ref.read(permissionsProvider.notifier).requestNotifications(),
          ),
        ],
        if (permissions.notifications && !permissions.exactAlarms) ...[
          const SizedBox(height: 14),
          _WarningCard(
            title: l.exactTitle,
            body: l.exactBody,
            action: l.exactAllow,
            onAction: () =>
                ref.read(permissionsProvider.notifier).requestExactAlarms(),
          ),
        ],
        const SizedBox(height: 14),
        const _SlotList(),
        if (settings.mode == ReminderMode.prayer) ...[
          const SizedBox(height: 14),
          const PrayerPanel(),
        ],
        const SizedBox(height: 14),
        const _OemCard(),
      ],
    );
  }
}

class _WarningCard extends StatelessWidget {
  const _WarningCard({
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
  });

  final String title, body, action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.warnBg,
        border: Border.all(color: t.warnBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: MishkatIcon(MIcon.warning, color: t.warnBtn, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.warnInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.8,
                    color: t.warnBody,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: t.warnBtn,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      action,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.warnBtnInk,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotList extends ConsumerWidget {
  const _SlotList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final settings = ref.watch(reminderSettingsProvider);

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final slot in settings.slots)
            _SlotRow(slot: slot, mode: settings.mode),
          const _ScheduleStateRow(),
        ],
      ),
    );
  }
}

String slotLabel(L l, ReminderSlotId id) => switch (id) {
  ReminderSlotId.wake => l.slotWake,
  ReminderSlotId.morning => l.slotMorning,
  ReminderSlotId.evening => l.slotEvening,
  ReminderSlotId.sleep => l.slotSleep,
};

String slotPrayerRule(L l, ReminderSlotId id) => switch (id) {
  ReminderSlotId.wake => l.slotPrayerWake,
  ReminderSlotId.morning => l.slotPrayerMorning,
  ReminderSlotId.evening => l.slotPrayerEvening,
  ReminderSlotId.sleep => l.slotPrayerSleep,
};

class _SlotRow extends ConsumerWidget {
  const _SlotRow({required this.slot, required this.mode});

  final ReminderSlot slot;
  final ReminderMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final locked = slot.lockedInPrayerMode(mode);

    final subtitle = mode == ReminderMode.prayer
        ? slotPrayerRule(l, slot.id)
        : slot.enabled
        ? l.daily
        : l.off;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.borderSoft)),
      ),
      child: Row(
        children: [
          Semantics(
            label: slotLabel(l, slot.id),
            toggled: slot.enabled,
            child: AppSwitch(
              value: slot.enabled,
              onChanged: () => ref
                  .read(reminderSettingsProvider.notifier)
                  .toggleSlot(slot.id),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slotLabel(l, slot.id),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: slot.enabled ? t.ink : t.faint,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, height: 1.6, color: t.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // A prayer-anchored slot has no clock time of its own to edit.
            onTap: locked ? null : () => showSlotTimeSheet(context, slot.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: slot.enabled ? t.softBg : t.disBg,
                border: Border.all(
                  color: slot.enabled ? t.softBorder : t.disBorder,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                locked
                    ? '—'
                    : formatClock(
                        slot.hour,
                        slot.minute,
                        lang,
                        am: l.am,
                        pm: l.pm,
                      ),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: slot.enabled ? t.accent : t.disFg,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Prints what the OS is actually holding.
///
/// The design treats the schedule as visible state: fixed mode says it never
/// needs the app opened, prayer mode names the date coverage runs out and how
/// many notifications are pending against the iOS cap.
class _ScheduleStateRow extends ConsumerWidget {
  const _ScheduleStateRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final schedule = ref.watch(currentScheduleProvider);

    final through = schedule.scheduledThrough;
    final text = schedule.usedFixedFallback
        ? l.prayerFallbackNotice
        : through == null
        ? l.schedFixed
        : l.scheduleThroughShort(
            // DateFormat emits Latin digits even under `ar`, and the rest of
            // this sentence is Arabic-Indic.
            localizeDigits(DateFormat.MMMd(lang).format(through), lang),
          );

    return Container(
      width: double.infinity,
      color: t.s2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: MishkatIcon(MIcon.check, color: t.accent, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(fontSize: 12.5, height: 1.6, color: t.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OemCard extends ConsumerWidget {
  const _OemCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final permissions = ref.watch(permissionsProvider);

    final hint = permissions.batteryExempt
        ? l.oemHintOn
        : l.oemHintOff(
            permissions.manufacturer.isEmpty
                ? l.oemTitle
                : permissions.manufacturer,
          );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showOemSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.oemTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hint,
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.6,
                      color: t.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Mirrors itself under RTL, so it always points the way the
            // sheet opens.
            MishkatIcon(MIcon.chevronRight, color: t.muted, size: 18),
          ],
        ),
      ),
    );
  }
}
