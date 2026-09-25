import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/labels.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../data/repositories/progress_providers.dart';
import '../../services/auth/auth_service.dart';
import '../../services/diagnostics.dart';
import '../feedback/feedback_sheet.dart';
import '../reminders/reminder_controller.dart';
import '../settings/settings_controller.dart';
import '../share/share_card.dart';
import 'reader_controller.dart';

/// Opens [category] as a full-screen reading session.
///
/// [subset] reads only [items] — a single saved thikr, say — instead of the
/// whole routine.
Future<void> openReader(
  BuildContext context,
  WidgetRef ref,
  ThikrCategory category,
  List<Thikr> items, {
  bool subset = false,
  bool restart = false,
}) async {
  if (items.isEmpty) return;
  final controller = ref.read(readerControllerProvider.notifier);
  try {
    if (!await controller.open(
      category,
      items,
      subset: subset,
      restart: restart,
    )) {
      return;
    }
  } catch (error, stack) {
    if (!context.mounted) return;
    ref.read(diagnosticsProvider).recordError(error, stack);
    final l = L.of(context);
    final startAgain = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.readerRestoreError),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.close),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.readerStartAgain),
          ),
        ],
      ),
    );
    if (startAgain == true && context.mounted) {
      return openReader(
        context,
        ref,
        category,
        items,
        subset: subset,
        restart: true,
      );
    }
    return;
  }
  if (!context.mounted) return;
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ReaderScreen(category: category),
    ),
  );
}

