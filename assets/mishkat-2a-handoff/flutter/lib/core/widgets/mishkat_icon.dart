// GENERATED — one entry per file in assets/icons/*.svg (24×24, 1.5 stroke, currentColor).
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum MIcon {
  arrowLeft('arrow-left', directional: true),
  arrowRight('arrow-right', directional: true),
  battery('battery', directional: false),
  bell('bell', directional: false),
  calendar('calendar', directional: false),
  check('check', directional: false),
  chevronDown('chevron-down', directional: false),
  chevronLeft('chevron-left', directional: true),
  chevronRight('chevron-right', directional: true),
  chevronUp('chevron-up', directional: false),
  clock('clock', directional: false),
  close('close', directional: false),
  copy('copy', directional: false),
  device('device', directional: false),
  download('download', directional: false),
  edit('edit', directional: false),
  external('external', directional: true),
  heart('heart', directional: false),
  heartFilled('heart-filled', directional: false),
  home('home', directional: false),
  info('info', directional: false),
  language('language', directional: false),
  location('location', directional: false),
  minus('minus', directional: false),
  moon('moon', directional: false),
  plus('plus', directional: false),
  progress('progress', directional: false),
  reset('reset', directional: true),
  routineAfterPrayer('routine-after-prayer', directional: false),
  routineEvening('routine-evening', directional: false),
  routineMisc('routine-misc', directional: false),
  routineMorning('routine-morning', directional: false),
  routineSleep('routine-sleep', directional: false),
  routineTasbih('routine-tasbih', directional: false),
  routineWake('routine-wake', directional: false),
  script('script', directional: false),
  settings('settings', directional: false),
  share('share', directional: false),
  sun('sun', directional: false),
  textSize('text-size', directional: false),
  trash('trash', directional: false),
  warning('warning', directional: false),
  ;

  const MIcon(this.file, {required this.directional});
  final String file;

  /// Directional glyphs mirror under RTL, so write them in LTR terms
  /// (chevronRight = "forward" in English) and let Directionality flip them.
  final bool directional;

  String get asset => 'assets/icons/$file.svg';
}

class MishkatIcon extends StatelessWidget {
  const MishkatIcon(this.icon, {super.key, required this.color, this.size = 22, this.semanticLabel});

  final MIcon icon;
  final Color color;
  final double size;

  /// Required for icon-only buttons; leave null when a visible label is adjacent.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        icon.asset,
        width: size,
        height: size,
        matchTextDirection: icon.directional,
        semanticsLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
}
