import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mishkat/core/format/hijri_date.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('Arabic month names carry correct orthography', () {
    expect(hijriMonthName(3, 'ar'), 'ربيع الأول');
    expect(hijriMonthName(4, 'ar'), 'ربيع الآخر');
    expect(hijriMonthName(9, 'ar'), 'رمضان');
    expect(hijriMonthName(12, 'ar'), 'ذو الحجة');
  });

  test('English month names are transliterated', () {
    expect(hijriMonthName(3, 'en'), "Rabi' al-Awwal");
    expect(hijriMonthName(9, 'en'), 'Ramadan');
  });

  test('month lookup is clamped rather than throwing', () {
    expect(() => hijriMonthName(0, 'ar'), returnsNormally);
    expect(() => hijriMonthName(13, 'ar'), returnsNormally);
  });

  test('header uses localized digits and weekday', () {
    final d = DateTime(2026, 9, 7); // a Monday
    final ar = formatHijriHeader(d, 'ar');
    final en = formatHijriHeader(d, 'en');

    expect(ar, contains('ربيع الأول'));
    expect(ar, contains('الاثنين'));
    expect(ar, isNot(matches(RegExp(r'[0-9]'))), reason: 'no Latin digits in ar');

    expect(en, contains("Rabi' al-Awwal"));
    expect(en, contains('Monday'));
    expect(en, matches(RegExp(r'\d')));
  });
}