/// Boards 3.1–3.4. Follows the app's appearance: light or dark, never forced.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.category});

  final ThikrCategory category;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _pressed = false;
  Timer? _pulse;

  @override
  void initState() {
    super.initState();
    // Counting is hands-busy; the screen stays awake while reading.
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _pulse?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  void _count(List<Thikr> items) {
    ref
        .read(readerControllerProvider.notifier)
        .countOne(items, advanceDelay: Motion.of(context, Motion.autoAdvance));
    if (Motion.reduced(context)) return;
    setState(() => _pressed = true);
    _pulse?.cancel();
    _pulse = Timer(Motion.tapPulse, () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  void _close() {
    ref.read(readerControllerProvider.notifier).close();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final library = ref.watch(athkarLibraryProvider).value;
    final session = ref.watch(readerControllerProvider).session;

    if (library == null || session == null) {
      return Scaffold(backgroundColor: t.bg, body: const SizedBox.shrink());
    }
    final items = session.itemsFrom(library);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) ref.read(readerControllerProvider.notifier).close();
      },
      child: Scaffold(
        backgroundColor: t.bg,
        bottomNavigationBar: ref.watch(readerControllerProvider).saveFailed
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        L.of(context).readerSaveError,
                        style: MishkatType.caption(t),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: ref
                            .read(readerControllerProvider.notifier)
                            .retrySave,
                        child: Text(L.of(context).retry),
                      ),
                    ],
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: session.finished
              ? _DoneView(
                  category: session.category,
                  items: items,
                  onHome: _close,
                )
              : GestureDetector(
                  // The whole page is the counter.
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _count(items),
                  child: Column(
                    children: [
                      _ReaderHeader(
                        items: items,
                        index: session.index,
                        category: session.category,
                        onClose: _close,
                      ),
                      _Progress(items: items, index: session.index),
                      Expanded(
                        child: _Page(
                          thikr: items[session.index],
                          library: library,
                        ),
                      ),
                      _Counter(
                        items: items,
                        index: session.index,
                        pressed: _pressed,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _ReaderHeader extends ConsumerWidget {
  const _ReaderHeader({
    required this.items,
    required this.index,
    required this.category,
    required this.onClose,
  });

  final List<Thikr> items;
  final int index;
  final ThikrCategory category;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final current = items[index];
    final saved = ref.watch(favoriteIdsProvider).contains(current.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Row(
        children: [
          IconCircleButton(
            icon: MIcon.close,
            iconSize: 18,
            semanticLabel: l.close,
            onPressed: onClose,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  categoryLabel(l, category),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MishkatType.headline(t).copyWith(fontSize: 15),
                ),
                Text(
                  l.positionOf(
                    localizeDigits(index + 1, lang),
                    localizeDigits(items.length, lang),
                  ),
                  style: MishkatType.caption(t).copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          IconCircleButton(
            icon: MIcon.share,
            iconSize: 18,
            semanticLabel: l.share,
            onPressed: () => showShareSheet(context, current),
          ),
          IconCircleButton(
            icon: saved ? MIcon.heartFilled : MIcon.heart,
            iconSize: 18,
            color: saved ? t.accentText : t.ink,
            semanticLabel: saved ? l.favoriteRemove : l.favoriteAdd,
            onPressed: () => ref
                .read(readerControllerProvider.notifier)
                .toggleFavorite(current.id),
          ),
          Builder(
            builder: (button) => IconCircleButton(
              icon: MIcon.more,
              iconSize: 18,
              semanticLabel: l.more,
              onPressed: () => _showMenu(button, ref, current, lang),
            ),
          ),
        ],
      ),
    );
  }

  /// Board AF 7: a raised menu under the button, no scrim. Report and copy,
  /// and starting the session again, which used to sit in the header.
  Future<void> _showMenu(
    BuildContext button,
    WidgetRef ref,
    Thikr current,
    String lang,
  ) async {
    final t = button.tokens;
    final l = L.of(button);
    final box = button.findRenderObject()! as RenderBox;
    final overlay = Overlay.of(button).context.findRenderObject()! as RenderBox;
    final origin = box.localToGlobal(
      Offset(0, box.size.height),
      ancestor: overlay,
    );
    PopupMenuItem<_ReaderAction> item(
      _ReaderAction value,
      MIcon icon,
      String label,
    ) => PopupMenuItem(
      value: value,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          MishkatIcon(icon, color: t.ink, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: MishkatType.body(t).copyWith(fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
    final action = await showMenu<_ReaderAction>(
      context: button,
      color: t.surfaceRaised,
      elevation: 12,
      shadowColor: MishkatTokens.dark.bg.withValues(alpha: 0.4),
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 262),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      menuPadding: const EdgeInsets.all(6),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(origin.dx, origin.dy + 4, box.size.width, 0),
        Offset.zero & overlay.size,
      ),
      items: [
        if (ref.read(cloudAvailableProvider))
          item(_ReaderAction.report, MIcon.flag, l.reportThikr),
        item(_ReaderAction.copy, MIcon.copy, l.copyText),
        item(_ReaderAction.restart, MIcon.reset, l.readerStartAgain),
      ],
    );
    if (action == null || !button.mounted) return;
    switch (action) {
      case _ReaderAction.report:
        await showFeedbackSheet(
          button,
          thikr: current,
          position: l.positionOf(
            localizeDigits(index + 1, lang),
            localizeDigits(items.length, lang),
          ),
        );
      case _ReaderAction.copy:
        await Clipboard.setData(ClipboardData(text: current.text));
        if (button.mounted) showToast(button, l.copied);
      case _ReaderAction.restart:
        await _restart(button, ref);
    }
  }

  Future<void> _restart(BuildContext context, WidgetRef ref) async {
    final l = L.of(context);
    final restart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.readerRestartQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.close),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.readerStartAgain),
          ),
        ],
      ),
    );
    if (restart != true || !context.mounted) return;
    final controller = ref.read(readerControllerProvider.notifier);
    final session = ref.read(readerControllerProvider).session!;
    final library = ref.read(athkarLibraryProvider).value!;
    try {
      await controller.open(
        category,
        session.isWholeRoutine ? library[category] : items,
        subset: !session.isWholeRoutine,
        restart: true,
      );
    } catch (error, stack) {
      ref.read(diagnosticsProvider).recordError(error, stack);
    }
  }
}

enum _ReaderAction { report, copy, restart }

/// One 3px segment per thikr: done, current, still to come.
class _Progress extends StatelessWidget {
  const _Progress({required this.items, required this.index});

