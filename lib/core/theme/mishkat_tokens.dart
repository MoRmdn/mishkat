// Mishkat Al-Wird, direction 2a "Dusk Grid". Generated from the handoff's
// tokens/mishkat.tokens.json — one brand identity, light and dark.
//
// Read colours only via `context.tokens`; never a raw hex in a widget.
import 'package:flutter/material.dart';

const kUiFont = 'Alexandria';
const kThikrFont = 'Scheherazade New';
const kQuranFont = 'Amiri Quran';

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

  /// Screen background.
  final Color bg;

  /// Cards, lists, the reader page and sheets.
  final Color surface;

  /// Selected segment, switch thumb, text on busy backgrounds.
  final Color surfaceRaised;
  final Color line;
  final Color lineSoft;

  /// Primary text.
  final Color ink;

  /// Secondary text.
  final Color inkMuted;

  /// Inactive nav icons — never body text.
  final Color inkFaint;

  /// The "now" module, primary buttons and done states. In dark this is a
  /// surface colour and the module draws a [glowLine] border instead.
  final Color primary;
  final Color onPrimary;
  final Color onPrimaryMuted;

  /// Fill only: current-routine bar, counted bead, lamp. Never text.
  final Color glow;

  /// Icon chips, the active nav pill, empty-state halos.
  final Color glowSoft;
  final Color glowLine;

  /// Coloured text: links and the "now" label.
  final Color accentText;

  /// The single start button inside the now module.
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
  MishkatTokens copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceRaised,
    Color? line,
    Color? lineSoft,
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? primary,
    Color? onPrimary,
    Color? onPrimaryMuted,
    Color? glow,
    Color? glowSoft,
    Color? glowLine,
    Color? accentText,
    Color? cta,
    Color? onCta,
    Color? ctaOnPrimaryLabel,
    Color? trackOff,
    Color? focusRing,
    Color? scrim,
    Color? warnBg,
    Color? warnLine,
    Color? warnInk,
    Color? warnAction,
    Color? onWarnAction,
    Color? error,
    Color? onError,
    Color? errorSoft,
    bool? isDark,
  }) => MishkatTokens(
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
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return MishkatTokens(
      bg: c(bg, other.bg),
      surface: c(surface, other.surface),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      line: c(line, other.line),
      lineSoft: c(lineSoft, other.lineSoft),
      ink: c(ink, other.ink),
      inkMuted: c(inkMuted, other.inkMuted),
      inkFaint: c(inkFaint, other.inkFaint),
      primary: c(primary, other.primary),
      onPrimary: c(onPrimary, other.onPrimary),
      onPrimaryMuted: c(onPrimaryMuted, other.onPrimaryMuted),
      glow: c(glow, other.glow),
      glowSoft: c(glowSoft, other.glowSoft),
      glowLine: c(glowLine, other.glowLine),
      accentText: c(accentText, other.accentText),
      cta: c(cta, other.cta),
      onCta: c(onCta, other.onCta),
      ctaOnPrimaryLabel: c(ctaOnPrimaryLabel, other.ctaOnPrimaryLabel),
      trackOff: c(trackOff, other.trackOff),
      focusRing: c(focusRing, other.focusRing),
      scrim: c(scrim, other.scrim),
      warnBg: c(warnBg, other.warnBg),
      warnLine: c(warnLine, other.warnLine),
      warnInk: c(warnInk, other.warnInk),
      warnAction: c(warnAction, other.warnAction),
      onWarnAction: c(onWarnAction, other.onWarnAction),
      error: c(error, other.error),
      onError: c(onError, other.onError),
      errorSoft: c(errorSoft, other.errorSoft),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// `context.tokens.primary` — the only way widgets should reach a colour.
extension MishkatTokensX on BuildContext {
  MishkatTokens get tokens => Theme.of(this).extension<MishkatTokens>()!;
}

abstract final class Space {
  static const xxs = 4.0, xs = 8.0, sm = 12.0, md = 16.0, lg = 20.0;
  static const xl = 24.0, xxl = 32.0, xxxl = 40.0;
  static const screenInline = 20.0;
}

abstract final class Radii {
  static const sm = 10.0, md = 14.0, lg = 18.0, xl = 24.0, pill = 999.0;

  /// App-icon style tiles round their corners at 26% of their size.
  static double iconTile(double size) => size * 0.26;
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

  /// Honours the OS "reduce motion" setting everywhere an animation runs.
  static Duration of(BuildContext c, Duration d) =>
      MediaQuery.disableAnimationsOf(c) ? Duration.zero : d;

  static bool reduced(BuildContext c) => MediaQuery.disableAnimationsOf(c);
}

/// Thikr text sizes. Fixed per setting: long athkar scroll, they never shrink.
enum ThikrSize {
  small(24),
  medium(29),
  large(35);

  const ThikrSize(this.px);
  final double px;

  /// Stored as the enum index, which kept its meaning through the redesign.
  static ThikrSize fromIndex(int? i) =>
      ThikrSize.values[(i ?? 1).clamp(0, ThikrSize.values.length - 1)];
}

abstract final class MishkatType {
  static TextStyle display(MishkatTokens t) => TextStyle(
    fontFamily: kUiFont,
    fontSize: 30,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: t.ink,
  );
  static TextStyle title(MishkatTokens t) => TextStyle(
    fontFamily: kUiFont,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: t.ink,
  );
  static TextStyle headline(MishkatTokens t) => TextStyle(
    fontFamily: kUiFont,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: t.ink,
  );
  static TextStyle body(MishkatTokens t) => TextStyle(
    fontFamily: kUiFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    height: 1.75,
    color: t.ink,
  );
  static TextStyle bodyMuted(MishkatTokens t) => TextStyle(
    fontFamily: kUiFont,
    fontSize: 14.5,
    fontWeight: FontWeight.w300,
    height: 1.85,
    color: t.inkMuted,
  );
  static TextStyle label(MishkatTokens t) => TextStyle(
    fontFamily: kUiFont,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: t.ink,
  );
  static TextStyle caption(MishkatTokens t) => TextStyle(
    fontFamily: kUiFont,
    fontSize: 12,
    fontWeight: FontWeight.w300,
    height: 1.6,
    color: t.inkMuted,
  );
  static TextStyle counter(MishkatTokens t) => TextStyle(
    fontFamily: kUiFont,
    fontSize: 60,
    fontWeight: FontWeight.w300,
    height: 1,
    color: t.ink,
  );
  static TextStyle thikr(
    MishkatTokens t,
    ThikrSize s, {
    bool quranScript = false,
  }) => TextStyle(
    fontFamily: quranScript ? kQuranFont : kThikrFont,
    fontSize: s.px,
    height: 2.0,
    color: t.ink,
  );
}

ThemeData buildMishkatTheme(Brightness b) {
  final t = MishkatTokens.of(b);
  final base = ThemeData(
    brightness: b,
    useMaterial3: true,
    fontFamily: kUiFont,
  );
  return base.copyWith(
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: t.primary, brightness: b)
        .copyWith(
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
    highlightColor: t.lineSoft.withValues(alpha: 0.5),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: t.accentText,
      selectionColor: t.glowSoft,
      selectionHandleColor: t.accentText,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.surface,
      modalBarrierColor: t.scrim,
    ),
    dialogTheme: DialogThemeData(backgroundColor: t.surface),
    textTheme: base.textTheme.apply(
      bodyColor: t.ink,
      displayColor: t.ink,
      fontFamily: kUiFont,
    ),
  );
}
