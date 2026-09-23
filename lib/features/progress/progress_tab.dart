import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/streak_ring.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/progress_providers.dart';
import '../home/home_tab.dart' show categoryLabel;
import '../settings/settings_controller.dart';

class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(progressStatsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      children: [
        _StreakCard(stats: stats),
        const SizedBox(height: 14),
        _LastFourteenCard(days: stats.last14Days),
        const SizedBox(height: 14),
        _CategoryCard(categories: stats.byCategory),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The ring fills over a 30-day cycle, so a long streak keeps
                // showing movement rather than sitting pinned at full.
                StreakRing(
                  percent: (stats.currentStreak % 30) / 30 * 100,
                  size: 96,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizeDigits(stats.currentStreak, lang),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l.dayUnit,
                      style: TextStyle(fontSize: 11, color: t.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.currentStreak,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l.longest}: ${localizeDigits(stats.longestStreak, lang)} '
                  '${l.dayUnitPl}\n'
                  '${l.totalSessions}: '
                  '${localizeDigits(stats.totalSessions, lang)} ${l.sessions}',
                  style: TextStyle(fontSize: 13, height: 1.8, color: t.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LastFourteenCard extends ConsumerWidget {
  const _LastFourteenCard({required this.days});

  final List<bool> days;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.last14,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < days.length; i++)
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: days[i] ? t.accent : t.s2,
                    border: Border.all(color: days[i] ? t.accent : t.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    localizeDigits(i + 1, lang),
                    style: TextStyle(
                      fontSize: 11,
                      color: days[i] ? t.onAccent : t.faint,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({required this.categories});

  final List<CategoryProgress> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.byCategory,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          for (final c in categories) ...[
            if (c != categories.first) const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryLabel(l, c.category),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                Text(
                  '${localizeDigits(c.done, lang)} / '
                  '${localizeDigits(c.target, lang)}',
                  style: TextStyle(fontSize: 13, color: t.muted),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 6,
                color: t.s3,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: c.fraction,
                    child: Container(color: t.accent),
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