  final List<Thikr> items;
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: AnimatedContainer(
                  duration: Motion.of(context, Motion.base),
                  height: 3,
                  decoration: BoxDecoration(
                    color: i < index
                        ? (t.isDark ? t.ink : t.primary)
                        : i == index
                        ? t.glow
                        : t.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The reader page. Text is set at the fixed size the user chose; a thikr
/// longer than the page scrolls inside it, with a fade and a cue, and never
/// shrinks.
class _Page extends ConsumerStatefulWidget {
  const _Page({required this.thikr, required this.library});

  final Thikr thikr;
  final AthkarLibrary library;

  @override
  ConsumerState<_Page> createState() => _PageState();
}

class _PageState extends ConsumerState<_Page> {
  final _scroll = ScrollController();
  bool _moreBelow = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_measure);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(_Page old) {
    super.didUpdateWidget(old);
    if (old.thikr.id != widget.thikr.id && _scroll.hasClients) {
      _scroll.jumpTo(0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _measure() {
    if (!mounted || !_scroll.hasClients) return;
    final p = _scroll.position;
    final more = p.maxScrollExtent - p.pixels > 4;
    if (more != _moreBelow) setState(() => _moreBelow = more);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language.name;
    final thikr = widget.thikr;
    final english = !settings.language.isRtl;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          thikr.text,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: MishkatType.thikr(
            t,
            settings.textSize,
            quranScript: settings.useQuranFont,
          ),
        ),
        if (english && thikr.meaningEn.isNotEmpty) ...[
          const SizedBox(height: 14),
          Divider(height: 1, thickness: 1, color: t.lineSoft),
          const SizedBox(height: 14),
          Text(
            thikr.meaningEn,
            textAlign: TextAlign.center,
            style: MishkatType.bodyMuted(
              t,
            ).copyWith(fontSize: 14, height: 1.75),
          ),
        ],
        SizedBox(height: english ? 12 : 16),
        Text(
          widget.library.referenceLine(thikr, lang),
          textAlign: TextAlign.center,
          style: MishkatType.caption(t),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: ColoredBox(
          color: t.surface,
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (context, box) =>
                    NotificationListener<ScrollMetricsNotification>(
                      onNotification: (_) {
                        _measure();
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _scroll,
                        padding: EdgeInsets.fromLTRB(
                          22,
                          28,
                          22,
                          _moreBelow ? 60 : 28,
                        ),
                        child: ConstrainedBox(
                          // Centred while it fits; scrolls from the top when
                          // it does not.
                          constraints: BoxConstraints(
                            minHeight: (box.maxHeight - 56).clamp(
                              0,
                              double.infinity,
                            ),
                          ),
                          child: Center(child: content),
                        ),
                      ),
                    ),
              ),
              if (_moreBelow)
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.only(bottom: 10),
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        // Solid by the time it reaches the cue, so the cue
                        // never sits on a half-faded line.
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0, 0.6],
                          colors: [t.surface.withValues(alpha: 0), t.surface],
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.scrollToContinue,
                            style: MishkatType.caption(
                              t,
                            ).copyWith(fontSize: 11.5),
                          ),
                          const SizedBox(width: 6),
                          MishkatIcon(
                            MIcon.chevronDown,
                            color: t.inkMuted,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The counter row: previous, the remaining count, next.
///
/// Up to 11 repetitions show as beads; more show "of N"; a single one says
/// "once".
class _Counter extends ConsumerWidget {
  const _Counter({
    required this.items,
    required this.index,
    required this.pressed,
  });

  final List<Thikr> items;
  final int index;
  final bool pressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final state = ref.watch(readerControllerProvider);
    final controller = ref.read(readerControllerProvider.notifier);
    final thikr = items[index];
    final remaining = state.remainingFor(thikr);
    final counted = thikr.count - remaining;
    final captionStyle = MishkatType.caption(t).copyWith(fontSize: 11.5);

    final Widget detail;
    if (thikr.count == 1) {
      detail = Text(l.once, style: captionStyle);
    } else if (thikr.count <= 11) {
      detail = Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < thikr.count; i++)
            AnimatedContainer(
              duration: Motion.of(context, Motion.fast),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < counted ? t.glow : null,
                border: i < counted
                    ? null
                    : Border.all(
                        color: t.isDark ? t.ink : t.primary,
                        width: 1.5,
                      ),
              ),
            ),
        ],
      );
    } else {
      detail = Text(
        l.counterOf(localizeDigits(thikr.count, lang)),
        style: captionStyle,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
      child: Row(
        children: [
          IconCircleButton(
            icon: MIcon.chevronLeft,
            size: 52,
            iconSize: 18,
            semanticLabel: l.prev,
            onPressed: index == 0 ? null : controller.previous,
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              label: l.counterRemaining(
                localizeDigits(remaining, lang),
                localizeDigits(thikr.count, lang),
              ),
              excludeSemantics: true,
              child: AnimatedScale(
                scale: pressed ? 0.97 : 1,
                duration: Motion.of(context, Motion.tapPulse),
                curve: Motion.curve,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizeDigits(remaining, lang),
                      style: MishkatType.counter(t),
                    ),
                    const SizedBox(height: 10),
                    detail,
                  ],
                ),
              ),
            ),
          ),
          IconCircleButton(
            icon: MIcon.chevronRight,
            size: 52,
            iconSize: 18,
            semanticLabel: l.next,
            onPressed: () => controller.advance(items),
          ),
        ],
      ),
    );
  }
}

