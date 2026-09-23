import 'package:flutter_test/flutter_test.dart';

import 'package:mishkat/core/format/numerals.dart';

void main() {
  group('numerals', () {
    test('converts ASCII digits to Arabic-Indic', () {
      expect(toArabicIndic('2026'), '٢٠٢٦');
      expect(toArabicIndic('6:30'), '٦:٣٠');
    });

    test('leaves non-digits untouched', () {
      expect(toArabicIndic('Fajr 4:48 AM'), 'Fajr ٤:٤٨ AM');
    });

    test('localizeDigits switches on language', () {
      expect(localizeDigits(14, 'ar'), '١٤');
      expect(localizeDigits(14, 'en'), '14');
    });
  });

  group('formatClock', () {
    test('Arabic uses Arabic-Indic digits and ص/م', () {
      expect(formatClock(6, 30, 'ar', am: 'ص', pm: 'م'), '٦:٣٠ ص');
      expect(formatClock(17, 30, 'ar', am: 'ص', pm: 'م'), '٥:٣٠ م');
    });

    test('English uses Latin digits and AM/PM', () {
      expect(formatClock(6, 30, 'en', am: 'AM', pm: 'PM'), '6:30 AM');
      expect(formatClock(22, 30, 'en', am: 'AM', pm: 'PM'), '10:30 PM');
    });

    test('midnight and noon map to 12, not 0', () {
      expect(formatClock(0, 5, 'en', am: 'AM', pm: 'PM'), '12:05 AM');
      expect(formatClock(12, 0, 'en', am: 'AM', pm: 'PM'), '12:00 PM');
    });
  });
}
