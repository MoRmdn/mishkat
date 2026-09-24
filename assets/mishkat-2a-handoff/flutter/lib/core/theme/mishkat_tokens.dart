// GENERATED from tokens/mishkat.tokens.json — Mishkat Al-Wird, direction 2a "Dusk Grid".
// Replaces lib/core/theme/palettes.dart + the three-palette AppTokens.
// Read colours only via `context.tokens`; never a raw hex in a widget.
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

const kUiFont = 'Alexandria';
const kThikrFont = 'Scheherazade New';
const kThikrAltFont = 'Amiri Quran';

@immutable
class MishkatTokens extends ThemeExtension<MishkatTokens> {
  const MishkatTokens({
    required this.bg,
    required this.surface,
    required this.surfaceRaised,
    required this.line,
    required this.lineSoft,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.primary,
    required this.onPrimary,
    required this.onPrimaryMuted,
    required this.glow,
    required this.glowSoft,
    required this.glowLine,
    required this.accentText,
    required this.cta,
    required this.onCta,
    required this.ctaOnPrimaryLabel,
    required this.trackOff,
    required this.focusRing,
    required this.scrim,
    required this.warnBg,
    required this.warnLine,
    required this.warnInk,
    required this.warnAction,
    required this.onWarnAction,
    required this.error,
    required this.onError,
    required this.errorSoft,
    required this.isDark,
  });

  final Color bg;
  final Color surface;
  final Color surfaceRaised;
  final Color line;
  final Color lineSoft;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color primary;
  final Color onPrimary;
  final Color onPrimaryMuted;
  final Color glow;
  final Color glowSoft;
  final Color glowLine;
  final Color accentText;
  final Color cta;
  final Color onCta;
  final Color ctaOnPrimaryLabel;
  final Color trackOff;
  final Color focusRing;
  final Color scrim;
  final Color warnBg;
  final Color warnLine;
  final Color warnInk;
  final Color warnAction;
  final Color onWarnAction;
  final Color error;
  final Color onError;
  final Color errorSoft;
  final bool isDark;

  static const light = MishkatTokens(
      bg: Color(0xFFEFEBE7),
      surface: Color(0xFFF9F7F4),
      surfaceRaised: Color(0xFFFFFFFF),
      line: Color(0xFFDDD5CE),
      lineSoft: Color(0xFFE7E0DA),
      ink: Color(0xFF2A1B2C),
      inkMuted: Color(0xFF6E5F6B),
      inkFaint: Color(0xFF7E6F7B),
      primary: Color(0xFF4A2A4D),
      onPrimary: Color(0xFFFFFFFF),
      onPrimaryMuted: Color(0xFFE3D2DC),
      glow: Color(0xFFC9939A),
      glowSoft: Color(0xFFF2E1DF),
      glowLine: Color(0xFFE3C6C6),
      accentText: Color(0xFF8E4E5A),
      cta: Color(0xFFE5B3B9),
      onCta: Color(0xFF2A1B2C),
      ctaOnPrimaryLabel: Color(0xFFE5B3B9),
      trackOff: Color(0xFFCFC5BE),
      focusRing: Color(0xFF8E4E5A),
      scrim: Color(0x992A1B2C),
      warnBg: Color(0xFFFBF1E1),
      warnLine: Color(0xFFEBD6AE),
      warnInk: Color(0xFF5E4712),
      warnAction: Color(0xFF8A6820),
      onWarnAction: Color(0xFFFFFFFF),
      error: Color(0xFFA13A3A),
      onError: Color(0xFFFFFFFF),
      errorSoft: Color(0xFFF7E3E1),
      isDark: false,
  );