/// Board 3.4: the session is complete.
class _DoneView extends ConsumerWidget {
  const _DoneView({
    required this.category,
    required this.items,
    required this.onHome,
  });

  final ThikrCategory category;
  final List<Thikr> items;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final streak = ref.watch(progressStatsProvider).currentStreak;
    final next = ref.watch(currentScheduleProvider).entries.firstOrNull;

    final lines = [
      l.streakNow(streak, localizeDigits(streak, lang)),
      if (next != null)
        l.nextReminderLine(
          categoryLabel(l, next.slot.category),
          formatTime(next.at, lang, am: l.am, pm: l.pm),
        ),
    ];

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.glowSoft,
                      shape: BoxShape.circle,
                    ),
                    child: BrandMark(
                      size: 64,
                      showTile: false,
                      arch: t.isDark ? t.ink : t.primary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l.doneRoutine(categoryLabel(l, category)),
                    textAlign: TextAlign.center,
                    style: MishkatType.display(
                      t,
                    ).copyWith(fontSize: 28, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lines.join(' '),
                    textAlign: TextAlign.center,
                    style: MishkatType.bodyMuted(t).copyWith(height: 1.9),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
          child: Column(
            children: [
              PrimaryButton(label: l.backHome, onPressed: onHome),
              const SizedBox(height: 10),
              SecondaryButton(
                label: l.shareAsImage,
                icon: MIcon.share,
                onPressed: () => _pickAndShare(context, items),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// A session has several athkar and a card shows one, so ask which.
  static Future<void> _pickAndShare(BuildContext context, List<Thikr> items) {
    if (items.length == 1) return showShareSheet(context, items.single);
    return showAppSheet<void>(
      context,
      (sheetContext) => _SharePicker(
        items: items,
        onPick: (thikr) {
          Navigator.of(sheetContext).pop();
          showShareSheet(context, thikr);
        },
      ),
    );
  }
}

class _SharePicker extends StatelessWidget {
  const _SharePicker({required this.items, required this.onPick});

  final List<Thikr> items;
  final ValueChanged<Thikr> onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetTitle(l.shareChooseTitle),
        const SizedBox(height: 12),
        for (final thikr in items) ...[
          Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(thikr),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: t.bg,
                  borderRadius: BorderRadius.circular(Radii.lg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        thikr.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: kThikrFont,
                          fontSize: 19,
                          height: 1.8,
                          color: t.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    MishkatIcon(MIcon.share, color: t.inkMuted, size: 18),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
