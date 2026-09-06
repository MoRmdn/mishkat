import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import 'numerals.dart';

/// Hijri month names.
///
/// Supplied here rather than taken from the `hijri` package, whose Arabic
/// table spells the third month «ربيع الاول» without the hamza. In an app
/// whose whole subject is remembrance, that orthography should be right.
const List<String> kHijriMonthsAr = [
  'محرم',
  'صفر',
  'ربيع الأول',
  'ربيع الآخر',
  'جمادى الأولى',
  'جمادى الآخرة',
  'رجب',
  'شعبان',
  'رمضان',
  'شوال',
  'ذو القعدة',
  'ذو الحجة',
];

const List<String> kHijriMonthsEn = [
  'Muharram',
  'Safar',
  "Rabi' al-Awwal",
  "Rabi' al-Akhir",
  'Jumada al-Ula',
  'Jumada al-Akhirah',
  'Rajab',
  "Sha'ban",
  'Ramadan',
  'Shawwal',
  "Dhu al-Qi'dah",
  'Dhu al-Hijjah',
];

String hijriMonthName(int month, String languageCode) {
  final table = languageCode == 'ar' ? kHijriMonthsAr : kHijriMonthsEn;
  return table[(month - 1).clamp(0, 11)];
}

/// Formats today as the header subtitle: `٢٥ ربيع الأول ١٤٤٨ · الاثنين`
/// in Arabic, `25 Rabi' al-Awwal 1448 · Monday` in English.
String formatHijriHeader(DateTime date, String languageCode) {
  final h = HijriCalendar.fromDate(date);
  final day = localizeDigits(h.hDay, languageCode);
  final month = hijriMonthName(h.hMonth, languageCode);
  final year = localizeDigits(h.hYear, languageCode);
  final weekday = DateFormat('EEEE', languageCode).format(date);
  return '$day $month $year · $weekday';
}