  static const dark = MishkatTokens(
      bg: Color(0xFF1B1320),
      surface: Color(0xFF261B2C),
      surfaceRaised: Color(0xFF2E2234),
      line: Color(0xFF3A2C40),
      lineSoft: Color(0xFF332539),
      ink: Color(0xFFF1E9EE),
      inkMuted: Color(0xFFBBA9B6),
      inkFaint: Color(0xFF9C8A98),
      primary: Color(0xFF261B2C),
      onPrimary: Color(0xFFF1E9EE),
      onPrimaryMuted: Color(0xFFBBA9B6),
      glow: Color(0xFFE5B3B9),
      glowSoft: Color(0xFF3A2C40),
      glowLine: Color(0xFF4A3552),
      accentText: Color(0xFFE5B3B9),
      cta: Color(0xFFE5B3B9),
      onCta: Color(0xFF1B1320),
      ctaOnPrimaryLabel: Color(0xFFE5B3B9),
      trackOff: Color(0xFF4A3A50),
      focusRing: Color(0xFFE5B3B9),
      scrim: Color(0xA3000000),
      warnBg: Color(0xFF2A2216),
      warnLine: Color(0xFF4C4023),
      warnInk: Color(0xFFF2E2B4),
      warnAction: Color(0xFFD8B86C),
      onWarnAction: Color(0xFF241D08),
      error: Color(0xFFF0A3A3),
      onError: Color(0xFF2A0E0E),
      errorSoft: Color(0xFF3A1E22),
      isDark: true,
  );

  static MishkatTokens of(Brightness b) => b == Brightness.dark ? dark : light;

  @override
  MishkatTokens copyWith({Color? bg, Color? surface, Color? surfaceRaised, Color? line, Color? lineSoft, Color? ink, Color? inkMuted, Color? inkFaint, Color? primary, Color? onPrimary, Color? onPrimaryMuted, Color? glow, Color? glowSoft, Color? glowLine, Color? accentText, Color? cta, Color? onCta, Color? ctaOnPrimaryLabel, Color? trackOff, Color? focusRing, Color? scrim, Color? warnBg, Color? warnLine, Color? warnInk, Color? warnAction, Color? onWarnAction, Color? error, Color? onError, Color? errorSoft, bool? isDark}) => MishkatTokens(
        bg: bg ?? this.bg,
        surface: surface ?? this.surface,
        surfaceRaised: surfaceRaised ?? this.surfaceRaised,
        line: line ?? this.line,
        lineSoft: lineSoft ?? this.lineSoft,
        ink: ink ?? this.ink,
        inkMuted: inkMuted ?? this.inkMuted,
        inkFaint: inkFaint ?? this.inkFaint,
        primary: primary ?? this.primary,
        onPrimary: onPrimary ?? this.onPrimary,
        onPrimaryMuted: onPrimaryMuted ?? this.onPrimaryMuted,
        glow: glow ?? this.glow,
        glowSoft: glowSoft ?? this.glowSoft,
        glowLine: glowLine ?? this.glowLine,
        accentText: accentText ?? this.accentText,
        cta: cta ?? this.cta,
        onCta: onCta ?? this.onCta,
        ctaOnPrimaryLabel: ctaOnPrimaryLabel ?? this.ctaOnPrimaryLabel,
        trackOff: trackOff ?? this.trackOff,
        focusRing: focusRing ?? this.focusRing,
        scrim: scrim ?? this.scrim,
        warnBg: warnBg ?? this.warnBg,
        warnLine: warnLine ?? this.warnLine,
        warnInk: warnInk ?? this.warnInk,
        warnAction: warnAction ?? this.warnAction,
        onWarnAction: onWarnAction ?? this.onWarnAction,
        error: error ?? this.error,
        onError: onError ?? this.onError,
        errorSoft: errorSoft ?? this.errorSoft,
        isDark: isDark ?? this.isDark,
      );

