import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/theme/app_theme.dart';
import 'package:mishkat/core/theme/palettes.dart';

void main() {
  group('AppTokens', () {
    test('every palette resolves in both appearances', () {
      for (final p in AppPalette.values) {
        for (final b in Brightness.values) {
          expect(() => AppTokens.of(p, b), returnsNormally, reason: '$p/$b');
        }
      }
    });

    test('teal light matches the design board values', () {
      final t = AppTokens.of(AppPalette.teal, Brightness.light);
      expect(t.bg, const Color(0xFFF3F5F3));
      expect(t.accent, const Color(0xFF1C6B58));
      expect(t.accentInk, const Color(0xFF123A31));
      expect(t.gold, const Color(0xFFCBA75C));
      expect(t.ink, const Color(0xFF0F1F1A));
      // Light builds put white on the accent.
      expect(t.onAccent, const Color(0xFFFFFFFF));
      expect(t.isDark, isFalse);
    });

    test('dark builds lighten accent and gold for contrast', () {
      final light = AppTokens.of(AppPalette.teal, Brightness.light);
      final dark = AppTokens.of(AppPalette.teal, Brightness.dark);

      expect(dark.accent, const Color(0xFF3D9A82));
      expect(dark.gold, const Color(0xFFDBBC74));
      expect(dark.accent, isNot(light.accent));

      // On dark, ink-on-accent flips to the palette's onGold rather than white.
      expect(dark.onAccent, const Color(0xFF16241E));
      expect(dark.isDark, isTrue);
    });

    test('accentInk is the palette constant in both appearances', () {
      for (final p in AppPalette.values) {
        final spec = kPalettes[p]!;
        expect(AppTokens.of(p, Brightness.light).accentInk, spec.accentInk);
        expect(AppTokens.of(p, Brightness.dark).accentInk, spec.accentInk);
      }
    });

    test('reader ramp stays dark-toned in light builds', () {
      for (final p in AppPalette.values) {
        final t = AppTokens.of(p, Brightness.light);
        // The reader is dark by default for night use, even in a light build.
        expect(
          t.rdBg.computeLuminance(),
          lessThan(0.1),
          reason: '$p reader bg',
        );
        expect(
          t.rdInk.computeLuminance(),
          greaterThan(0.7),
          reason: '$p reader ink',
        );
      }
    });

    test('the three palettes are actually distinct', () {
      final accents = AppPalette.values
          .map((p) => AppTokens.of(p, Brightness.light).accent)
          .toSet();
      expect(accents.length, 3);
    });

    test('warning ramp does not change with palette', () {
      final a = AppTokens.of(AppPalette.teal, Brightness.light);
      final b = AppTokens.of(AppPalette.olive, Brightness.light);
      expect(a.warnBg, b.warnBg);
      expect(a.warnBtn, b.warnBtn);
    });

    test('buildAppTheme exposes tokens through the extension', () {
      final theme = buildAppTheme(AppPalette.indigo, Brightness.dark);
      final t = theme.extension<AppTokens>();
      expect(t, isNotNull);
      expect(t!.accent, const Color(0xFF5A8FB8));
      expect(theme.scaffoldBackgroundColor, t.bg);
      expect(theme.textTheme.bodyMedium?.fontFamily ?? kUiFont, isNotNull);
    });

    test('lerp interpolates between two builds', () {
      final a = AppTokens.of(AppPalette.teal, Brightness.light);
      final b = AppTokens.of(AppPalette.teal, Brightness.dark);
      final mid = a.lerp(b, 0.5);
      expect(mid.bg, Color.lerp(a.bg, b.bg, 0.5));
      // isDark is a discrete flag, so it snaps at the midpoint rather than
      // interpolating: below 0.5 it keeps the source, from 0.5 up it takes
      // the target.
      expect(a.lerp(b, 0.4).isDark, isFalse);
      expect(mid.isDark, isTrue);
      expect(a.lerp(b, 0.9).isDark, isTrue);
    });
  });
}
