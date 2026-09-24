// TEMPORARY — removed in phase 3 of the 2a redesign.
//
// Maps the retired three-palette token names onto MishkatTokens so every
// screen keeps compiling while it is rebuilt against the new design. Nothing
// new may use these getters.
// ignore_for_file: deprecated_member_use_from_same_package
import 'package:flutter/painting.dart';

import 'mishkat_tokens.dart';

extension LegacyTokens on MishkatTokens {
  @Deprecated('use surface')
  Color get s2 => surface;
  @Deprecated('use lineSoft')
  Color get s3 => lineSoft;
  @Deprecated('use line')
  Color get border => line;
  @Deprecated('use lineSoft')
  Color get borderSoft => lineSoft;
  @Deprecated('use inkMuted')
  Color get muted => inkMuted;
  @Deprecated('use inkFaint')
  Color get faint => inkFaint;
  @Deprecated('use primary')
  Color get accent => primary;
  @Deprecated('use primary')
  Color get accentInk => primary;
  @Deprecated('use glow (fill) or accentText (text)')
  Color get gold => glow;
  @Deprecated('use onCta')
  Color get onGold => onCta;
  @Deprecated('use onPrimary')
  Color get onAccent => onPrimary;
  @Deprecated('use inkFaint')
  Color get navOff => inkFaint;
  @Deprecated('use glowSoft')
  Color get softBg => glowSoft;
  @Deprecated('use glowLine')
  Color get softBorder => glowLine;
  @Deprecated('the reader follows appearance: use bg')
  Color get rdBg => bg;
  @Deprecated('the reader follows appearance: use surface')
  Color get rdSurface => surface;
  @Deprecated('the reader follows appearance: use ink')
  Color get rdInk => ink;
  @Deprecated('the reader follows appearance: use inkMuted')
  Color get rdDim => inkMuted;
  @Deprecated('the reader follows appearance: use inkFaint')
  Color get rdFaint => inkFaint;
  @Deprecated('the reader follows appearance: use lineSoft')
  Color get rdFill => lineSoft;
  @Deprecated('use warnLine')
  Color get warnBorder => warnLine;
  @Deprecated('use warnInk')
  Color get warnBody => warnInk;
  @Deprecated('use warnAction')
  Color get warnBtn => warnAction;
  @Deprecated('use onWarnAction')
  Color get warnBtnInk => onWarnAction;
  @Deprecated('use surface')
  Color get disBg => surface;
  @Deprecated('use line')
  Color get disBorder => line;
  @Deprecated('use inkFaint')
  Color get disFg => inkFaint;
  @Deprecated('use primary')
  Color get onb1 => primary;
  @Deprecated('use primary')
  Color get onb2 => primary;
  @Deprecated('use onPrimary')
  Color get onbInk => onPrimary;
  @Deprecated('use onPrimaryMuted')
  Color get onbDim => onPrimaryMuted;
  @Deprecated('use onPrimaryMuted')
  Color get onbFill => onPrimaryMuted.withValues(alpha: 0.12);
  @Deprecated('use onPrimaryMuted')
  Color get onbLine => onPrimaryMuted.withValues(alpha: 0.3);
  @Deprecated('use primary')
  Color get card1 => primary;
  @Deprecated('use primary')
  Color get card2 => primary;
  @Deprecated('use onPrimary')
  Color get cardInk => onPrimary;
  @Deprecated('use onPrimaryMuted')
  Color get cardSub => onPrimaryMuted;
  @Deprecated('use cta')
  Color get cardChip => cta;
}
