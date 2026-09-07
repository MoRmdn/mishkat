import 'package:flutter/material.dart';

/// The three app palettes from the design board.
///
/// Values are transcribed verbatim from `AthkarPhone.dc.html` (`PAL`). Each
/// palette carries an accent set, a light and a dark neutral ramp, and a
/// separate *reader* ramp — the reader stays dark-toned in every build.
enum AppPalette {
  teal,
  indigo,
  olive;

  static AppPalette fromName(String? n) => AppPalette.values.firstWhere(
    (p) => p.name == n,
    orElse: () => AppPalette.teal,
  );
}

Color _hex(String h) => Color(int.parse(h.replaceFirst('#', 'FF'), radix: 16));

/// Neutral ramp for one appearance (light or dark) of one palette.
@immutable
class NeutralRamp {
  const NeutralRamp({
    required this.bg,
    required this.surface,
    required this.s2,
    required this.s3,
    required this.border,
    required this.borderSoft,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.navOff,
    required this.trackOff,
    required this.softBg,
    required this.softBorder,
    this.accent,
    this.gold,
  });

  final Color bg, surface, s2, s3, border, borderSoft;
  final Color ink, muted, faint, navOff, trackOff, softBg, softBorder;

  /// Dark ramps lighten the accent and gold so they still carry 4.5:1.
  final Color? accent, gold;
}

@immutable
class ReaderRamp {
  const ReaderRamp({
    required this.bg,
    required this.surface,
    required this.ink,
    required this.dim,
    required this.faint,
  });

  final Color bg, surface, ink, dim, faint;
  Color get fill => const Color(0x14FFFFFF); // rgba(255,255,255,0.08)
}

@immutable
class PaletteSpec {
  const PaletteSpec({
    required this.accent,
    required this.accentInk,
    required this.gold,
    required this.onGold,
    required this.light,
    required this.dark,
    required this.reader,
  });

  final Color accent, accentInk, gold, onGold;
  final NeutralRamp light, dark;
  final ReaderRamp reader;
}

