@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart';

/// Guards the generated branding assets.
///
/// These are build outputs committed to the repo, so a bad regeneration would
/// otherwise reach a store submission unnoticed.
void main() {
  Image load(String path) {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: '$path is missing');
    final image = decodePng(file.readAsBytesSync());
    expect(image, isNotNull, reason: '$path did not decode');
    return image!.convert(numChannels: 4);
  }

  group('app icon', () {
    test('is 1024 square', () {
      final icon = load('assets/branding/app-icon.png');
      expect(icon.width, 1024);
      expect(icon.height, 1024);
    });

    test('is fully opaque', () {
      // App Store submission rejects an icon containing an alpha channel.
      final icon = load('assets/branding/app-icon.png');
      for (var y = 0; y < icon.height; y += 7) {
        for (var x = 0; x < icon.width; x += 7) {
          expect(
            icon.getPixel(x, y).a,
            255,
            reason: 'transparent pixel at $x,$y',
          );
        }
      }
    });

    test('actually contains the flame, not just a background', () {
      // Cheap guard against a silently empty composite: the centre of the mark
      // must be the flame's gold, well away from the teal ground.
      final icon = load('assets/branding/app-icon.png');
      final p = icon.getPixel(512, 530);
      expect(p.r, greaterThan(180), reason: 'centre is not gold: $p');
      expect(p.g, greaterThan(150), reason: 'centre is not gold: $p');
      expect(p.b, lessThan(210), reason: 'centre is not gold: $p');
    });

    test('matches the designer\'s reference composition', () {
      // The 1024 export could not be fetched, so the icon is recomposed from
      // the authentic marks. The 192 export *is* authentic: downscaling to it
      // is the check that the reconstruction stayed faithful.
      final mine = copyResize(
        load('assets/branding/app-icon.png'),
        width: 192,
        height: 192,
        interpolation: Interpolation.average,
      );
      final reference = load('assets/branding/icon-teal-192.png');

      var total = 0;
      var wrong = 0;
      for (var y = 0; y < 192; y++) {
        for (var x = 0; x < 192; x++) {
          final a = mine.getPixel(x, y);
          final b = reference.getPixel(x, y);
          final delta = [
            (a.r - b.r).abs(),
            (a.g - b.g).abs(),
            (a.b - b.b).abs(),
          ].reduce((m, v) => v > m ? v : m);
          total++;
          if (delta > 24) wrong++;
        }
      }
      expect(
        wrong / total,
        lessThan(0.02),
        reason:
            '${(100 * wrong / total).toStringAsFixed(1)}% of pixels '
            'diverge from the reference',
      );
    });
  });

  group('notification icon', () {
    test('exists at every density', () {
      for (final d in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
        expect(
          File(
            'android/app/src/main/res/drawable-$d/ic_notification.png',
          ).existsSync(),
          isTrue,
          reason: 'missing at $d',
        );
      }
    });

    test('is a white silhouette on transparency', () {
      // Android tints these flat; any colour would be lost and any solid
      // background would render as a featureless blob.
      final icon = load(
        'android/app/src/main/res/drawable-xxxhdpi/ic_notification.png',
      );
      var opaque = 0;
      for (var y = 0; y < icon.height; y++) {
        for (var x = 0; x < icon.width; x++) {
          final p = icon.getPixel(x, y);
          if (p.a > 8) {
            opaque++;
            // Shape lives entirely in the alpha channel; every colour channel
            // is pinned white so downscaling cannot leave grey fringes.
            expect(p.r, 255, reason: 'non-white pixel at $x,$y');
            expect(p.g, 255);
            expect(p.b, 255);
          }
        }
      }
      expect(opaque, greaterThan(0), reason: 'silhouette is empty');
      expect(
        opaque,
        lessThan(icon.width * icon.height),
        reason: 'nothing was punched through — the flame should be a hole',
      );
    });
  });

  test('the in-app mark is transparent outside the glyph', () {
    final mark = load('assets/branding/splash-mark.png');
    expect(mark.getPixel(0, 0).a, 0);
  });
}
