/// Locale-aware number and clock formatting.
///
/// The design switches numerals with the language: Arabic uses Arabic-Indic
/// digits and ص/م, English uses Latin digits and AM/PM. This mirrors the
/// prototype's `AR()`, `num()` and `time()` helpers.
library;

const List<String> _arabicIndic = [
  '٠',
  '١',
  '٢',
  '٣',
  '٤',
  '٥',
  '٦',
  '٧',
  '٨',
  '٩',
];

/// Converts every ASCII digit in [input] to its Arabic-Indic form.
String toArabicIndic(String input) {
  final buf = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      buf.write(_arabicIndic[rune - 0x30]);
    } else {
      buf.writeCharCode(rune);
    }
  }
  return buf.toString();
}

/// Formats [value] in the digit system used by [languageCode].
String localizeDigits(Object value, String languageCode) {
  final s = value.toString();
  return languageCode == 'ar' ? toArabicIndic(s) : s;
}

/// 12-hour clock in the conventions of [languageCode].
///
/// [am] and [pm] come from the localizations so the suffix stays translatable
/// (ص / م in Arabic, AM / PM in English).
String formatClock(
  int hour24,
  int minute,
  String languageCode, {
  required String am,
  required String pm,
}) {
  final h12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final mm = minute.toString().padLeft(2, '0');
  final suffix = hour24 < 12 ? am : pm;
  return '${localizeDigits(h12, languageCode)}:'
      '${localizeDigits(mm, languageCode)} $suffix';
}

/// The clock without its AM/PM suffix, for the compact day band where the
/// routine's name already says which half of the day it is.
String formatClockShort(int hour24, int minute, String languageCode) {
  final h12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final mm = minute.toString().padLeft(2, '0');
  return '${localizeDigits(h12, languageCode)}:${localizeDigits(mm, languageCode)}';
}

/// [formatClock] for a [DateTime].
String formatTime(
  DateTime at,
  String languageCode, {
  required String am,
  required String pm,
}) => formatClock(at.hour, at.minute, languageCode, am: am, pm: pm);
