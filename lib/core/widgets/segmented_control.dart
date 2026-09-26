import 'package:flutter/material.dart';

import '../theme/mishkat_tokens.dart';
import 'mishkat_icon.dart';

class SegmentedOption<T> {
  const SegmentedOption(this.value, this.label, {this.icon, this.flex = 1});

  final T value;
  final String label;
  final MIcon? icon;

  /// Relative width, for a label longer than its neighbours.
  final int flex;
}

/// The 2a segmented control: a pill track with the selected segment raised
/// onto [MishkatTokens.surfaceRaised]. 40px segments; no shadow — the system
/// is flat.
///
/// The track is [MishkatTokens.lineSoft] on a page and [MishkatTokens.bg]
/// inside a sheet, so it always reads as a recess in whatever it sits on.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.onSurface = false,
    this.fontSize = 13.5,
  });

  final List<SegmentedOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  /// True inside a sheet or card, where the page colour is the recess.
  final bool onSurface;

  /// 12 where three long labels share the track (the feedback types).
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      // No vertical padding here: each segment carries its own 4px, so the
      // whole 48px height of the track is tappable.
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: onSurface ? t.bg : t.lineSoft,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              flex: o.flex,
              child: _Segment(
                option: o,
                fontSize: fontSize,
                selected: o.value == value,
                onTap: () => onChanged(o.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.fontSize,
  });

  final SegmentedOption<T> option;
  final double fontSize;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = selected ? t.ink : t.inkMuted;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: AnimatedContainer(
            duration: Motion.of(context, Motion.base),
            curve: Motion.curve,
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? t.surfaceRaised
                  : t.surfaceRaised.withValues(alpha: 0),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  MishkatIcon(option.icon!, color: fg, size: 16),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    option.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: fontSize,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 46×28 switch. On is primary (the rose CTA in dark, where primary is a
/// surface); off is [MishkatTokens.trackOff]. The knob travels toward the
/// end edge, so it follows text direction.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final VoidCallback? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final duration = Motion.of(context, Motion.base);
    final on = t.isDark ? t.cta : t.primary;
    final knob = t.isDark ? t.ink : t.surfaceRaised;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      enabled: onChanged != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged,
        // A 48px target around the 28px track.
        child: SizedBox(
          width: 52,
          height: Sizes.touchMin,
          child: Center(
            child: AnimatedContainer(
              duration: duration,
              curve: Motion.curve,
              width: 46,
              height: 28,
              decoration: BoxDecoration(
                color: value ? on : t.trackOff,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  AnimatedPositionedDirectional(
                    duration: duration,
                    curve: Motion.curve,
                    top: 3,
                    start: value ? 21 : 3,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: knob,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
