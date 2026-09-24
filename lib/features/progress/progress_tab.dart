import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/labels.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/progress_providers.dart';
import '../../data/repositories/progress_repository.dart';
import '../settings/settings_controller.dart';

/// The routines the week card lists, in the board's order.
const _weekRows = [
  ThikrCategory.morning,
  ThikrCategory.evening,
  ThikrCategory.sleep,
];

/// Board 5.3.
class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final stats = ref.watch(progressStatsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      children: [
        PageTitle(l.titleProgress),
        const SizedBox(height: 12),
        _StreakCard(stats: stats),
        const SizedBox(height: 12),
        _LastFourteenCard(levels: stats.last14Routines),
        const SizedBox(height: 12),
        _WeekCard(
          categories: [
            for (final c in _weekRows)
              ...stats.byCategory.where((p) => p.category == c),
          ],
        ),
      ],
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard({required this.stats});

  final ProgressStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    String digits(int n) => localizeDigits(n, lang);

    final small = TextStyle(
      fontFamily: kUiFont,
      fontSize: 11.5,
      fontWeight: FontWeight.w300,
      color: t.onPrimaryMuted,
    );
    final figure = TextStyle(
      fontFamily: kUiFont,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: t.onPrimary,
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: t.primary,
        borderRadius: BorderRadius.circular(Radii.xl),
        border: t.isDark ? Border.all(color: t.glowLine) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.currentStreak,
                  style: TextStyle(
                    fontFamily: kUiFont,
                    fontSize: 12,
                    color: t.ctaOnPrimaryLabel,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      digits(stats.currentStreak),
                      style: TextStyle(
                        fontFamily: kUiFont,
                        fontSize: 52,
                        fontWeight: FontWeight.w300,
                        height: 1,
                        color: t.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l.daysUnit(stats.currentStreak),
                        style: small.copyWith(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Hugs the far edge of the card, as on the board; flexible only so
          // 200% text can wrap instead of overflowing.
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // Lines up on the card's outer edge (left in Arabic).
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l.longest, style: small),
                  Text(
                    l.daysCount(
                      stats.longestStreak,
                      digits(stats.longestStreak),
                    ),
                    style: figure,
                  ),
                  const SizedBox(height: 6),
                  Text(l.totalSessions, style: small),
                  Text(digits(stats.totalSessions), style: figure),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LastFourteenCard extends StatelessWidget {
  const _LastFourteenCard({required this.levels});

  /// Oldest first; routines completed each day, out of four.
  final List<int> levels;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final full = t.isDark ? t.cta : t.primary;

    Widget swatch(Color? fill, {Color? border}) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: fill,
        border: border == null ? null : Border.all(color: border),
        borderRadius: BorderRadius.circular(3),
      ),
    );

    Widget legend(Widget mark, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 5),
        Text(label, style: MishkatType.caption(t).copyWith(fontSize: 11)),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.last14, style: MishkatType.label(t).copyWith(fontSize: 13)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < levels.length; i++)
                Container(
                  decoration: BoxDecoration(
                    color: levels[i] >= kDailyRoutines.length
                        ? full
                        : levels[i] > 0
                        ? t.glow
                        : t.bg,
                    border: levels[i] > 0
                        ? null
                        : Border.all(
                            // Today is outlined, so it reads as still open.
                            color: i == levels.length - 1 ? full : t.line,
                            width: i == levels.length - 1 ? 1.5 : 1,
                          ),
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              legend(swatch(full), l.legendFull),
              legend(swatch(t.glow), l.legendPartial),
              legend(swatch(null, border: t.line), l.legendNone),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends ConsumerWidget {
  const _WeekCard({required this.categories});

  final List<CategoryProgress> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;

    String name(ThikrCategory c) => switch (c) {
      ThikrCategory.wake => l.slotWakeShort,
      ThikrCategory.morning => l.slotMorningShort,
      ThikrCategory.evening => l.slotEveningShort,
      ThikrCategory.sleep => l.slotSleepShort,
      _ => libraryLabel(l, c),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.byCategory,
            style: MishkatType.label(t).copyWith(fontSize: 13),
          ),
          for (final c in categories) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    name(c.category),
                    style: MishkatType.body(
                      t,
                    ).copyWith(fontSize: 12.5, height: 1.4),
                  ),
                ),
                Text(
                  l.weekRatio(
                    localizeDigits(c.done, lang),
                    localizeDigits(c.target, lang),
                  ),
                  style: MishkatType.caption(
                    t,
                  ).copyWith(fontSize: 12.5, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 6,
                child: ColoredBox(
                  color: t.lineSoft,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      heightFactor: 1,
                      widthFactor: c.fraction,
                      child: ColoredBox(color: t.isDark ? t.cta : t.primary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
