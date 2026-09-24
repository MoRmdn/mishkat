import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/labels.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../data/repositories/progress_providers.dart';
import '../reader/reader_controller.dart';
import '../reader/reader_screen.dart';
import '../settings/settings_controller.dart';
import '../share/share_card.dart';
import '../shell/app_shell.dart';

/// Boards 5.1 and 5.2.
class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    final library = ref.watch(athkarLibraryProvider).value;
    final favorites = ref.watch(favoritesProvider).value;

    final title = Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: PageTitle(l.titleFavorites),
    );
    if (library == null || favorites == null) {
      return Align(alignment: AlignmentDirectional.topStart, child: title);
    }

    // A favourite whose thikr is no longer in the corpus is skipped rather
    // than rendered as a blank card.
    final items = favorites
        .map((f) => library.byId(f.thikrId))
        .whereType<Thikr>()
        .toList();

    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const Expanded(child: _EmptyState()),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        title,
        for (final thikr in items)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _FavoriteCard(thikr: thikr, library: library),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(l.favHint, style: MishkatType.caption(context.tokens)),
        ),
      ],
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
    final lang = settings.language.name;
    void remove() =>
        ref.read(readerControllerProvider.notifier).toggleFavorite(thikr.id);

    final reference = library.referenceLine(thikr, lang);
    final footer = thikr.count > 1
        ? '$reference · ${l.timesCount(thikr.count, localizeDigits(thikr.count, lang))}'
        : reference;

    return Dismissible(
      key: ValueKey(thikr.id),
      onDismissed: (_) => remove(),
      child: Semantics(
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () =>
              openReader(context, ref, thikr.category, [thikr], subset: true),
          onLongPress: () => showShareSheet(context, thikr),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        categoryLabel(l, thikr.category),
                        style: MishkatType.label(
                          t,
                        ).copyWith(fontSize: 12, color: t.accentText),
                      ),
                    ),
                    IconCircleButton(
                      icon: MIcon.heartFilled,
                      size: 32,
                      background: t.surface,
                      color: t.isDark ? t.accentText : t.primary,
                      semanticLabel: l.favoriteRemove,
                      onPressed: remove,
                    ),
                  ],
                ),
                Text(
                  thikr.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: settings.useQuranFont ? kQuranFont : kThikrFont,
                    fontSize: 22,
                    height: 2,
                    color: t.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        footer,
                        style: MishkatType.caption(t).copyWith(fontSize: 11.5),
                      ),
                    ),
                    IconCircleButton(
                      icon: MIcon.share,
                      size: 40,
                      iconSize: 16,
                      background: t.bg,
                      semanticLabel: l.share,
                      onPressed: () => showShareSheet(context, thikr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IconHalo(icon: MIcon.heart, iconSize: 34),
            const SizedBox(height: 20),
            Text(
              l.favEmptyTitle,
              textAlign: TextAlign.center,
              style: MishkatType.headline(t).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              l.favEmptyBody,
              textAlign: TextAlign.center,
              style: MishkatType.bodyMuted(t).copyWith(fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            SecondaryButton(
              label: l.browseAthkar,
              expand: false,
              onPressed: () =>
                  ref.read(shellTabProvider.notifier).select(ShellTab.home),
            ),
          ],
        ),
      ),
    );
  }
}
