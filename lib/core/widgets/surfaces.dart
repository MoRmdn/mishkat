import 'package:flutter/material.dart';

import '../theme/mishkat_tokens.dart';
import 'mishkat_icon.dart';

/// A tab's page title, 24/500, as on Reminders, Saved and Progress.
class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: MishkatType.display(context.tokens).copyWith(fontSize: 24),
    ),
  );
}

/// A rounded [MishkatTokens.surface] group whose rows are divided by
/// [MishkatTokens.lineSoft] hairlines — the library list, the reminder slots,
/// the prayer settings.
class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.children, this.color});

  final List<Widget> children;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Radii.lg),
      child: ColoredBox(
        color: color ?? t.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: t.lineSoft),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// The warning or error banner: 18px radius, glyph, title and/or body, one
/// action. Exact-alarm and notifications-off states use the warn ramp.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.inlineAction = false,
  });

  final String? title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// True draws the action as an underlined word after the body (4.1);
  /// false as a pill button under it (2.3).
  final bool inlineAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final bodyStyle = TextStyle(
      fontFamily: kUiFont,
      fontSize: 12.5,
      fontWeight: title == null ? FontWeight.w400 : FontWeight.w300,
      height: 1.7,
      color: t.warnInk,
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: title == null ? 14 : 16,
        vertical: title == null ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: t.warnBg,
        border: Border.all(color: t.warnLine),
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: MishkatIcon(
              MIcon.warning,
              color: t.warnAction,
              size: title == null ? 18 : 20,
            ),
          ),
          SizedBox(width: title == null ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: t.warnInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (inlineAction && actionLabel != null)
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onAction,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '$body '),
                            TextSpan(
                              text: actionLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                        style: bodyStyle,
                      ),
                    ),
                  )
                else
                  Text(body, style: bodyStyle),
                if (!inlineAction && actionLabel != null) ...[
                  const SizedBox(height: 10),
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onAction,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: t.warnAction,
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              actionLabel!,
                              style: TextStyle(
                                fontFamily: kUiFont,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: t.onWarnAction,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A 38px pill showing a time. Filled on the page colour when the slot is
/// on, outlined and faint when it is off.
class TimeChip extends StatelessWidget {
  const TimeChip({
    super.key,
    required this.label,
    this.enabled = true,
    this.onTap,
    this.semanticLabel,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final chip = Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? t.bg : null,
        border: enabled ? null : Border.all(color: t.line),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        style: TextStyle(
          fontFamily: kUiFont,
          fontSize: 14,
          fontWeight: enabled ? FontWeight.w500 : FontWeight.w400,
          color: enabled ? t.ink : t.inkFaint,
        ),
      ),
    );
    if (onTap == null) return chip;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: Sizes.touchMin,
          child: Center(child: chip),
        ),
      ),
    );
  }
}

/// The small round icon chip on [MishkatTokens.glowSoft] leading a library
/// row.
class IconChip extends StatelessWidget {
  const IconChip(this.icon, {super.key, this.size = 34, this.iconSize = 16});

  final MIcon icon;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.glowSoft, shape: BoxShape.circle),
      child: MishkatIcon(
        icon,
        color: t.isDark ? t.accentText : t.primary,
        size: iconSize,
      ),
    );
  }
}

/// The soft round halo behind an empty-state or error glyph.
class IconHalo extends StatelessWidget {
  const IconHalo({
    super.key,
    this.icon,
    this.child,
    this.size = 88,
    this.iconSize = 28,
    this.color,
  });

  final MIcon? icon;
  final Widget? child;
  final double size;
  final double iconSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.glowSoft, shape: BoxShape.circle),
      child:
          child ??
          MishkatIcon(
            icon!,
            color: color ?? (t.isDark ? t.accentText : t.primary),
            size: iconSize,
          ),
    );
  }
}

/// The rounded-square tile behind an onboarding glyph.
class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.size = 72});

  final MIcon icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.glowSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: MishkatIcon(
        icon,
        color: t.isDark ? t.accentText : t.primary,
        size: 32,
      ),
    );
  }
}
