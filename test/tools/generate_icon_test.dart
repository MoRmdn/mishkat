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

/// Regenerates `assets/branding/app-icon.png`.
///
/// Not a test — a generator, run on demand:
///   flutter test test/tools/generate_icon_test.dart
///
/// The design project's own 1024px export cannot be fetched through the
/// DesignSync tooling (it exceeds the 256 KiB per-file limit and comes back
/// truncated), so the icon is rebuilt here from the same palette and mark path
/// the app already uses. Replace this with the designer's export before
/// release if the two ever diverge.
void main() {
  const size = 1024.0;

  testWidgets('generate app icon', (tester) async {
    await loadAppFonts();
    final spec = kPalettes[AppPalette.teal]!;

    final icon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [spec.accentInk, spec.reader.bg],
        ),
      ),
      child: Center(
        child: StrokeIcon(
          AppIcons.mark,
          color: spec.gold,
          size: size * 0.54,
          strokeWidth: 1.5,
          extraShapes: AppIcons.markShapes,
        ),
      ),
    );

    late final Uint8List bytes;
    await tester.runAsync(() async {
      bytes = await ScreenshotController().captureFromWidget(
        icon,
        pixelRatio: 1,
        targetSize: const Size(size, size),
        delay: const Duration(milliseconds: 100),
      );
    });

    final file = File('assets/branding/app-icon.png');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);

    expect(file.lengthSync(), greaterThan(1000));
    // ignore: avoid_print
    print('wrote ${file.path} (${file.lengthSync()} bytes)');
  });
}
