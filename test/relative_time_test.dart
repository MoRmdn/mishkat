import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mishkat/core/format/relative_time.dart';
import 'package:mishkat/core/l10n/app_localizations.dart';

void main() {
  late L ar, en;
  final now = DateTime(2026, 9, 25, 9, 41);

  setUpAll(() async {
    await initializeDateFormatting();
    ar = await L.delegate.load(const Locale('ar'));
    en = await L.delegate.load(const Locale('en'));
  });

  String rAr(Duration ago, {bool short = false}) =>
      formatRelative(ar, now.subtract(ago), now, 'ar', short: short);
  String rEn(Duration ago) => formatRelative(en, now.subtract(ago), now, 'en');

  test('under a minute is now', () {
    expect(rAr(const Duration(seconds: 20)), 'الآن');
  });

  test('minutes agree in number and use Arabic-Indic digits', () {
    expect(rAr(const Duration(minutes: 1)), 'قبل دقيقة');
    expect(rAr(const Duration(minutes: 2)), 'قبل دقيقتين');
    expect(rAr(const Duration(minutes: 3)), 'قبل ٣ دقائق');
    expect(rAr(const Duration(minutes: 11)), 'قبل ١١ دقيقة');
    expect(rEn(const Duration(minutes: 3)), '3 min ago');
    expect(rEn(const Duration(minutes: 1)), '1 min ago');
  });

  test('the inbox uses the short form', () {
    expect(rAr(const Duration(minutes: 5), short: true), 'قبل ٥ د');
  });

  test('hours, then yesterday, then a date', () {
    expect(rAr(const Duration(hours: 1)), 'قبل ساعة');
    expect(rAr(const Duration(hours: 3)), 'قبل ٣ ساعات');
    expect(rEn(const Duration(hours: 2)), '2 hours ago');
    expect(rAr(const Duration(hours: 20)), 'أمس');
    expect(
      formatRelative(ar, DateTime(2026, 9, 20, 18), now, 'ar'),
      '٢٠ سبتمبر',
    );
    expect(formatRelative(en, DateTime(2026, 9, 20, 18), now, 'en'), '20 Sep');
  });
}
