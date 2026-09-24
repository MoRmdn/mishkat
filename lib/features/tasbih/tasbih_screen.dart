import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../settings/settings_controller.dart';

/// Round sizes offered under the counter. Null is "no limit".
const List<int?> kTasbihTargets = [100, 33, null];

/// A light buzz every this many counts, as the hint promises.
const int _buzzEvery = 33;

@immutable
class TasbihState {
  const TasbihState({this.count = 0, this.target = 100});

  /// Total counted since the counter was last reset.
  final int count;

  /// Counts per round, or null for an open count.
  final int? target;

  /// The count shown on the dial: within the current round.
  int get display => target == null ? count : count % target!;

  /// 1-based round number.
  int get round => target == null ? 1 : count ~/ target! + 1;
}

class TasbihController extends Notifier<TasbihState> {
  @override
  TasbihState build() => const TasbihState();

  void count() {
    final next = state.count + 1;
    state = TasbihState(count: next, target: state.target);
    final target = state.target;
    if (target != null && next % target == 0) {
      HapticFeedback.mediumImpact();
    } else if (next % _buzzEvery == 0) {
      HapticFeedback.lightImpact();
    }
  }

  void setTarget(int? target) =>
      state = TasbihState(count: state.count, target: target);

  void reset() => state = TasbihState(target: state.target);
}

/// In memory: the tasbih is a free counter, not a tracked routine.
final tasbihProvider = NotifierProvider<TasbihController, TasbihState>(
  TasbihController.new,
);

Future<void> openTasbih(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => const TasbihScreen(),
  ),
);

/// Board 2.4: the free counter. The whole screen counts.
class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  bool _pressed = false;
  Timer? _pulse;

  @override
  void dispose() {
    _pulse?.cancel();
    super.dispose();
  }

  void _count() {
    ref.read(tasbihProvider.notifier).count();
    if (Motion.reduced(context)) return;
    setState(() => _pressed = true);
    _pulse?.cancel();
    _pulse = Timer(Motion.tapPulse, () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final state = ref.watch(tasbihProvider);
    final library = ref.watch(athkarLibraryProvider).value;
    final dhikr = library?[ThikrCategory.tasbih].firstOrNull;

    String digits(Object v) => localizeDigits(v, lang);
    final caption = state.target == null
        ? l.tasbihFree
        : l.tasbihRound(digits(state.round), digits(state.target!));

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _count,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: Row(
                  children: [
                    IconCircleButton(
                      icon: MIcon.close,
                      iconSize: 18,
                      semanticLabel: l.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        l.catTasbih,
                        textAlign: TextAlign.center,
                        style: MishkatType.headline(t).copyWith(fontSize: 15),
                      ),
                    ),
                    IconCircleButton(
                      icon: MIcon.reset,
                      iconSize: 18,
                      semanticLabel: l.reset,
                      onPressed: ref.read(tasbihProvider.notifier).reset,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dhikr != null)
                          Text(
                            dhikr.text,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: kThikrFont,
                              fontSize: 32,
                              height: 2,
                            ).copyWith(color: t.ink),
                          ),
                        const SizedBox(height: 26),
                        Semantics(
                          liveRegion: true,
                          label: '${digits(state.display)} · $caption',
                          excludeSemantics: true,
                          child: AnimatedScale(
                            scale: _pressed ? 0.97 : 1,
                            duration: Motion.of(context, Motion.tapPulse),
                            curve: Motion.curve,
                            child: Container(
                              width: 230,
                              height: 230,
                              decoration: BoxDecoration(
                                color: t.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: t.line),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FittedBox(
                                    child: Text(
                                      digits(state.display),
                                      style: MishkatType.counter(
                                        t,
                                      ).copyWith(fontSize: 76),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    caption,
                                    style: MishkatType.caption(
                                      t,
                                    ).copyWith(fontSize: 12.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final target in kTasbihTargets)
                              _TargetChip(
                                label: target == null
                                    ? l.tasbihNoLimit
                                    : digits(target),
                                selected: state.target == target,
                                onTap: () => ref
                                    .read(tasbihProvider.notifier)
                                    .setTarget(target),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                child: Text(
                  l.tasbihHint,
                  textAlign: TextAlign.center,
                  style: MishkatType.caption(t),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fill = selected ? (t.isDark ? t.cta : t.primary) : t.surface;
    final ink = selected ? (t.isDark ? t.onCta : t.onPrimary) : t.ink;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: Sizes.touchMin,
          child: Center(
            // Shrink-wrap: inside a Wrap a plain Center takes the full row.
            widthFactor: 1,
            child: AnimatedContainer(
              duration: Motion.of(context, Motion.fast),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                label,
                style: TextStyle(fontFamily: kUiFont, fontSize: 13, color: ink),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
