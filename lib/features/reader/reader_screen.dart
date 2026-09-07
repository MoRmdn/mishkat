import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../data/models/app_settings.dart';
import '../home/home_tab.dart';
import '../settings/settings_controller.dart';
import 'reader_controller.dart';

/// Opens [category] as a full-screen reading session.
Future<void> openReader(
  BuildContext context,
  WidgetRef ref,
  ThikrCategory category,
  List<Thikr> items,
) {
  if (items.isEmpty) return Future.value();
  ref.read(readerControllerProvider.notifier).open(category, items);
  return Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ReaderScreen(category: category),
    ),
  );
}

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.category});

  final ThikrCategory category;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _tapped = false;

  @override
  void initState() {
    super.initState();
    // The copy promises the screen stays awake while counting.
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  void _flashTap() {
    setState(() => _tapped = true);
    Future.delayed(const Duration(milliseconds: 130), () {
      if (mounted) setState(() => _tapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final library = ref.watch(athkarLibraryProvider).value;
    final state = ref.watch(readerControllerProvider);
    final session = state.session;

    if (library == null || session == null) {
      return Scaffold(backgroundColor: t.rdBg, body: const SizedBox.shrink());
    }

    final items = library[session.category];
    final controller = ref.read(readerControllerProvider.notifier);

    return Scaffold(
      backgroundColor: t.rdBg,
      body: SafeArea(
        child: Column(
          children: [
            _ReaderHeader(items: items, session: session),
            _ProgressBar(items: items, session: session),
            Expanded(
              child: session.finished
                  ? _DoneView(category: session.category)
                  : _CountingView(
                      items: items,
                      session: session,
                      library: library,
                      tapped: _tapped,
                      onTap: () {
                        _flashTap();
                        controller.countOne(items);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderHeader extends ConsumerWidget {
  const _ReaderHeader({required this.items, required this.session});

  final List<Thikr> items;
  final ReaderSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final state = ref.watch(readerControllerProvider);
    final current = items[session.index];

    Widget iconButton(Widget child, VoidCallback onTap, String label) {
      return Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: t.rdFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          iconButton(
            StrokeIcon(
              AppIcons.close,
              color: t.rdInk,
              size: 18,
              strokeWidth: 1.8,
            ),
            () {
              ref.read(readerControllerProvider.notifier).close();
              Navigator.of(context).pop();
            },
            'close',
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  categoryLabel(l, session.category),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: t.rdInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${localizeDigits(session.index + 1, lang)} ${l.countOf} '
                  '${localizeDigits(items.length, lang)}',
                  style: TextStyle(fontSize: 11.5, color: t.rdDim),
                ),
              ],
            ),
          ),
          iconButton(
            HeartIcon(
              color: t.gold,
              filled: state.favorites.contains(current.id),
            ),
            () => ref
                .read(readerControllerProvider.notifier)
                .toggleFavorite(current.id),
            'favorite',
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends ConsumerWidget {
  const _ProgressBar({required this.items, required this.session});

  final List<Thikr> items;
  final ReaderSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final state = ref.watch(readerControllerProvider);

    // Session progress: whole athkar done, plus the fraction of the current one.
    final current = items[session.index];
    final withinCurrent =
        (current.count - state.remainingFor(current)) / current.count;
    final fraction = session.finished
        ? 1.0
        : ((session.index + withinCurrent) / items.length).clamp(0.0, 1.0);

    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: t.rdFill,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: fraction,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: t.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountingView extends ConsumerWidget {
  const _CountingView({
    required this.items,
    required this.session,
    required this.library,
    required this.tapped,
    required this.onTap,
  });

  final List<Thikr> items;
  final ReaderSession session;
  final AthkarLibrary library;
  final bool tapped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language.name;
    final state = ref.watch(readerControllerProvider);
    final controller = ref.read(readerControllerProvider.notifier);

    final thikr = items[session.index];
    final remaining = state.remainingFor(thikr);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            // Centre the thikr in the available space, while still allowing a
            // long one at the largest text size to scroll. A Column cannot
            // centre inside an unbounded scroll view, hence the min-height box.
            child: LayoutBuilder(
              builder: (context, viewport) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewport.maxHeight - 34,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // The Arabic is always shown in full; a translation never
                        // replaces it.
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            thikr.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: settings.useQuranFont
                                  ? kQuranFont
                                  : kUiFont,
                              fontSize: settings.textSize.sizeFor(thikr.text),
                              height: 2.25,
                              color: t.rdInk,
                            ),
                          ),
                        ),
                        if (settings.language == AppLanguage.en) ...[
                          const SizedBox(height: 16),
                          Text(
                            thikr.meaningEn,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.85,
                              color: t.rdDim,
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Text(
                          library.referenceLine(thikr, lang),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: t.rdFaint),
                        ),
                        if (thikr.hasVirtue) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: t.rdFill,
                              border: Border.all(color: t.softBorder),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              thikr.virtue(lang) ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.9,
                                color: t.rdDim,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              children: [
                AnimatedScale(
                  scale: tapped ? 0.955 : 1,
                  duration: const Duration(milliseconds: 120),
                  child: _CountRing(
                    remaining: remaining,
                    total: thikr.count,
                    languageCode: lang,
                    label: thikr.count > 1
                        ? '${l.countOf} ${localizeDigits(thikr.count, lang)}'
                        : l.once,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l.tapHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, height: 1.6, color: t.rdDim),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ReaderButton(label: l.prev, onTap: controller.previous),
                    const SizedBox(width: 8),
                    _ReaderButton(
                      label: l.reset,
                      dim: true,
                      onTap: () => controller.resetCurrent(items),
                    ),
                    const SizedBox(width: 8),
                    _ReaderButton(
                      label: l.next,
                      onTap: () => controller.advance(items),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountRing extends StatelessWidget {
  const _CountRing({
    required this.remaining,
    required this.total,
    required this.languageCode,
    required this.label,
  });

  final int remaining, total;
  final String languageCode, label;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fraction = total == 0 ? 0.0 : (total - remaining) / total;

    return SizedBox(
      width: 148,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: -1.5708,
                endAngle: 4.7124,
                colors: [t.gold, t.gold, t.rdFill, t.rdFill],
                stops: [0, fraction, fraction, 1],
              ),
            ),
          ),
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              color: t.rdSurface,
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizeDigits(remaining, languageCode),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: -1,
                    color: t.rdInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(label, style: TextStyle(fontSize: 11.5, color: t.rdDim)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderButton extends StatelessWidget {
  const _ReaderButton({
    required this.label,
    required this.onTap,
    this.dim = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: t.rdFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 13, color: dim ? t.rdDim : t.rdInk),
        ),
      ),
    );
  }
}

class _DoneView extends ConsumerWidget {
  const _DoneView({required this.category});

  final ThikrCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;

    // Streak and the next reminder time become real in M6 and M4.
    const streak = 12;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.rdFill,
              shape: BoxShape.circle,
              border: Border.all(color: t.softBorder),
            ),
            child: StrokeIcon(
              AppIcons.check,
              color: t.gold,
              size: 36,
              strokeWidth: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l.doneTitle(categoryLabel(l, category)),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: t.rdInk,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.doneStreak(
              localizeDigits(streak, lang),
              formatClock(6, 30, lang, am: l.am, pm: l.pm),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.9, color: t.rdDim),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: t.gold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l.shareAsImage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: t.onGold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ref.read(readerControllerProvider.notifier).close();
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: t.softBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l.backHome,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: t.rdInk),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
