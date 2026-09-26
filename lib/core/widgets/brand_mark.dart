import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/mishkat_tokens.dart';

/// The Mishkat symbol: a rounded wall tile holding an arched niche, with a
/// lamp resting inside.
///
/// Draws the handoff's own SVG master rather than a retrace, and recolours
/// it from tokens so the mark follows appearance and can sit on any surface
/// the design puts it on. Below 32px the small cut is used, where the band
/// closes into a solid doorway that stays legible.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    required this.size,
    this.tile,
    this.arch,
    this.lamp,
    this.showTile = true,
    this.smallCut,
    this.semanticLabel,
  });

  /// The symbol on a tinted panel, as on the welcome hero and the share card.
  factory BrandMark.onPrimary(
    BuildContext context, {
    Key? key,
    required double size,
    bool showTile = true,
  }) {
    final t = context.tokens;
    return BrandMark(
      key: key,
      size: size,
      // A lift of the panel's own colour, so the tile reads without a border.
      tile: Color.alphaBlend(t.onPrimary.withValues(alpha: 0.09), t.primary),
      arch: t.onPrimary,
      lamp: t.cta,
      showTile: showTile,
    );
  }

  final double size;

  /// Overrides for the three parts. Null uses the appearance's own mark:
  /// primary / bg / glow in light, glowSoft / ink / glow in dark.
  final Color? tile;
  final Color? arch;
  final Color? lamp;

  /// False draws the niche and lamp alone, as on the completion halo.
  final bool showTile;

  /// Null picks the cut by [size]. Set it where the logical size understates
  /// the rendered one, as in an image exported at 3×.
  final bool? smallCut;
  final String? semanticLabel;

  static const _full = 'assets/branding/svg/symbol-color.svg';
  static const _small = 'assets/branding/svg/symbol-small-color.svg';

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final mapper = _MarkColors(
      tile: showTile
          ? (tile ?? (t.isDark ? t.glowSoft : t.primary))
          : Colors.transparent,
      arch: arch ?? (showTile ? (t.isDark ? t.ink : t.bg) : t.primary),
      lamp: lamp ?? t.glow,
    );
    return SvgPicture(
      SvgAssetLoader(
        (smallCut ?? size < 32) ? _small : _full,
        colorMapper: mapper,
      ),
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}

/// Swaps the master artwork's three fills — which are exactly the light
/// tokens primary, bg and glow — for the colours this placement needs.
class _MarkColors extends ColorMapper {
  const _MarkColors({
    required this.tile,
    required this.arch,
    required this.lamp,
  });

  final Color tile;
  final Color arch;
  final Color lamp;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    const source = MishkatTokens.light;
    if (color == source.primary) return tile;
    if (color == source.bg) return arch;
    if (color == source.glow) return lamp;
    return color;
  }

  @override
  bool operator ==(Object other) =>
      other is _MarkColors &&
      other.tile == tile &&
      other.arch == arch &&
      other.lamp == lamp;

  @override
  int get hashCode => Object.hash(tile, arch, lamp);
}
