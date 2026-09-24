import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/theme/mishkat_tokens.dart';

/// WCAG 2.x relative luminance of an opaque colour.
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.04045 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// WCAG contrast ratio between two opaque colours, 1–21.
double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  test('the contrast helper matches the WCAG reference values', () {
    expect(
      contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
    expect(
      contrast(const Color(0xFF777777), const Color(0xFFFFFFFF)),
      closeTo(4.48, 0.01),
    );
  });

  for (final t in [MishkatTokens.light, MishkatTokens.dark]) {
    final name = t.isDark ? 'dark' : 'light';

    group('$name build', () {
      test('text tokens reach 4.5:1 on the surfaces they sit on', () {
        final pairs = <String, (Color, Color)>{
          'ink on bg': (t.ink, t.bg),
          'ink on surface': (t.ink, t.surface),
          'inkMuted on bg': (t.inkMuted, t.bg),
          'inkMuted on surface': (t.inkMuted, t.surface),
          'accentText on bg': (t.accentText, t.bg),
          'accentText on surface': (t.accentText, t.surface),
          'onPrimary on primary': (t.onPrimary, t.primary),
          'onPrimaryMuted on primary': (t.onPrimaryMuted, t.primary),
          'onCta on cta': (t.onCta, t.cta),
          'warnInk on warnBg': (t.warnInk, t.warnBg),
          'onWarnAction on warnAction': (t.onWarnAction, t.warnAction),
          'onError on error': (t.onError, t.error),
        };
        for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: label);
        }
      });

      test('the "now" label reads on the now module', () {
        expect(
          contrast(t.ctaOnPrimaryLabel, t.primary),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('icons and filled controls reach 3:1', () {
        expect(contrast(t.inkFaint, t.bg), greaterThanOrEqualTo(3));
        expect(contrast(t.inkFaint, t.surface), greaterThanOrEqualTo(3));
        // Dark primary is a surface colour outlined by glowLine, so only the
        // light build's filled primary has to stand off the page by itself.
        if (!t.isDark) {
          expect(contrast(t.primary, t.surface), greaterThanOrEqualTo(3));
        }
      });

      test('the glow bar is never the only signal of state', () {
        // Light glow is 2.4:1 on surface — below 3:1 — so the day band also
        // marks the current routine with label weight and semantics. This
        // pins the measured value so a token change is a deliberate act.
        final ratio = contrast(t.glow, t.surface);
        expect(ratio, t.isDark ? greaterThan(3) : closeTo(2.42, 0.05));
      });
    });
  }

  test('light and dark resolve through ThemeMode', () {
    final light = buildMishkatTheme(Brightness.light);
    final dark = buildMishkatTheme(Brightness.dark);
    expect(light.extension<MishkatTokens>(), MishkatTokens.light);
    expect(dark.extension<MishkatTokens>(), MishkatTokens.dark);
    expect(light.scaffoldBackgroundColor, MishkatTokens.light.bg);
    expect(dark.scaffoldBackgroundColor, MishkatTokens.dark.bg);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
  });

  test('the UI font is Alexandria and athkar use Scheherazade New', () {
    expect(kUiFont, 'Alexandria');
    expect(kThikrFont, 'Scheherazade New');
    expect(
      MishkatType.thikr(MishkatTokens.light, ThikrSize.medium).fontFamily,
      kThikrFont,
    );
    expect(
      MishkatType.thikr(
        MishkatTokens.light,
        ThikrSize.medium,
        quranScript: true,
      ).fontFamily,
      kQuranFont,
    );
  });

  test('thikr sizes are fixed at 24 / 29 / 35 with a 2.0 line height', () {
    expect(ThikrSize.values.map((s) => s.px), [24, 29, 35]);
    expect(MishkatType.thikr(MishkatTokens.light, ThikrSize.small).height, 2.0);
  });

  test('lerp lands on its endpoints', () {
    final a = MishkatTokens.light, b = MishkatTokens.dark;
    expect(a.lerp(b, 0).ink, a.ink);
    expect(a.lerp(b, 1).ink, b.ink);
    expect(a.lerp(b, 1).isDark, isTrue);
  });

  test('glow is fill-only: no widget uses it as a text colour', () {
    // `glow` fails contrast as text on light surfaces; accentText exists for
    // coloured text. A source scan is crude, but this rule is easy to break
    // by autocomplete and invisible until someone squints at a screenshot.
    final offenders = <String>[];
    final textColour = RegExp(
      r'(TextStyle|MishkatType\.\w+)\([^;]*?color:\s*t(okens)?\.glow\b',
      dotAll: true,
    );
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final src = f.readAsStringSync();
      for (final m in textColour.allMatches(src)) {
        // Only flag when the glow colour sits inside one text-style call.
        final chunk = m.group(0)!;
        if (!chunk.contains('BoxDecoration') && chunk.length < 400) {
          offenders.add(f.path);
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
