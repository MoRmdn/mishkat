import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// `show` because intl also exports a TextDirection that shadows Flutter's.
import 'package:intl/intl.dart' show DateFormat;

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/prayer_settings.dart';
import '../../services/reminder_scheduler.dart';
import '../settings/settings_controller.dart';
import 'prayer_controller.dart';
import 'reminder_controller.dart';

/// Today's prayer times and where they are computed for (board 4.2).
///
/// When there is no position yet the times are left out rather than guessed —
/// the app never shows numbers it cannot stand behind.
class PrayerTimesCard extends ConsumerWidget {
  const PrayerTimesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final settings = ref.watch(prayerSettingsProvider);
    final lang = ref.watch(settingsProvider).language.name;
    final now = ref.watch(clockProvider)();
    final times = ref.watch(prayerTimeServiceProvider).timesFor(now, settings);

    final place = settings.useDeviceLocation
        ? (settings.hasDevicePosition
              ? l.cityAuto(l.location)
              : l.locationPending)
        : l.cityManual(settings.manualCity.name(lang));

    Widget cell(String label, DateTime time) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Column(
          children: [
            Text(label, style: MishkatType.caption(t).copyWith(fontSize: 11)),
            const SizedBox(height: 3),
            Text(
              formatTime(time, lang, am: l.am, pm: l.pm),
              maxLines: 1,
              softWrap: false,
              style: MishkatType.headline(t).copyWith(fontSize: 15),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.todayTimes, style: MishkatType.label(t))),
              Flexible(
                child: Semantics(
                  button: true,
                  label: '${l.location}: $place',
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => showCityPicker(context),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: Sizes.touchMin,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MishkatIcon(
                            MIcon.location,
                            color: t.accentText,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: kUiFont,
                                fontSize: 12,
                                color: t.accentText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (times != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                cell(l.fajr, times.fajr),
                const SizedBox(width: 8),
                cell(l.asr, times.asr),
                const SizedBox(width: 8),
                cell(l.maghrib, times.maghrib),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Calculation method and Asr madhab.
class PrayerSettingsCard extends ConsumerWidget {
  const PrayerSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final settings = ref.watch(prayerSettingsProvider);
    final controller = ref.read(prayerSettingsProvider.notifier);

    return GroupCard(
      children: [
        _SettingRow(
          label: l.method,
          value: switch (settings.method) {
            PrayerCalculationMethod.ummAlQura => l.methodUmmAlQura,
            PrayerCalculationMethod.muslimWorldLeague => l.methodMwl,
            PrayerCalculationMethod.egyptian => l.methodEgypt,
          },
          onTap: controller.cycleMethod,
        ),
        _SettingRow(
          label: l.madhab,
          value: settings.madhab == AsrMadhab.standard
              ? l.madhabStandard
              : l.madhabHanafi,
          onTap: controller.toggleMadhab,
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label, value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: MishkatType.body(
                      t,
                    ).copyWith(fontSize: 13.5, height: 1.4),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: MishkatType.body(t).copyWith(
                      fontSize: 13.5,
                      height: 1.4,
                      color: t.accentText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// How far ahead reminders are scheduled, and how close that is to the iOS
/// cap — the schedule is visible state, so the window never lapses silently.
class PrayerWindow extends ConsumerWidget {
  const PrayerWindow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final schedule = ref.watch(currentScheduleProvider);
    final pending =
        ref.watch(pendingCountProvider).value ?? schedule.pendingCount;
    final through = schedule.scheduledThrough;
    final fraction = (pending / kIosPendingCap).clamp(0.0, 1.0);

    final text = schedule.usedFixedFallback || through == null
        ? l.prayerFallbackNotice
        : l.windowShort(
            // DateFormat emits Latin digits even under `ar`.
            localizeDigits(DateFormat.MMMMd(lang).format(through), lang),
            localizeDigits(pending, lang),
            localizeDigits(kIosPendingCap, lang),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 4,
              child: ColoredBox(
                color: t.line,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    heightFactor: 1,
                    widthFactor: fraction,
                    child: ColoredBox(color: t.isDark ? t.glow : t.primary),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(text, style: MishkatType.caption(t).copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

Future<void> showCityPicker(BuildContext context) =>
    showAppSheet(context, (_) => const CityPickerSheet());

/// Lets the user name their city when device location is unavailable or
/// unwanted. Prayer times vary by only minutes across a city, so this is a
/// genuine alternative rather than a consolation prize.
class CityPickerSheet extends ConsumerWidget {
  const CityPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final settings = ref.watch(prayerSettingsProvider);
    final controller = ref.read(prayerSettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.chooseCity),
        const SizedBox(height: 16),
        SecondaryButton(
          label: l.useMyLocation,
          icon: MIcon.location,
          background: t.bg,
          onPressed: () async {
            await controller.useDeviceLocation();
            if (context.mounted) Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 12),
        GroupCard(
          color: t.bg,
          children: [
            for (final city in kPrayerCities)
              Semantics(
                button: true,
                selected:
                    !settings.useDeviceLocation &&
                    settings.manualCityId == city.id,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    controller.setManualCity(city.id);
                    Navigator.of(context).pop();
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 50),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              city.name(lang),
                              style: MishkatType.body(
                                t,
                              ).copyWith(fontSize: 14.5, height: 1.4),
                            ),
                          ),
                          if (!settings.useDeviceLocation &&
                              settings.manualCityId == city.id)
                            MishkatIcon(
                              MIcon.check,
                              color: t.accentText,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
