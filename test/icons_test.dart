import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';

void main() {
  test('every MIcon has its SVG in assets/icons', () {
    final missing = [
      for (final icon in MIcon.values)
        if (!File(icon.asset).existsSync()) icon.asset,
    ];
    expect(missing, isEmpty);
  });

  test('every SVG in assets/icons is drawn by an MIcon', () {
    final registered = {for (final icon in MIcon.values) icon.asset};
    final orphans = [
      for (final file in Directory('assets/icons').listSync())
        if (file.path.endsWith('.svg') && !registered.contains(file.path))
          file.path,
    ];
    expect(orphans, isEmpty);
  });
}
