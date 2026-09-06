import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The small progress ring in the streak chip — a conic sweep of `accent` over
/// `s3`, with a `surface` disc punched out of the middle.
class StreakRing extends StatelessWidget {
  const StreakRing({super.key, required this.percent, this.size = 24});

  /// 0–100.
  final double percent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fraction = (percent.clamp(0, 100)) / 100;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: -math.pi / 2,
                endAngle: math.pi * 1.5,
                colors: [t.accent, t.accent, t.s3, t.s3],
                stops: [0, fraction, fraction, 1],
              ),
            ),
          ),
          Container(
            width: size * 17 / 24,
            height: size * 17 / 24,
            decoration: BoxDecoration(color: t.surface, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
