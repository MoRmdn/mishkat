import 'package:flutter/material.dart';

import 'palettes.dart';

const String kUiFont = 'IBMPlexSansArabic';
const String kQuranFont = 'AmiriQuran';

/// Every semantic colour the app draws with.
///
/// Mirrors the CSS custom properties the design prototype sets on its root
/// element. Widgets read from here — never from [kPalettes] directly, and never
/// from a raw hex literal.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.bg,
    required this.surface,
    required this.s2,
    required this.s3,
    required this.border,
    required this.borderSoft,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.accent,
    required this.accentInk,
    required this.gold,
    required this.onGold,
    required this.onAccent,
    required this.navOff,
    required this.trackOff,
    required this.softBg,
    required this.softBorder,
    required this.rdBg,
    required this.rdSurface,
    required this.rdInk,
    required this.rdDim,
    required this.rdFaint,
    required this.rdFill,
    required this.warnBg,
    required this.warnBorder,
    required this.warnInk,
    required this.warnBody,
    required this.warnBtn,
    required this.warnBtnInk,
    required this.disBg,
    required this.disBorder,
    required this.disFg,
    required this.scrim,
    required this.onb1,
    required this.onb2,
    required this.onbInk,
    required this.onbDim,
    required this.onbFill,
    required this.onbLine,
    required this.card1,
    required this.card2,
    required this.cardInk,
    required this.cardSub,
    required this.cardChip,
    required this.isDark,
  });

  final Color bg, surface, s2, s3, border, borderSoft;
  final Color ink, muted, faint;
  final Color accent, accentInk, gold, onGold, onAccent;
  final Color navOff, trackOff, softBg, softBorder;
  final Color rdBg, rdSurface, rdInk, rdDim, rdFaint, rdFill;
  final Color warnBg, warnBorder, warnInk, warnBody, warnBtn, warnBtnInk;
  final Color disBg, disBorder, disFg, scrim;
  final Color onb1, onb2, onbInk, onbDim, onbFill, onbLine;
  final Color card1, card2, cardInk, cardSub, cardChip;
  final bool isDark;

  /// Builds the token set for one palette in one appearance, applying the same
  /// derivations the prototype performs in `renderVals()`.
  factory AppTokens.of(AppPalette palette, Brightness brightness) {
    final spec = kPalettes[palette]!;
    final dark = brightness == Brightness.dark;
    final n = dark ? spec.dark : spec.light;
    final warn = dark ? kWarnDark : kWarnLight;

    return AppTokens(
      bg: n.bg,
      surface: n.surface,
      s2: n.s2,
      s3: n.s3,
      border: n.border,
      borderSoft: n.borderSoft,
      ink: n.ink,
      muted: n.muted,
      faint: n.faint,
      // Dark ramps override accent and gold so contrast holds on near-black.
      accent: n.accent ?? spec.accent,
      accentInk: spec.accentInk,
      gold: n.gold ?? spec.gold,
      onGold: spec.onGold,
      onAccent: dark ? spec.onGold : const Color(0xFFFFFFFF),
      navOff: n.navOff,
      trackOff: n.trackOff,
      softBg: n.softBg,
      softBorder: n.softBorder,
      rdBg: spec.reader.bg,
      rdSurface: spec.reader.surface,
      rdInk: spec.reader.ink,
      rdDim: spec.reader.dim,
      rdFaint: spec.reader.faint,
      rdFill: spec.reader.fill,
      warnBg: warn.bg,
      warnBorder: warn.border,
      warnInk: warn.ink,
      warnBody: warn.body,
      warnBtn: warn.btn,
      warnBtnInk: warn.btnInk,
      disBg: n.s2,
      disBorder: n.border,
      disFg: n.faint,
      scrim: dark ? const Color(0x9E000000) : const Color(0x800A1411),
      onb1: spec.accentInk,
      onb2: dark ? const Color(0xFF08100D) : spec.reader.bg,
      onbInk: const Color(0xFFEAF2EE),
      onbDim: const Color(0xC7EAF2EE),
      onbFill: const Color(0x14FFFFFF),
      onbLine: const Color(0x29FFFFFF),
      card1: dark ? spec.accentInk : spec.accent,
      card2: dark ? spec.reader.bg : spec.accentInk,
      cardInk: const Color(0xFFF1F7F4),
      cardSub: dark ? const Color(0xD1F1F7F4) : const Color(0xDBF1F7F4),
      cardChip: const Color(0x2EFFFFFF),
      isDark: dark,
    );
  }

  @override
  AppTokens copyWith({Color? bg}) => this;

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppTokens(
      bg: c(bg, other.bg),
      surface: c(surface, other.surface),
      s2: c(s2, other.s2),
      s3: c(s3, other.s3),
      border: c(border, other.border),
      borderSoft: c(borderSoft, other.borderSoft),
      ink: c(ink, other.ink),
      muted: c(muted, other.muted),
      faint: c(faint, other.faint),
      accent: c(accent, other.accent),
      accentInk: c(accentInk, other.accentInk),
      gold: c(gold, other.gold),
      onGold: c(onGold, other.onGold),
      onAccent: c(onAccent, other.onAccent),
      navOff: c(navOff, other.navOff),
      trackOff: c(trackOff, other.trackOff),
      softBg: c(softBg, other.softBg),
      softBorder: c(softBorder, other.softBorder),
      rdBg: c(rdBg, other.rdBg),
      rdSurface: c(rdSurface, other.rdSurface),
      rdInk: c(rdInk, other.rdInk),
      rdDim: c(rdDim, other.rdDim),
      rdFaint: c(rdFaint, other.rdFaint),
      rdFill: c(rdFill, other.rdFill),
      warnBg: c(warnBg, other.warnBg),
      warnBorder: c(warnBorder, other.warnBorder),
      warnInk: c(warnInk, other.warnInk),
      warnBody: c(warnBody, other.warnBody),
      warnBtn: c(warnBtn, other.warnBtn),
      warnBtnInk: c(warnBtnInk, other.warnBtnInk),
      disBg: c(disBg, other.disBg),
      disBorder: c(disBorder, other.disBorder),
      disFg: c(disFg, other.disFg),
      scrim: c(scrim, other.scrim),
      onb1: c(onb1, other.onb1),
      onb2: c(onb2, other.onb2),
      onbInk: c(onbInk, other.onbInk),
      onbDim: c(onbDim, other.onbDim),
      onbFill: c(onbFill, other.onbFill),
      onbLine: c(onbLine, other.onbLine),
      card1: c(card1, other.card1),
      card2: c(card2, other.card2),
      cardInk: c(cardInk, other.cardInk),
      cardSub: c(cardSub, other.cardSub),
      cardChip: c(cardChip, other.cardChip),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Convenience accessor so widgets can write `context.tokens.accent`.
extension AppTokensX on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}

ThemeData buildAppTheme(AppPalette palette, Brightness brightness) {
  final t = AppTokens.of(palette, brightness);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: kUiFont,
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: t.accent,
      brightness: brightness,
    ).copyWith(
      primary: t.accent,
      onPrimary: t.onAccent,
      surface: t.surface,
      onSurface: t.ink,
    ),
    extensions: [t],
  );
}
