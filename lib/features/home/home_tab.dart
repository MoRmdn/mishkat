import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../reader/reader_controller.dart';
import '../reader/reader_screen.dart';
import '../settings/settings_controller.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(athkarLibraryProvider);

    return library.when(
      // The corpus is bundled and parses in milliseconds; a spinner would only
      // flash. Show nothing rather than a stutter.
      loading: () => const SizedBox.shrink(),
      error: (e, _) => _LoadFailure(error: e),
      data: (library) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
        children: [
          const _NextReminderCard(),
          const SizedBox(height: 14),
          _CategoryGrid(library: library),
          const SizedBox(height: 14),
          _TasbihCard(library: library),
        ],
      ),
    );
  }
}

/// The next reminder, as the design's gradient card.
///
/// The slot shown is the design's default (morning, 6:30, fixed mode). M4 wires
/// this to real reminder settings and M5 to computed prayer times; until then
/// only the countdown is live.
class _NextReminderCard extends ConsumerWidget {
  const _NextReminderCard();

  static const int _slotHour = 6;
  static const int _slotMinute = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;

    final now = ref.watch(clockProvider)();
    var next = DateTime(now.year, now.month, now.day, _slotHour, _slotMinute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    final until = next.difference(now);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [t.card1, t.card2],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.nextReminder,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: t.cardInk,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: t.cardChip,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l.edit,
                    style: TextStyle(fontSize: 12, color: t.cardInk),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 10,
            children: [
              Text(
                formatClock(_slotHour, _slotMinute, lang, am: l.am, pm: l.pm),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                  color: t.cardInk,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  l.slotMorning,
                  style: TextStyle(fontSize: 17, color: t.cardInk),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.inHours(
              localizeDigits(until.inHours, lang),
              localizeDigits(until.inMinutes % 60, lang),
            ),
            style: TextStyle(fontSize: 14, height: 1.7, color: t.cardSub),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
          const SizedBox(height: 12),
          Row(
            children: [
              StrokeIcon(
                AppIcons.check,
                color: t.cardInk,
                size: 14,
                strokeWidth: 2,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.schedFixed,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.6,
                    color: t.cardSub,
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

class _CategoryGrid extends ConsumerWidget {
  const _CategoryGrid({required this.library});

  final AthkarLibrary library;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rows of two sized to their content rather than a fixed aspect ratio:
    // category names wrap to two lines in Arabic, at larger text sizes, and in
    // some translations, and a fixed ratio clips them.
    final categories = ThikrCategory.homeGrid;
    return Column(
      children: [
        for (var i = 0; i < categories.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CategoryCard(
                    category: categories[i],
                    items: library[categories[i]],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < categories.length
                      ? _CategoryCard(
                          category: categories[i + 1],
                          items: library[categories[i + 1]],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

String categoryLabel(L l, ThikrCategory c) => switch (c) {
  ThikrCategory.morning => l.catMorning,
  ThikrCategory.evening => l.catEvening,
  ThikrCategory.sleep => l.catSleep,
  ThikrCategory.wake => l.catWake,
  ThikrCategory.afterPrayer => l.catAfterPrayer,
  ThikrCategory.misc => l.catMisc,
  ThikrCategory.tasbih => l.catTasbih,
};

String categoryIconPath(ThikrCategory c) => switch (c) {
  ThikrCategory.morning => AppIcons.morning,
  ThikrCategory.evening => AppIcons.evening,
  ThikrCategory.sleep => AppIcons.sleep,
  ThikrCategory.wake => AppIcons.wake,
  ThikrCategory.afterPrayer => AppIcons.afterPrayer,
  ThikrCategory.misc => AppIcons.misc,
  ThikrCategory.tasbih => AppIcons.misc,
};

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({required this.category, required this.items});

  final ThikrCategory category;
  final List<Thikr> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final state = ref.watch(readerControllerProvider);

    final done = ref
        .read(readerControllerProvider.notifier)
        .completedCount(items);
    final subtitle = state.completedToday.contains(category)
        ? l.completedToday
        : done == 0
        ? l.athkarCount(localizeDigits(items.length, lang))
        : '${localizeDigits(done, lang)} ${l.countOf} '
              '${localizeDigits(items.length, lang)}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openReader(context, ref, category, items),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 0),
            StrokeIcon(
              categoryIconPath(category),
              color: t.accent,
              size: 24,
              strokeWidth: 1.5,
              extraShapes: category == ThikrCategory.misc
                  ? AppIcons.miscShapes
                  : '',
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryLabel(l, category),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: t.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TasbihCard extends ConsumerWidget {
  const _TasbihCard({required this.library});

  final AthkarLibrary library;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final items = library[ThikrCategory.tasbih];
    final state = ref.watch(readerControllerProvider);

    // The tasbih counts up from zero rather than down to it.
    final counted = items.isEmpty
        ? 0
        : items.first.count - state.remainingFor(items.first);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openReader(context, ref, ThikrCategory.tasbih, items),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: t.softBg,
          border: Border.all(color: t.softBorder, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.tasbihTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l.tasbihSub,
                    style: TextStyle(fontSize: 12.5, color: t.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.surface,
                shape: BoxShape.circle,
                border: Border.all(color: t.border),
              ),
              child: Text(
                localizeDigits(counted, lang),
                style: TextStyle(
                  fontSize: 13,
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

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          '$error',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: t.muted),
        ),
      ),
    );
  }
}
