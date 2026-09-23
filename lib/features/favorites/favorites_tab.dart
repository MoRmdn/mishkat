import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../data/repositories/progress_providers.dart';
import '../home/home_tab.dart' show categoryLabel;
import '../reader/reader_controller.dart';
import '../settings/settings_controller.dart';
import '../share/share_card.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(athkarLibraryProvider).value;
    final favorites = ref.watch(favoritesProvider).value;

    if (library == null || favorites == null) return const SizedBox.shrink();

    // A favourite whose thikr is no longer in the corpus is skipped rather
    // than rendered as a blank card.
    final items = favorites
        .map((f) => library.byId(f.thikrId))
        .whereType<Thikr>()
        .toList();

    if (items.isEmpty) return const _EmptyState();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) =>
          _FavoriteCard(thikr: items[i], library: library),
    );
  }
}

class _FavoriteCard extends ConsumerWidget {
  const _FavoriteCard({required this.thikr, required this.library});

  final Thikr thikr;
  final AthkarLibrary library;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final settings = ref.watch(settingsProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Long-press to share, as the design specifies.
      onLongPress: () => showShareSheet(context, thikr),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    categoryLabel(l, thikr.category),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: t.accent,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'unfavorite',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref
                        .read(readerControllerProvider.notifier)
                        .toggleFavorite(thikr.id),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: HeartIcon(color: t.accent, filled: true, size: 19),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                thikr.text,
                style: TextStyle(
                  fontFamily: settings.useQuranFont ? kQuranFont : kUiFont,
                  fontSize: 19,
                  height: 2.05,
                  color: t.ink,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              library.referenceLine(thikr, settings.language.name),
              style: TextStyle(fontSize: 12, color: t.faint),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.favEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: t.muted),
            ),
            const SizedBox(height: 8),
            Text(
              l.favEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.8, color: t.muted),
            ),
          ],
        ),
      ),
    );
  }
}
