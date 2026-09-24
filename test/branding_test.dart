@Tags(['golden'])
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mishkat/core/theme/brand_colors.dart';
import 'package:mishkat/core/theme/mishkat_tokens.dart';
import 'package:mishkat/features/share/share_card.dart';

import 'golden/font_loader.dart';

/// Guards the branding outputs committed to the repo — native files that no
/// Dart code reads, where a bad regeneration would otherwise reach a store
/// submission unnoticed.
void main() {
  const res = 'android/app/src/main/res';

  String hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  /// `name → #RRGGBB` from colors.xml, following `@color/` aliases.
  Map<String, String> androidColors() {
    final xml = File('$res/values/colors.xml').readAsStringSync();
    final raw = {
      for (final m in RegExp(
        r'<color name="(\w+)">([^<]+)</color>',
      ).allMatches(xml))
        m.group(1)!: m.group(2)!.trim(),
    };
    String resolve(String v) =>
        v.startsWith('@color/') ? resolve(raw[v.substring(7)]!) : v;
    return {for (final e in raw.entries) e.key: resolve(e.value).toUpperCase()};
  }

  group('brand colours are token values', () {
    test('BrandColors are defined by tokens', () {
      expect(BrandColors.primary, MishkatTokens.light.primary);
      expect(BrandColors.launchLight, MishkatTokens.light.bg);
      expect(BrandColors.launchDark, MishkatTokens.dark.bg);
      expect(BrandColors.lamp, MishkatTokens.light.glow);
      expect(BrandColors.notificationAccent, MishkatTokens.light.primary);
    });

    test('Android colors.xml matches the tokens', () {
      final c = androidColors();
      expect(c['brand_primary'], hex(BrandColors.primary));
      expect(c['brand_bg'], hex(BrandColors.launchLight));
      expect(c['brand_glow'], hex(BrandColors.lamp));
      expect(c['ic_launcher_background'], hex(BrandColors.primary));
      expect(c['notification_accent'], hex(BrandColors.primary));
    });

    test('launch screen colours match the tokens', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final splash = pubspec.substring(
        pubspec.indexOf('flutter_native_splash:'),
      );
      final light = hex(BrandColors.launchLight);
      final dark = hex(BrandColors.launchDark);
      expect(RegExp('color: "$light"').allMatches(splash).length, 2);
      expect(RegExp('color_dark: "$dark"').allMatches(splash).length, 2);

      String v31(String dir) => RegExp(
        r'windowSplashScreenBackground">(#\w+)<',
      ).firstMatch(File('$res/$dir/styles.xml').readAsStringSync())!.group(1)!;
      expect(v31('values-v31'), light);
      expect(v31('values-night-v31'), dark);
    });
  });

  group('Android launcher icon', () {
    test('the adaptive icon is vector-only, with a themed layer', () {
      final xml = File(
        '$res/mipmap-anydpi-v26/ic_launcher.xml',
      ).readAsStringSync();
      expect(xml, contains('@drawable/ic_launcher_foreground'));
      expect(xml, contains('<monochrome'));
      expect(
        File('$res/drawable/ic_launcher_foreground.xml').existsSync(),
        isTrue,
      );
      expect(
        File('$res/drawable/ic_launcher_monochrome.xml').existsSync(),
        isTrue,
      );
    });

    test('no density PNG shadows the vector foreground', () {
      final shadows = Directory(res)
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) => RegExp(
              r'drawable-[a-z]*dpi[/\\]ic_launcher_foreground\.png$',
            ).hasMatch(f.path),
          );
      expect(shadows, isEmpty);
    });

    test('the artwork stays inside the 66dp safe circle', () {
      // Group transform from ic_launcher_foreground.xml: scale 0.7, then
      // translate (12, 8.5), in a 108dp viewport centred on (54, 54).
      Offset map(double x, double y) => Offset(12 + 0.7 * x, 8.5 + 0.7 * y);
      final extremes = [
        map(32, 100), map(88, 100), // the arch's feet
        map(60, 30), // the crown of the arch
        for (var a = 0; a <= 180; a += 5) // the outer arch curve
          map(
            60 - 28 * math.cos(a * math.pi / 180),
            58 - 28 * math.sin(a * math.pi / 180),
          ),
      ];
      for (final p in extremes) {
        expect((p - const Offset(54, 54)).distance, lessThanOrEqualTo(33));
      }
    });

    testWidgets('renders cleanly under a round launcher mask', (tester) async {
      // The vector's own path data, drawn through flutter_svg, so this image
      // is the XML Android will draw — not a separate export.
      final xml = File(
        '$res/drawable/ic_launcher_foreground.xml',
      ).readAsStringSync();
      final colours = androidColors();
      final paths =
          RegExp(
            r'fillColor="@color/(\w+)"(?: android:fillType="(\w+)")? android:pathData="([^"]+)"',
          ).allMatches(xml).map((m) {
            final rule = m.group(2) == 'evenOdd' ? ' fill-rule="evenodd"' : '';
            return '<path d="${m.group(3)}" fill="${colours[m.group(1)]}"$rule/>';
          }).join();
      expect(paths, isNotEmpty);
      final svg =
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">'
          '<rect width="108" height="108" fill="${colours['ic_launcher_background']}"/>'
          '<g transform="translate(12 8.5) scale(0.7)">$paths</g></svg>';

      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            child: SizedBox.square(
              dimension: 216,
              child: ClipOval(child: SvgPicture.string(svg)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(RepaintBoundary).first,
        matchesGoldenFile('golden/images/adaptive_icon_round.png'),
      );
    });
  });

  group('notification icon', () {
    test('is the one-colour vector, kept through resource shrinking', () {
      final icon = File('$res/drawable/ic_stat_mishkat.xml').readAsStringSync();
      final fills = RegExp(
        r'fillColor="([^"]+)"',
      ).allMatches(icon).map((m) => m.group(1)).toSet();
      expect(fills, {'#FFFFFFFF'}, reason: 'Android tints it; one colour only');

      final keep = File('$res/raw/keep.xml').readAsStringSync();
      expect(keep, contains('@drawable/ic_stat_mishkat'));
    });

    test('the service uses it and no stale PNG set remains', () {
      final service = File(
        'lib/services/notification_service.dart',
      ).readAsStringSync();
      expect(service, contains("'@drawable/ic_stat_mishkat'"));
      expect(service, contains('BrandColors.notificationAccent'));
      final stale = Directory(res)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.contains('ic_notification'));
      expect(stale, isEmpty);
    });
  });

  group('iOS app icon', () {
    test('the store icon is 1024 square and fully opaque', () {
      // App Store submission rejects an icon with an alpha channel.
      final bytes = File(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
      ).readAsBytesSync();
      final icon = img.decodePng(bytes)!;
      expect((icon.width, icon.height), (1024, 1024));
      final rgba = icon.convert(numChannels: 4);
      for (var y = 0; y < rgba.height; y += 16) {
        for (var x = 0; x < rgba.width; x += 16) {
          expect(rgba.getPixel(x, y).a, 255, reason: 'transparent at $x,$y');
        }
      }
    });

    test('dark and tinted variants are registered', () {
      final contents = File(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
      ).readAsStringSync();
      expect(contents, contains('"value":"dark"'));
      expect(contents, contains('"value":"tinted"'));
    });
  });

  group('share card', () {
    setUpAll(loadAppFonts);

    test('a short thikr is square, a long one grows instead of shrinking', () {
      expect(shareCardHeight('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'), 360);
      final long = List.filled(
        12,
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ',
      ).join('، ');
      expect(shareCardHeight(long), greaterThan(360));
    });
  });
}
