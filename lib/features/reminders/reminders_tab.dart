import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `show` because intl also exports a TextDirection that shadows Flutter's.
import 'package:intl/intl.dart' show DateFormat;

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/labels.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/segmented_control.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/reminder_settings.dart';
import '../home/home_now.dart' show slotTimeOn;
import '../settings/settings_controller.dart';
import '../update/update_banners.dart';
import '../update/update_controller.dart';
import 'oem_sheet.dart';
import 'prayer_panel.dart';
import 'reminder_controller.dart';
import 'slot_time_sheet.dart';

/// Boards 4.1 (fixed times) and 4.2 (prayer times).
class RemindersTab extends ConsumerWidget {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final settings = ref.watch(reminderSettingsProvider);
    final permissions = ref.watch(permissionsProvider);
    final prayer = settings.mode == ReminderMode.prayer;
    // Below the minimum version reminder changes do not take; say why.
    final locked = ref.watch(updateBlocksWritesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      children: [
        PageTitle(l.titleReminders),
        const SizedBox(height: 12),
        if (locked) ...[const UpdateLockedBanner(), const SizedBox(height: 12)],
        SegmentedControl<ReminderMode>(
          value: settings.mode,
          onChanged: ref.read(reminderSettingsProvider.notifier).setMode,
          options: [
            SegmentedOption(ReminderMode.fixed, l.fixedMode),
            SegmentedOption(ReminderMode.prayer, l.prayerMode),
          ],
        ),
        if (!permissions.notifications) ...[
          const SizedBox(height: 12),
          NoticeBanner(
            title: l.notifOffTitle,
            body: l.notifOffBody,
            actionLabel: l.openSettings,
            onAction: () async {
              final granted = await ref
                  .read(permissionsProvider.notifier)
                  .requestNotifications();
              if (!granted) {
                await AppSettings.openAppSettings(
                  type: AppSettingsType.notification,
                );
              }
            },
          ),
        ] else if (!permissions.exactAlarms) ...[
          // Persistent while exact alarms are denied: reminders still fire,
          // inexactly, and the user should know why one came late.
          const SizedBox(height: 12),
          NoticeBanner(
            body: l.exactBanner,
            actionLabel: l.allow,
            inlineAction: true,
            onAction: () =>
                ref.read(permissionsProvider.notifier).requestExactAlarms(),
          ),
        ],
        if (prayer) ...[const SizedBox(height: 12), const PrayerTimesCard()],
        const SizedBox(height: 12),
        GroupCard(
          children: [
            for (final slot in settings.slots)
              _SlotRow(slot: slot, mode: settings.mode),
          ],
        ),
        const SizedBox(height: 12),
        if (prayer) ...[
          const PrayerSettingsCard(),
          const SizedBox(height: 12),
          const PrayerWindow(),
        ] else
          const _ScheduleState(),
        const SizedBox(height: 12),
        const _OemRow(),
      ],
    );
  }
}

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
    final prayerTimes = ref.watch(prayerTimesResolverProvider);
    final now = ref.watch(clockProvider)();

    String clock(DateTime at) => formatTime(at, lang, am: l.am, pm: l.pm);

    final String subtitle;
    if (mode == ReminderMode.prayer) {
      // The rule, then the time it produces today.
      final at = slotTimeOn(slot, mode, prayerTimes, now);
      subtitle = locked
          ? '${slotPrayerRule(l, slot.id)} · ${clock(at)}'
          : slotPrayerRule(l, slot.id);
    } else {
      subtitle = slot.enabled ? l.slotDaily : l.off;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: locked ? 58 : 62),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _shortName(l, slot.id),
                    style: MishkatType.body(t).copyWith(
                      fontSize: locked ? 14 : 14.5,
                      height: 1.4,
                      color: slot.enabled ? t.ink : t.inkMuted,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: MishkatType.caption(
                      t,
                    ).copyWith(fontSize: 11.5, height: 1.5),
                  ),
                ],
              ),
            ),
            // A prayer-anchored slot has no clock time of its own to edit.
            if (!locked) ...[
              const SizedBox(width: 8),
              TimeChip(
                label: formatClock(
                  slot.hour,
                  slot.minute,
                  lang,
                  am: l.am,
                  pm: l.pm,
                ),
                enabled: slot.enabled,
                semanticLabel: l.timeOf(slotLabel(l, slot.id)),
                onTap: () => showSlotTimeSheet(context, slot.id),
              ),
            ],
            const SizedBox(width: 4),
            AppSwitch(
              value: slot.enabled,
              semanticLabel: slotLabel(l, slot.id),
              onChanged: () => ref
                  .read(reminderSettingsProvider.notifier)
                  .toggleSlot(slot.id),
            ),
          ],
        ),
      ),
    );
  }

  /// The list names the time of day; the routine is implied by the tab.
  static String _shortName(L l, ReminderSlotId id) => switch (id) {
    ReminderSlotId.wake => l.slotWakeShort,
    ReminderSlotId.morning => l.slotMorningShort,
    ReminderSlotId.evening => l.slotEveningShort,
    ReminderSlotId.sleep => l.slotSleepShort,
  };
}

/// Fixed mode's line of schedule state: what the OS holds, in plain words.
class _ScheduleState extends ConsumerWidget {
  const _ScheduleState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final schedule = ref.watch(currentScheduleProvider);
    final pending =
        ref.watch(pendingCountProvider).value ?? schedule.pendingCount;

    final through = schedule.scheduledThrough;
    final String state;
    if (schedule.usedFixedFallback) {
      state = l.prayerFallbackNotice;
    } else if (through == null) {
      state = l.schedFixed;
    } else {
      // DateFormat emits Latin digits even under `ar`, and the rest of this
      // sentence is Arabic-Indic.
      state = l.scheduleThroughShort(
        localizeDigits(DateFormat.MMMd(lang).format(through), lang),
      );
    }
    final text = '$state · ${l.pendingShort(localizeDigits(pending, lang))}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: MishkatIcon(MIcon.check, color: t.inkMuted, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: MishkatType.caption(t))),
        ],
      ),
    );
  }
}

class _OemRow extends ConsumerWidget {
  const _OemRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showOemSheet(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          child: Row(
            children: [
              MishkatIcon(
                MIcon.battery,
                color: t.isDark ? t.accentText : t.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.oemTitle,
                  style: MishkatType.body(
                    t,
                  ).copyWith(fontSize: 13.5, height: 1.4),
                ),
              ),
              // Mirrors itself under RTL, so it always points the way the
              // sheet opens.
              MishkatIcon(MIcon.chevronRight, color: t.inkMuted, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
