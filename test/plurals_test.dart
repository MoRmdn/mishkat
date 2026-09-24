import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/format/numerals.dart';
import 'package:mishkat/core/l10n/app_localizations.dart';

/// Arabic plural agreement is not optional: "١ أيام" is wrong. Each count
/// selects its form from a `num`, while the digits shown are localized
/// separately.
void main() {
  final ar = lookupL(const Locale('ar'));
  final en = lookupL(const Locale('en'));
  String d(int n) => localizeDigits(n, 'ar');

  test('streak days take the right Arabic form at each count', () {
    expect(ar.streakDays(1, d(1)), 'يوم واحد متتالٍ');
    expect(ar.streakDays(2, d(2)), 'يومان متتاليان');
    expect(ar.streakDays(9, d(9)), '٩ أيام متتالية');
    expect(ar.streakDays(11, d(11)), '١١ يوماً متتالياً');
    expect(ar.streakDays(100, d(100)), '١٠٠ يوم متتالٍ');
  });

  test('a routine\'s athkar count agrees with its number', () {
    expect(ar.athkarCountLabel(1, d(1)), 'ذكر واحد');
    expect(ar.athkarCountLabel(2, d(2)), 'ذكران');
    expect(ar.athkarCountLabel(6, d(6)), '٦ أذكار');
    expect(ar.athkarCountLabel(12, d(12)), '١٢ ذكراً');
    expect(en.athkarCountLabel(1, '1'), '1 thikr');
    expect(en.athkarCountLabel(6, '6'), '6 athkar');
  });

  test('reading time never says "١ دقائق"', () {
    expect(ar.aboutMinutes(1, d(1)), 'نحو دقيقة');
    expect(ar.aboutMinutes(2, d(2)), 'نحو دقيقتين');
    expect(ar.aboutMinutes(4, d(4)), 'نحو ٤ دقائق');
    expect(en.aboutMinutes(1, '1'), 'about 1 minute');
    expect(en.aboutMinutes(3, '3'), 'about 3 minutes');
  });

  test('the completion line has a zero form instead of "٠ يوم"', () {
    expect(ar.streakNow(0, d(0)), 'ابدأ تتابعك اليوم.');
    expect(ar.streakNow(10, d(10)), 'تتابعك الآن ١٠ أيام.');
    expect(en.streakNow(1, '1'), 'Your streak is now 1 day.');
  });

  test('day counts on the progress card', () {
    expect(ar.daysCount(31, d(31)), '٣١ يوماً');
    expect(ar.daysUnit(10), 'أيام');
    expect(ar.daysUnit(1), 'يوم');
    expect(en.daysUnit(1), 'day');
  });
}
