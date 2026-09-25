import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import 'numerals.dart';

/// "قبل ٣ دقائق" / "3 min ago" for the sync card and «قبل ٥ د» in the inbox.
///
/// Pure: [now] comes from clockProvider, never DateTime.now(). Within the
/// last minute reads «الآن»; up to a day, minutes then hours; the previous
/// calendar day «أمس»; anything older is a date, «٢٠ سبتمبر».
String formatRelative(
  L l,
  DateTime at,
  DateTime now,
  String languageCode, {
  bool short = false,
}) {
  final diff = now.difference(at);
  if (diff.inMinutes < 1) return l.nowLabel;
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    final digits = localizeDigits(m, languageCode);
    return short && m > 2 ? l.minutesAgoShort(digits) : l.minutesAgo(m, digits);
  }
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(at.year, at.month, at.day);
  if (diff.inHours < 24 && day == today) {
    final h = diff.inHours;
    return l.hoursAgo(h, localizeDigits(h, languageCode));
  }
  if (today.difference(day).inDays == 1) return l.yesterday;
  return formatDayMonth(at, languageCode);
}

/// «٢٤ سبتمبر» / "24 Sep". Adds the year when it is not [now]'s.
String formatDayMonth(DateTime at, String languageCode, {DateTime? now}) {
  final pattern = languageCode == 'ar' ? 'd MMMM' : 'd MMM';
  final withYear = now != null && now.year != at.year;
  final text = DateFormat(
    withYear ? '$pattern y' : pattern,
    languageCode,
  ).format(at);
  return localizeDigits(text, languageCode);
}
