import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Line icons transcribed from the design prototype's inline SVG.
///
/// Kept as raw path data rather than a Material icon lookalike so the stroke
/// weight and geometry match the board exactly.
class AppIcons {
  AppIcons._();

  static const home = 'M4 20V11l8-6 8 6v9H4z';
  static const bell = 'M18 15V10a6 6 0 10-12 0v5l-1.5 3h15L18 15zM10 21h4';
  static const heart =
      'M12 20s-7-4.4-7-9.5A3.9 3.9 0 0112 8a3.9 3.9 0 017 2.5c0 5.1-7 9.5-7 9.5z';
  static const chart = 'M4 19h16M7 19v-6M12 19V6M17 19v-9';
  static const gear =
      'M12 3v2.2M12 18.8V21M3 12h2.2M18.8 12H21M5.6 5.6l1.6 1.6'
      'M16.8 16.8l1.6 1.6M18.4 5.6l-1.6 1.6M7.2 16.8l-1.6 1.6';

  // Category glyphs: a rising sun, a setting sun, a crescent, an alarm, a
  // mosque silhouette, and an ellipsis.
  static const morning =
      'M12 4v2M5.6 6.6l1.4 1.4M17 8l1.4-1.4M3 17h18M6 13a6 6 0 0112 0';
  static const evening =
      'M12 18v2M5.6 15.4L7 14M17 14l1.4 1.4M3 11h18M6 8a6 6 0 0112 0';
  static const sleep = 'M20 14.5A8 8 0 019.5 4a8 8 0 1010.5 10.5z';
  static const wake =
      'M3 18h18M7 14a5 5 0 0110 0M12 3v3M4.8 8.8l1.6 1.6M17.6 10.4l1.6-1.6';
  static const afterPrayer = 'M4 20V11l8-6 8 6v9M4 20h16M10 20v-5h4v5';
  static const misc = '';
  static const miscShapes =
      '<circle cx="6" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="18" cy="12" r="2"/>';

  static const warning = 'M12 8v5M12 16.5v.5';
  static const warningShapes = '<circle cx="12" cy="12" r="9"/>';

  static const chevronStart = 'M14 6l-6 6 6 6';
  static const chevronUp = 'M6 15l6-6 6 6';
  static const chevronDown = 'M6 9l6 6 6-6';

  static const check = 'M20 6L9 17l-5-5';
  static const close = 'M6 6l12 12M18 6L6 18';
}

/// Renders a stroked 24×24 icon path at [size] in [color].
class StrokeIcon extends StatelessWidget {
  const StrokeIcon(
    this.path, {
    super.key,
    required this.color,
    this.size = 21,
    this.strokeWidth = 1.7,
    this.extraShapes = '',
  });

  final String path;
  final Color color;
  final double size;
  final double strokeWidth;

  /// Additional raw SVG elements drawn with the same stroke (e.g. the gear's
  /// centre circle).
  final String extraShapes;

  @override
  Widget build(BuildContext context) {
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" '
        'viewBox="0 0 24 24" fill="none" stroke="#000000" stroke-width="$strokeWidth" '
        'stroke-linecap="round" stroke-linejoin="round">'
        '$extraShapes<path d="$path"/></svg>';

    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

class GearIcon extends StatelessWidget {
  const GearIcon({super.key, required this.color, this.size = 18});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => StrokeIcon(
    AppIcons.gear,
    color: color,
    size: size,
    extraShapes: '<circle cx="12" cy="12" r="3.2"/>',
  );
}

/// A filled-or-outlined heart, used for favouriting in the reader.
class HeartIcon extends StatelessWidget {
  const HeartIcon({
    super.key,
    required this.color,
    required this.filled,
    this.size = 18,
  });

  final Color color;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    final svg =
        '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" '
        'viewBox="0 0 24 24" fill="${filled ? '#000000' : 'none'}" stroke="#000000" '
        'stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">'
        '<path d="${AppIcons.heart}"/></svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
