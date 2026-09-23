import 'package:flutter/material.dart';

/// The Mishkat mark — a niche (مشكاة) with a lit flame.
///
/// The designer's own artwork, bundled rather than traced: the mark is a PNG
/// in the design project, and redrawing it would reintroduce exactly the
/// approximation this replaced.
///
/// Every surface it appears on in the app is dark, so the white variant is the
/// only one needed and it needs no per-theme tinting.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/branding/splash-mark.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Mishkat',
    );
  }
}
