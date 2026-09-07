@Tags(['tools'])
library;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/theme/palettes.dart';
import 'package:mishkat/core/widgets/app_icons.dart';
import 'package:screenshot/screenshot.dart';

import '../golden/font_loader.dart';

/// Regenerates `assets/branding/splash-mark.png` — the gold mark on
/// transparency, used by flutter_native_splash over the brand colour.
///
///   flutter test test/tools/generate_splash_test.dart
void main() {
  const size = 512.0;

  testWidgets('generate splash mark', (tester) async {
    await loadAppFonts();
    final spec = kPalettes[AppPalette.teal]!;

    final mark = SizedBox(
      width: size,
      height: size,
      child: Center(
        child: StrokeIcon(
          AppIcons.mark,
          color: spec.gold,
          size: size * 0.6,
          strokeWidth: 1.5,
          extraShapes: AppIcons.markShapes,
        ),
      ),
    );

    late final Uint8List bytes;
    await tester.runAsync(() async {
      bytes = await ScreenshotController().captureFromWidget(
        mark,
        pixelRatio: 1,
        targetSize: const Size(size, size),
        delay: const Duration(milliseconds: 100),
      );
    });

    final file = File('assets/branding/splash-mark.png');
    file.writeAsBytesSync(bytes);
    expect(file.lengthSync(), greaterThan(500));
    // ignore: avoid_print
    print('wrote ${file.path} (${file.lengthSync()} bytes)');
  });
}