  @override
  MishkatTokens lerp(ThemeExtension<MishkatTokens>? other, double t) {
    if (other is! MishkatTokens) return this;
    return MishkatTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineSoft: Color.lerp(lineSoft, other.lineSoft, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onPrimaryMuted: Color.lerp(onPrimaryMuted, other.onPrimaryMuted, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      glowSoft: Color.lerp(glowSoft, other.glowSoft, t)!,
      glowLine: Color.lerp(glowLine, other.glowLine, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      cta: Color.lerp(cta, other.cta, t)!,
      onCta: Color.lerp(onCta, other.onCta, t)!,
      ctaOnPrimaryLabel: Color.lerp(ctaOnPrimaryLabel, other.ctaOnPrimaryLabel, t)!,
      trackOff: Color.lerp(trackOff, other.trackOff, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      warnBg: Color.lerp(warnBg, other.warnBg, t)!,
      warnLine: Color.lerp(warnLine, other.warnLine, t)!,
      warnInk: Color.lerp(warnInk, other.warnInk, t)!,
      warnAction: Color.lerp(warnAction, other.warnAction, t)!,
      onWarnAction: Color.lerp(onWarnAction, other.onWarnAction, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension MishkatTokensX on BuildContext {
  MishkatTokens get tokens => Theme.of(this).extension<MishkatTokens>()!;
}

abstract final class Space {
  static const xxs = 4.0, xs = 8.0, sm = 12.0, md = 16.0, lg = 20.0, xl = 24.0, xxl = 32.0, xxxl = 40.0;
  static const screenInline = 20.0;
}

abstract final class Radii {
  static const sm = 10.0, md = 14.0, lg = 18.0, xl = 24.0, pill = 999.0;
}

abstract final class Sizes {
  static const touchMin = 48.0, icon = 22.0, iconSm = 16.0, iconLg = 24.0;
  static const button = 52.0, row = 58.0, nav = 64.0;
}

abstract final class Motion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 200);
  static const slow = Duration(milliseconds: 320);
  static const tapPulse = Duration(milliseconds: 140);
  static const autoAdvance = Duration(milliseconds: 480);
  static const curve = Cubic(0.2, 0, 0, 1);

  /// Honour the OS "reduce motion" setting everywhere an animation runs.
  static Duration of(BuildContext c, Duration d) =>
      MediaQuery.of(c).disableAnimations ? Duration.zero : d;
}

/// Thikr text sizes. Fixed per setting: long athkar scroll, they never shrink.
enum ThikrSize {
  small(24),
  medium(29),
  large(35);

  const ThikrSize(this.px);
  final double px;
}

abstract final class MishkatType {
  static TextStyle display(MishkatTokens t) => TextStyle(fontFamily: kUiFont, fontSize: 30, fontWeight: FontWeight.w500, height: 1.35, color: t.ink);
  static TextStyle title(MishkatTokens t) => TextStyle(fontFamily: kUiFont, fontSize: 20, fontWeight: FontWeight.w500, height: 1.4, color: t.ink);
  static TextStyle headline(MishkatTokens t) => TextStyle(fontFamily: kUiFont, fontSize: 17, fontWeight: FontWeight.w500, height: 1.45, color: t.ink);
  static TextStyle body(MishkatTokens t) => TextStyle(fontFamily: kUiFont, fontSize: 14.5, fontWeight: FontWeight.w400, height: 1.75, color: t.ink);
  static TextStyle bodyMuted(MishkatTokens t) => TextStyle(fontFamily: kUiFont, fontSize: 14.5, fontWeight: FontWeight.w300, height: 1.85, color: t.inkMuted);
  static TextStyle label(MishkatTokens t) => TextStyle(fontFamily: kUiFont, fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.4, color: t.ink);
  static TextStyle caption(MishkatTokens t) => TextStyle(fontFamily: kUiFont, fontSize: 12, fontWeight: FontWeight.w300, height: 1.6, color: t.inkMuted);
  static TextStyle counter(MishkatTokens t) => TextStyle(fontFamily: kUiFont, fontSize: 60, fontWeight: FontWeight.w300, height: 1, color: t.ink);
  static TextStyle thikr(MishkatTokens t, ThikrSize s, {bool quranScript = false}) => TextStyle(
        fontFamily: quranScript ? kThikrAltFont : kThikrFont,
        fontSize: s.px,
        height: 2.0,
        color: t.ink,
      );
}

ThemeData buildMishkatTheme(Brightness b) {
  final t = MishkatTokens.of(b);
  final base = ThemeData(brightness: b, useMaterial3: true, fontFamily: kUiFont);
  return base.copyWith(
    scaffoldBackgroundColor: t.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: t.primary, brightness: b).copyWith(
      primary: t.primary,
      onPrimary: t.onPrimary,
      secondary: t.cta,
      onSecondary: t.onCta,
      surface: t.surface,
      onSurface: t.ink,
      error: t.error,
      onError: t.onError,
    ),
    extensions: [t],
    splashFactory: NoSplash.splashFactory,
    textTheme: base.textTheme.apply(bodyColor: t.ink, displayColor: t.ink, fontFamily: kUiFont),
  );
}

// Unused-import guard for lerpDouble in custom painters that import this file.
double? mishkatLerp(double a, double b, double t) => lerpDouble(a, b, t);
