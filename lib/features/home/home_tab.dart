import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/labels.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/local/app_database.dart' show dayKey;
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../data/repositories/progress_providers.dart';
import '../../services/diagnostics.dart';
import '../reader/reader_screen.dart';
import '../reminders/reminder_controller.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_sheet.dart';
import '../shell/app_shell.dart';
import '../tasbih/tasbih_screen.dart';
import 'home_now.dart';

/// Home's "now" state from the real schedule inputs, completions and clock.
final homeNowProvider = Provider<HomeNow>((ref) {
  final now = ref.watch(clockProvider)();
  final rows = ref.watch(completionsProvider).value ?? const [];
  final today = dayKey(now);
  final yesterday = dayKey(DateTime(now.year, now.month, now.day - 1));
  Set<ThikrCategory> on(String day) => {
    for (final c in rows)
      if (c.day == day)
        ...ThikrCategory.values.where((v) => v.key == c.category),
  };
  return resolveHomeNow(
    settings: ref.watch(reminderSettingsProvider),
    prayerTimes: ref.watch(prayerTimesResolverProvider),
    completedToday: on(today),
    completedYesterday: on(yesterday),
    now: now,
  );
});

/// The routines listed under the now module — the ones without a daily slot.
const _library = [
  ThikrCategory.afterPrayer,
  ThikrCategory.misc,
  ThikrCategory.tasbih,
];

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(athkarLibraryProvider);

    return library.when(
      // The corpus is bundled and parses in milliseconds; a spinner would only
      // flash. Show nothing rather than a stutter.
      loading: () => const SizedBox.shrink(),
      error: (e, stack) => LoadFailure(error: e, stack: stack),
      data: (library) => _HomeBody(library: library),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.library});

  final AthkarLibrary library;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeNowProvider);
    final notificationsOff = !ref.watch(permissionsProvider).notifications;
    final band = _DayBand(home: home, compact: home.allDone);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      children: [
        const _Header(),
        const SizedBox(height: 14),
        if (notificationsOff) ...[
          const _NotificationsOffBanner(),
          const SizedBox(height: 14),
        ],
        if (home.allDone || home.current == null) ...[
          _RestCard(home: home),
          const SizedBox(height: 14),
          band,
        ] else ...[
          band,
          const _ScheduleCaption(),
          const SizedBox(height: 14),
          _NowModule(library: library, home: home),
        ],
        const SizedBox(height: 14),
        _LibraryList(library: library),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final streak = ref.watch(progressStatsProvider).currentStreak;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        BrandMark(size: 26, semanticLabel: l.brandName),
        Text(
          l.brandName,
          style: MishkatType.headline(t).copyWith(fontSize: 18),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 6,
            children: [
              Text(
                streak == 0
                    ? l.streakStart
                    : l.streakDays(streak, localizeDigits(streak, lang)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MishkatType.caption(t),
              ),
              const SizedBox(width: 6),
              IconCircleButton(
                icon: MIcon.settings,
                semanticLabel: l.settings,
                onPressed: () => showSettingsSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Four equal columns — waking, morning, evening, sleep — each a 4px bar, a
/// label and a time. Tapping a column opens that routine; "Edit times" opens
/// Reminders.
class _DayBand extends ConsumerWidget {
  const _DayBand({required this.home, required this.compact});

  final HomeNow home;

  /// The all-done variant: labels with ticks, no times, no header.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final library = ref.watch(athkarLibraryProvider).value;

    Color bar(BandState s) => switch (s) {
      BandState.done => t.isDark ? t.ink : t.primary,
      BandState.now => t.glow,
      BandState.later => t.line,
    };

    Widget column(BandSlot slot) {
      final isNow = slot.state == BandState.now;
      final time = formatClockShort(slot.at.hour, slot.at.minute, lang);
      final label = bandLabel(l, slot.id);
      final state = switch (slot.state) {
        BandState.done => l.stateDone,
        BandState.now => l.stateNow,
        BandState.later => l.stateLater,
      };
      return Expanded(
        child: Semantics(
          button: true,
          label: l.bandSemantics(slotLabel(l, slot.id), time, state),
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: library == null
                ? null
                : () => openReader(
                    context,
                    ref,
                    slot.id.category,
                    library[slot.id.category],
                  ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Sizes.touchMin),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: bar(slot.state),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Ticked(
                      text: label,
                      ticked: compact && slot.done,
                      style: TextStyle(
                        fontFamily: kUiFont,
                        fontSize: 11,
                        fontWeight: isNow ? FontWeight.w500 : FontWeight.w300,
                        color: isNow ? t.ink : t.inkMuted,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 8),
                      _Ticked(
                        text: time,
                        ticked: slot.done,
                        style: TextStyle(
                          fontFamily: kUiFont,
                          fontSize: 12.5,
                          fontWeight: isNow ? FontWeight.w500 : FontWeight.w400,
                          color: slot.state == BandState.later
                              ? t.inkMuted
                              : t.ink,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      // The "Edit times" row brings its own 48px touch height, so the card
      // needs no top padding when it is shown.
      padding: EdgeInsets.fromLTRB(11, compact ? 10 : 0, 11, 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => ref
                      .read(shellTabProvider.notifier)
                      .select(ShellTab.reminders),
                  child: ConstrainedBox(
                    // 48px to the touch, though it reads as a small link.
                    constraints: const BoxConstraints(
                      minHeight: Sizes.touchMin,
                      minWidth: Sizes.touchMin,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MishkatIcon(MIcon.clock, color: t.accentText, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          l.editTimes,
                          style: MishkatType.label(
                            t,
                          ).copyWith(fontSize: 12, color: t.accentText),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final slot in home.band) column(slot)],
          ),
        ],
      ),
    );
  }
}

/// One line under the band, only when the schedule is not what the band
/// implies: prayer times unavailable, or every reminder switched off. The
/// normal case says nothing — Reminders shows the full schedule state.
class _ScheduleCaption extends ConsumerWidget {
  const _ScheduleCaption();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final settings = ref.watch(reminderSettingsProvider);
    final schedule = ref.watch(currentScheduleProvider);

    final String? text;
    if (settings.enabledSlots.isEmpty) {
      text = l.remindersAllOff;
    } else if (schedule.usedFixedFallback) {
      text = l.prayerFallbackNotice;
    } else {
      text = null;
    }
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: MishkatIcon(MIcon.info, color: t.inkMuted, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: MishkatType.caption(t))),
        ],
      ),
    );
  }
}

/// The one coloured block on Home: what to read now, and one button.
class _NowModule extends ConsumerWidget {
  const _NowModule({required this.library, required this.home});

  final AthkarLibrary library;
  final HomeNow home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final category = home.current!.category;
    final items = library[category];
    final minutes = estimatedMinutes(items);

    final meta = [
      l.athkarCountLabel(items.length, localizeDigits(items.length, lang)),
      l.aboutMinutes(minutes, localizeDigits(minutes, lang)),
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: t.primary,
        borderRadius: BorderRadius.circular(Radii.xl),
        // Dark primary is a surface; the border is what makes it a module.
        border: t.isDark ? Border.all(color: t.glowLine) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.nowLabel,
            style: TextStyle(
              fontFamily: kUiFont,
              fontSize: 12,
              color: t.ctaOnPrimaryLabel,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            categoryLabel(l, category),
            style: MishkatType.display(t).copyWith(color: t.onPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            meta,
            style: TextStyle(
              fontFamily: kUiFont,
              fontSize: 13,
              fontWeight: FontWeight.w300,
              height: 1.5,
              color: t.onPrimaryMuted,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: l.begin,
            cta: true,
            onPressed: () => openReader(context, ref, category, items),
          ),
        ],
      ),
    );
  }
}

/// Shown when nothing is left today: a tick when every routine is done,
/// otherwise just what comes next.
class _RestCard extends ConsumerWidget {
  const _RestCard({required this.home});

  final HomeNow home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final next = home.next;
    final nextLine = next == null
        ? null
        : l.tomorrowAt(
            categoryLabel(l, next.id.category),
            formatTime(next.at, lang, am: l.am, pm: l.pm),
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
      child: Column(
        children: [
          IconHalo(
            icon: home.allDone ? MIcon.check : MIcon.clock,
            size: 56,
            iconSize: 26,
          ),
          const SizedBox(height: 10),
          Text(
            home.allDone ? l.allDoneTitle : l.nextLabel,
            textAlign: TextAlign.center,
            style: MishkatType.title(t),
          ),
          if (nextLine != null) ...[
            const SizedBox(height: 10),
            Text(
              nextLine,
              textAlign: TextAlign.center,
              style: MishkatType.caption(t).copyWith(fontSize: 13, height: 1.8),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationsOffBanner extends ConsumerWidget {
  const _NotificationsOffBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    return NoticeBanner(
      title: l.notifOffTitle,
      body: l.notifOffBody,
      actionLabel: l.openSettings,
      onAction: () async {
        final granted = await ref
            .read(permissionsProvider.notifier)
            .requestNotifications();
        // Once denied, Android stops showing the prompt; the system page is
        // the only way back.
        if (!granted) {
          await AppSettings.openAppSettings(type: AppSettingsType.notification);
        }
      },
    );
  }
}

class _LibraryList extends ConsumerWidget {
  const _LibraryList({required this.library});

  final AthkarLibrary library;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final tasbihCount = ref.watch(tasbihProvider).count;

    return GroupCard(
      children: [
        for (final c in _library)
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => c == ThikrCategory.tasbih
                  ? openTasbih(context)
                  : openReader(context, ref, c, library[c]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    IconChip(categoryIcon(c)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        libraryLabel(l, c),
                        style: MishkatType.body(
                          t,
                        ).copyWith(fontSize: 14, height: 1.4),
                      ),
                    ),
                    Text(
                      localizeDigits(
                        c == ThikrCategory.tasbih
                            ? tasbihCount
                            : library[c].length,
                        lang,
                      ),
                      style: MishkatType.caption(
                        t,
                      ).copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Board 5.5: the content failed to load. Never shows the raw exception —
/// that goes to diagnostics, and the user gets a way to try again.
class LoadFailure extends ConsumerStatefulWidget {
  const LoadFailure({super.key, required this.error, this.stack});

  final Object error;
  final StackTrace? stack;

  @override
  ConsumerState<LoadFailure> createState() => _LoadFailureState();
}

class _LoadFailureState extends ConsumerState<LoadFailure> {
  @override
  void initState() {
    super.initState();
    ref.read(diagnosticsProvider).recordError(widget.error, widget.stack);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.errorSoft,
                shape: BoxShape.circle,
              ),
              child: MishkatIcon(MIcon.info, color: t.error, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              l.errorTitle,
              textAlign: TextAlign.center,
              style: MishkatType.headline(t).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              l.errorBody,
              textAlign: TextAlign.center,
              style: MishkatType.bodyMuted(t).copyWith(fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l.retry,
              expand: false,
              onPressed: () => ref.invalidate(athkarLibraryProvider),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text followed by a small check. Drawn as the icon rather than "✓":
/// Alexandria has no check glyph, and a fallback font would render a box.
class _Ticked extends StatelessWidget {
  const _Ticked({
    required this.text,
    required this.ticked,
    required this.style,
  });

  final String text;
  final bool ticked;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.fade,
            style: style,
          ),
        ),
        if (ticked) ...[
          const SizedBox(width: 3),
          MishkatIcon(MIcon.check, color: style.color!, size: 12),
        ],
      ],
    );
  }
}
