import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/features/reminders/prayer_panel.dart';

import 'support/app_harness.dart';

/// Scrolls a row fully into view before tapping it.
///
/// scrollUntilVisible only guarantees the widget is built; a row can still sit
/// under the nav bar, where the tap offset misses it entirely.
Future<void> tapRow(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  /// Starts in prayer mode with a manual city, so no platform location is
  /// needed to have real times on screen.
  Future<void> openPrayerMode(
    WidgetTester tester, {
    String city = 'makkah',
    String language = 'ar',
  }) async {
    await harness.pump(
      tester,
      language: language,
      extraPrefs: {
        'reminders.mode': 'prayer',
        'prayer.useDeviceLocation': false,
        'prayer.manualCity': city,
      },
    );
    await tester.tap(
      find.text(language == 'ar' ? 'التذكيرات' : 'Reminders').last,
    );
    await tester.pumpAndSettle();
    // The panel sits below the slot list, and the tab is a lazy ListView, so
    // it is not built until scrolled into range.
    await tester.scrollUntilVisible(
      find.text(language == 'ar' ? 'الفجر' : 'Fajr'),
      200,
    );
  }

  testWidgets('prayer mode shows today\'s computed times', (tester) async {
    await openPrayerMode(tester);

    expect(find.byType(PrayerTimesCard), findsOneWidget);
    expect(find.text('الفجر'), findsOneWidget);
    expect(find.text('العصر'), findsOneWidget);
    expect(find.text('المغرب'), findsOneWidget);
    // The fallback notice must be gone now that times exist.
    expect(
      find.text('تعذّر حساب المواقيت — تُستخدم الأوقات الثابتة مؤقتاً'),
      findsNothing,
    );
  });

  testWidgets('the window indicator reports the real pending count', (
    tester,
  ) async {
    await openPrayerMode(tester);
    final window = find.textContaining('مجدولة حتى');
    await tester.scrollUntilVisible(window, 200);

    // Three anchored slots across 14 days, plus nothing repeating (sleep off),
    // against the iOS cap.
    final line = tester.widget<Text>(window).data!;
    expect(line, contains('٤٢ من ٦٤'));
  });

  testWidgets('changing the calculation method changes the times', (
    tester,
  ) async {
    await openPrayerMode(tester);
    await tester.scrollUntilVisible(find.text('أم القرى'), 200);

    final before = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();

    await tapRow(tester, find.text('أم القرى'));

    expect(find.text('رابطة العالم الإسلامي'), findsOneWidget);
    final after = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .toList();
    expect(after, isNot(equals(before)));
  });

  testWidgets('the madhab toggles between the two options', (tester) async {
    await openPrayerMode(tester);

    await tapRow(tester, find.text('الجمهور'));
    expect(find.text('الحنفي'), findsOneWidget);

    await tapRow(tester, find.text('الحنفي'));
    expect(find.text('الجمهور'), findsOneWidget);
  });

  testWidgets('the city picker changes the location and reschedules', (
    tester,
  ) async {
    await openPrayerMode(tester);
    // The place sits in the header of today's times.
    expect(find.text('مكة المكرمة · يدوي'), findsOneWidget);

    final before = harness.notifications.applied.last.entries.first.at;

    await tapRow(tester, find.text('مكة المكرمة · يدوي'));
    expect(find.byType(CityPickerSheet), findsOneWidget);

    await tester.tap(find.text('القاهرة'));
    await tester.pumpAndSettle();

    expect(find.text('القاهرة · يدوي'), findsOneWidget);
    expect(
      harness.notifications.applied.last.entries.first.at,
      isNot(before),
      reason: 'a different city means different prayer times',
    );
  });

  testWidgets('prayer settings survive a restart', (tester) async {
    await openPrayerMode(tester);
    await tapRow(tester, find.text('الجمهور'));

    await harness.pump(tester, resetPrefs: false);
    await tester.tap(find.text('التذكيرات').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('الحنفي'), 200);

    expect(find.text('الحنفي'), findsOneWidget);
  });

  testWidgets('English shows the city and times in Latin numerals', (
    tester,
  ) async {
    await openPrayerMode(tester, city: 'london', language: 'en');
    expect(find.text('London · manual'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
  });

  testWidgets('the scheduled-through date uses Arabic-Indic digits', (
    tester,
  ) async {
    await openPrayerMode(tester);

    // The rest of the sentence is Arabic-Indic; a Latin "20" would read as a
    // formatting bug in the middle of Arabic text.
    final line = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .firstWhere((s) => s.startsWith('مجدولة حتى'));
    expect(line, isNot(matches(RegExp(r'[0-9]'))), reason: line);
  });

  testWidgets('the window sentence appears once, not twice', (tester) async {
    await openPrayerMode(tester);
    await tester.scrollUntilVisible(find.textContaining('مجدولة حتى'), 200);

    final windowLines = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .whereType<String>()
        .where((s) => s.startsWith('مجدولة حتى'))
        .toList();
    expect(windowLines, hasLength(1));
  });

  testWidgets('fixed mode hides the panel entirely', (tester) async {
    await harness.pump(tester);
    await tester.tap(find.text('التذكيرات').last);
    await tester.pumpAndSettle();

    expect(find.byType(PrayerTimesCard), findsNothing);
  });
}