final Map<AppPalette, PaletteSpec> kPalettes = {
  AppPalette.teal: PaletteSpec(
    accent: _hex('#1C6B58'),
    accentInk: _hex('#123A31'),
    gold: _hex('#CBA75C'),
    onGold: _hex('#16241E'),
    light: NeutralRamp(
      bg: _hex('#F3F5F3'),
      surface: _hex('#FFFFFF'),
      s2: _hex('#F4F7F5'),
      s3: _hex('#E7EBE8'),
      border: _hex('#E3E8E4'),
      borderSoft: _hex('#EEF2EF'),
      ink: _hex('#0F1F1A'),
      muted: _hex('#5B6A64'),
      faint: _hex('#69766F'),
      navOff: _hex('#7C8A84'),
      trackOff: _hex('#C0C9C4'),
      softBg: _hex('#F0F5F2'),
      softBorder: _hex('#D6E3DB'),
    ),
    dark: NeutralRamp(
      bg: _hex('#0E1613'),
      surface: _hex('#17211E'),
      s2: _hex('#1C2724'),
      s3: _hex('#22302B'),
      border: _hex('#283733'),
      borderSoft: _hex('#202D29'),
      ink: _hex('#E9EFEB'),
      muted: _hex('#AEBBB5'),
      faint: _hex('#9CA9A3'),
      navOff: _hex('#84918B'),
      trackOff: _hex('#3C4A45'),
      softBg: _hex('#17251F'),
      softBorder: _hex('#2C3F38'),
      accent: _hex('#3D9A82'),
      gold: _hex('#DBBC74'),
    ),
    reader: ReaderRamp(
      bg: _hex('#0F1815'),
      surface: _hex('#17211D'),
      ink: _hex('#F2F7F4'),
      dim: _hex('#B7C4BE'),
      faint: _hex('#94A29B'),
    ),
  ),
  AppPalette.indigo: PaletteSpec(
    accent: _hex('#2E5C7E'),
    accentInk: _hex('#16233D'),
    gold: _hex('#C79A4F'),
    onGold: _hex('#101725'),
    light: NeutralRamp(
      bg: _hex('#F2F4F7'),
      surface: _hex('#FFFFFF'),
      s2: _hex('#F3F5F9'),
      s3: _hex('#E6E9EF'),
      border: _hex('#E0E5EC'),
      borderSoft: _hex('#EBEEF3'),
      ink: _hex('#101725'),
      muted: _hex('#5A6472'),
      faint: _hex('#6B7482'),
      navOff: _hex('#7B8593'),
      trackOff: _hex('#C1C8D3'),
      softBg: _hex('#EFF3F9'),
      softBorder: _hex('#D9DFE9'),
    ),
    dark: NeutralRamp(
      bg: _hex('#0D131F'),
      surface: _hex('#161E2D'),
      s2: _hex('#1B2434'),
      s3: _hex('#20293A'),
      border: _hex('#273248'),
      borderSoft: _hex('#1F2839'),
      ink: _hex('#E7EBF2'),
      muted: _hex('#ADB6C4'),
      faint: _hex('#9AA4B4'),
      navOff: _hex('#848E9E'),
      trackOff: _hex('#3A4658'),
      softBg: _hex('#16223A'),
      softBorder: _hex('#2C3C57'),
      accent: _hex('#5A8FB8'),
      gold: _hex('#D8AF69'),
    ),
    reader: ReaderRamp(
      bg: _hex('#0E1420'),
      surface: _hex('#161D2B'),
      ink: _hex('#F1F4FA'),
      dim: _hex('#BAC3D2'),
      faint: _hex('#98A2B3'),
    ),
  ),
  AppPalette.olive: PaletteSpec(
    accent: _hex('#6B7440'),
    accentInk: _hex('#3B3B23'),
    gold: _hex('#C2894A'),
    onGold: _hex('#201E13'),
    light: NeutralRamp(
      bg: _hex('#F6F4EE'),
      surface: _hex('#FFFDF8'),
      s2: _hex('#F2EFE4'),
      s3: _hex('#E9E4D6'),
      border: _hex('#E6E1D3'),
      borderSoft: _hex('#EDE9DC'),
      ink: _hex('#1E1C12'),
      muted: _hex('#67614F'),
      faint: _hex('#77705C'),
      navOff: _hex('#8B8471'),
      trackOff: _hex('#C7C1AC'),
      softBg: _hex('#F1EEE2'),
      softBorder: _hex('#DCD6C2'),
    ),
    dark: NeutralRamp(
      bg: _hex('#14150E'),
      surface: _hex('#1E2015'),
      s2: _hex('#24261A'),
      s3: _hex('#2B2D20'),
      border: _hex('#353725'),
      borderSoft: _hex('#272919'),
      ink: _hex('#EFEDE2'),
      muted: _hex('#B9B4A0'),
      faint: _hex('#A6A08C'),
      navOff: _hex('#8F8875'),
      trackOff: _hex('#474930'),
      softBg: _hex('#212416'),
      softBorder: _hex('#3C3F28'),
      accent: _hex('#9BA95F'),
      gold: _hex('#D6A768'),
    ),
    reader: ReaderRamp(
      bg: _hex('#191A12'),
      surface: _hex('#212218'),
      ink: _hex('#F6F4E9'),
      dim: _hex('#C4BFA9'),
      faint: _hex('#A9A38E'),
    ),
  ),
};

/// The amber warning ramp used by the exact-alarm banner and OEM callouts.
/// Shared across palettes — a warning should not change hue with the theme.
@immutable
class WarnRamp {
  const WarnRamp({
    required this.bg,
    required this.border,
    required this.ink,
    required this.body,
    required this.btn,
    required this.btnInk,
  });

  final Color bg, border, ink, body, btn, btnInk;
}

final WarnRamp kWarnLight = WarnRamp(
  bg: _hex('#FDF4E3'),
  border: _hex('#EBD9AE'),
  ink: _hex('#5E4712'),
  body: _hex('#6F5722'),
  btn: _hex('#8A6820'),
  btnInk: _hex('#FFFFFF'),
);

final WarnRamp kWarnDark = WarnRamp(
  bg: _hex('#2A2415'),
  border: _hex('#4C4023'),
  ink: _hex('#F2E2B4'),
  body: _hex('#DFCEA2'),
  btn: _hex('#D8B86C'),
  btnInk: _hex('#241D08'),
);
