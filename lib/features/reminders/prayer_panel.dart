import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_sheet.dart';
import '../../data/models/prayer_settings.dart';
import '../../services/reminder_scheduler.dart';
import '../settings/settings_controller.dart';
import 'prayer_controller.dart';
import 'reminder_controller.dart';

/// Today's prayer times, the scheduling window, and the settings behind them.
///
/// Shown only in prayer mode. When there is no position yet the times card is
/// replaced by a plain statement — the app never shows numbers it cannot stand
/// behind.
class PrayerPanel extends ConsumerWidget {
  const PrayerPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final settings = ref.watch(prayerSettingsProvider);
    final lang = ref.watch(settingsProvider).language.name;
    final now = ref.watch(clockProvider)();

    final times = ref.watch(prayerTimeServiceProvider).timesFor(now, settings);

    final placeName = settings.useDeviceLocation
        ? (settings.hasDevicePosition ? null : l.locationPending)
        : settings.manualCity.name(lang);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (times != null)
          _TodayTimesCard(
            fajr: times.fajr,
            asr: times.asr,
            maghrib: times.maghrib,
            placeName: placeName,
          ),
        const SizedBox(height: 14),
        _SettingsCard(settings: settings, languageCode: lang),
      ],
    );
  }
}

class _TodayTimesCard extends ConsumerWidget {
  const _TodayTimesCard({
    required this.fajr,
    required this.asr,
    required this.maghrib,
    required this.placeName,
  });

  final DateTime fajr, asr, maghrib;
  final String? placeName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;

    Widget cell(String label, DateTime time) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.s2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: t.muted)),
            const SizedBox(height: 5),
            Text(
              formatClock(time.hour, time.minute, lang, am: l.am, pm: l.pm),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            placeName == null ? l.todayTimes : l.todayTimesFor(placeName!),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: t.accent,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              cell(l.fajr, fajr),
              const SizedBox(width: 10),
              cell(l.asr, asr),
              const SizedBox(width: 10),
              cell(l.maghrib, maghrib),
            ],
          ),
          const _WindowIndicator(),
        ],
      ),
    );
  }
}

/// How far ahead reminders are scheduled, and how close that is to the iOS cap.
class _WindowIndicator extends ConsumerWidget {
  const _WindowIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final schedule = ref.watch(currentScheduleProvider);
    final pending =
        ref.watch(pendingCountProvider).value ?? schedule.pendingCount;

    final fraction = (pending / kIosPendingCap).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 1, color: t.borderSoft),
          const SizedBox(height: 14),
          Text(l.windowLabel, style: TextStyle(fontSize: 12.5, color: t.muted)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: t.s3,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(color: t.accent),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.windowText(
              localizeDigits(kScheduleWindowDays, lang),
              localizeDigits(pending, lang),
              localizeDigits(kIosPendingCap, lang),
            ),
            style: TextStyle(fontSize: 12.5, height: 1.6, color: t.muted),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard({required this.settings, required this.languageCode});

  final PrayerSettings settings;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final controller = ref.read(prayerSettingsProvider.notifier);

    final locationText = settings.useDeviceLocation
        ? (settings.hasDevicePosition
              ? l.cityAuto(l.location)
              : l.locationPending)
        : l.cityManual(settings.manualCity.name(languageCode));

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
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
          _SettingRow(
            label: l.location,
            value: locationText,
            last: true,
            onTap: () => showCityPicker(context),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.onTap,
    this.last = false,
  });

  final String label, value;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: t.borderSoft)),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: t.accent,
                ),
              ),
            ),
          ],
        ),
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
        Text(
          l.chooseCity,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            await controller.useDeviceLocation();
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: settings.useDeviceLocation ? t.accent : t.surface,
              border: Border.all(
                color: settings.useDeviceLocation ? t.accent : t.border,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l.useMyLocation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: settings.useDeviceLocation ? t.onAccent : t.ink,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final city in kPrayerCities)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              controller.setManualCity(city.id);
              Navigator.of(context).pop();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: t.s2,
                border: Border.all(
                  color:
                      !settings.useDeviceLocation &&
                          settings.manualCityId == city.id
                      ? t.accent
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                city.name(lang),
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
      ],
    );
  }
}
