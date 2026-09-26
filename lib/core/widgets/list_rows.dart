import 'package:flutter/material.dart';

import '../format/numerals.dart';
import '../theme/mishkat_tokens.dart';
import 'mishkat_icon.dart';

/// A 54px row in a [GroupCard]: optional glyph, label, then an unread dot, a
/// count, and a chevron (or the external-link glyph for a web page).
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.unread = false,
    this.count,
    this.external = false,
    this.semanticsSuffix,
  });

  final String label;
  final String? subtitle;
  final MIcon? icon;
  final VoidCallback onTap;

  /// The glow dot: an unread reply.
  final bool unread;

  /// The owner's unread inbox count. Hidden when null or zero.
  final int? count;

  /// Opens a web page rather than a screen.
  final bool external;

  /// Read after the label by screen readers ("new reply", "3 unread").
  final String? semanticsSuffix;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final lang = Localizations.localeOf(context).languageCode;
    return Semantics(
      button: true,
      link: external,
      label: semanticsSuffix == null ? label : '$label، $semanticsSuffix',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 54),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                if (icon != null) ...[
                  MishkatIcon(icon!, color: t.ink, size: 18),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: MishkatType.body(
                          t,
                        ).copyWith(fontSize: 14, height: 1.5),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: MishkatType.caption(
                            t,
                          ).copyWith(fontSize: 11.5),
                        ),
                    ],
                  ),
                ),
                if (unread) ...[const SizedBox(width: 12), const UnreadDot()],
                if (count != null && count! > 0) ...[
                  const SizedBox(width: 12),
                  CountBadge(localizeDigits(count!, lang)),
                ],
                const SizedBox(width: 12),
                MishkatIcon(
                  external ? MIcon.external : MIcon.chevronRight,
                  color: t.inkMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 9px glow dot for an unread reply. With [ring], the 11px dot with a
/// 2px surface ring that sits on Home's settings button.
class UnreadDot extends StatelessWidget {
  const UnreadDot({super.key, this.ring = false});

  final bool ring;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final size = ring ? 11.0 : 9.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: t.glow,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: t.surface, width: 2) : null,
      ),
    );
  }
}

/// The owner's inbox count: 24px pill, primary on light, cta on dark.
class CountBadge extends StatelessWidget {
  const CountBadge(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.isDark ? t.cta : t.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: kUiFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: t.isDark ? t.onCta : t.onPrimary,
        ),
      ),
    );
  }
}

/// A small pill: a feedback status, "Waiting to send".
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.height = 24,
  });

  final String label;
  final Color background, foreground;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(height / 2),
    ),
    child: Text(
      label,
      maxLines: 1,
      style: TextStyle(
        fontFamily: kUiFont,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: foreground,
      ),
    ),
  );
}

/// A one-line confirmation at the bottom of the screen: "تم تسجيل الدخول".
void showToast(BuildContext context, String message) {
  final t = context.tokens;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.ink,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: kUiFont,
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: t.bg,
          ),
        ),
      ),
    );
}
