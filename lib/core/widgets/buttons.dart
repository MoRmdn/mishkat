import 'package:flutter/material.dart';

import '../theme/mishkat_tokens.dart';
import 'mishkat_icon.dart';

/// The full-width 52px pill for a screen's one main action.
///
/// Primary on light; on dark the design moves the colour to [cta], because a
/// dark primary is a surface and would disappear.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.cta = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final MIcon? icon;

  /// False sizes the pill to its label, as on the error screen.
  final bool expand;

  /// Forces the rose CTA fill — the now module's start button.
  final bool cta;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final useCta = cta || t.isDark;
    final bg = useCta ? t.cta : t.primary;
    final fg = useCta ? t.onCta : t.onPrimary;
    return _Pill(
      label: label,
      onPressed: onPressed,
      background: bg,
      style: TextStyle(
        fontFamily: kUiFont,
        fontSize: 15.5,
        fontWeight: FontWeight.w500,
        color: fg,
      ),
      icon: icon,
      iconColor: fg,
      expand: expand,
    );
  }
}

/// The quieter 52px pill on [MishkatTokens.surface] — "share as image",
/// "browse athkar", "skip".
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.muted = false,
    this.background,
  });

  final String label;
  final VoidCallback? onPressed;
  final MIcon? icon;
  final bool expand;

  /// Muted label, for a skip that should not compete with the main action.
  final bool muted;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = muted ? t.inkMuted : t.ink;
    return _Pill(
      label: label,
      onPressed: onPressed,
      background: background ?? t.surface,
      style: TextStyle(
        fontFamily: kUiFont,
        fontSize: muted ? 14 : 14.5,
        fontWeight: FontWeight.w400,
        color: fg,
      ),
      icon: icon,
      iconColor: fg,
      expand: expand,
    );
  }
}

/// A borderless text action under a primary button ("ليس الآن", "لاحقاً").
class TextAction extends StatelessWidget {
  const TextAction({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Sizes.touchMin),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kUiFont,
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                color: t.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A round icon-only button: 44px in headers, 52px for the reader's
/// previous/next. Always at least 48px to the touch, always labelled.
class IconCircleButton extends StatelessWidget {
  const IconCircleButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.background,
    this.color,
  });

  final MIcon icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? background;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final hit = size < Sizes.touchMin ? Sizes.touchMin : size;
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: hit,
          child: Center(
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: background ?? t.surface,
                shape: BoxShape.circle,
              ),
              child: MishkatIcon(
                icon,
                color: color ?? t.ink,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.style,
    required this.icon,
    required this.iconColor,
    required this.expand,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final TextStyle style;
  final MIcon? icon;
  final Color iconColor;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          MishkatIcon(icon!, color: iconColor, size: 18),
          const SizedBox(width: Space.xs),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: AnimatedOpacity(
          duration: Motion.of(context, Motion.fast),
          opacity: enabled ? 1 : 0.55,
          child: Container(
            constraints: const BoxConstraints(minHeight: Sizes.button),
            padding: const EdgeInsets.symmetric(
              horizontal: Space.xl,
              vertical: Space.xs,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
