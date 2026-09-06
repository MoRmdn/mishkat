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
  static const heart = 'M12 20s-7-4.4-7-9.5A3.9 3.9 0 0112 8a3.9 3.9 0 017 2.5c0 5.1-7 9.5-7 9.5z';
  static const chart = 'M4 19h16M7 19v-6M12 19V6M17 19v-9';
  static const gear = 'M12 3v2.2M12 18.8V21M3 12h2.2M18.8 12H21M5.6 5.6l1.6 1.6'
      'M16.8 16.8l1.6 1.6M18.4 5.6l-1.6 1.6M7.2 16.8l-1.6 1.6';
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
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" '
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
