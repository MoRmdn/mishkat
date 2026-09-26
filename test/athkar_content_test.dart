import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/athkar_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AthkarLibrary library;

  setUpAll(() async {
    library = await AthkarRepository().load();
  });

  test('every category is present and non-empty', () {
    for (final c in ThikrCategory.values) {
      expect(library[c], isNotEmpty, reason: c.key);
    }
  });

  test('the content version is the edition the review document describes', () {
    // A wrong-thikr report carries this, so the reviewer can tell which text
    // the reporter was reading.
    final review = File('docs/athkar-content-review.md').readAsStringSync();
    expect(library.contentVersion, isNotNull);
    expect(review, contains('Draft version: `${library.contentVersion}`'));
  });

  test('thikr ids are unique across the whole corpus', () {
    final ids = library.all.map((t) => t.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every thikr has Arabic text, a positive count and a meaning', () {
    for (final t in library.all) {
      expect(t.text.trim(), isNotEmpty, reason: t.id);
      expect(t.count, greaterThan(0), reason: t.id);
      expect(t.meaningEn.trim(), isNotEmpty, reason: t.id);
      // The text must actually be Arabic script, not a transliteration.
      expect(
        RegExp(r'[؀-ۿ]').hasMatch(t.text),
        isTrue,
        reason: '${t.id} is not Arabic script',
      );
    }
  });

  test('every source reference resolves', () {
    for (final t in library.all) {
      expect(library.sources.containsKey(t.sourceId), isTrue, reason: t.id);
      expect(t.reference, greaterThan(0), reason: t.id);
    }
  });

  test('reference lines are localized in both languages', () {
    final thikr = library[ThikrCategory.morning].first;
    final ar = library.referenceLine(thikr, 'ar');
    final en = library.referenceLine(thikr, 'en');

    expect(ar, contains('رواه'));
    expect(
      ar,
      isNot(matches(RegExp(r'[0-9]'))),
      reason: 'ar uses Arabic-Indic',
    );
    expect(en, matches(RegExp(r'\d')));
  });

  test('virtues, where present, exist in both languages', () {
    final withVirtue = library.all.where((t) => t.hasVirtue);
    expect(withVirtue, isNotEmpty);
    for (final t in withVirtue) {
      expect(t.virtue('ar'), isNotNull);
      expect(t.virtue('en'), isNotNull);
      expect(t.virtue('ar')!.trim(), isNotEmpty);
      expect(t.virtue('en')!.trim(), isNotEmpty);
    }
  });

  test('byId finds a thikr and returns null for an unknown one', () {
    expect(library.byId('mo1'), isNotNull);
    expect(library.byId('nope'), isNull);
  });

  test('tasbih is the only non-session category', () {
    for (final c in ThikrCategory.values) {
      expect(c.isCountedSession, c != ThikrCategory.tasbih, reason: c.key);
    }
    expect(ThikrCategory.homeGrid, isNot(contains(ThikrCategory.tasbih)));
  });

  test('the corpus is still flagged as placeholder content', () async {
    // Guards against shipping unverified تخريج. Whoever replaces this with a
    // human-reviewed dataset must drop the marker deliberately, which fails
    // this test and forces the decision to be noticed.
    final raw =
        json.decode(await rootBundle.loadString('assets/data/athkar.json'))
            as Map<String, dynamic>;

    expect(
      raw['_warning'],
      contains('PLACEHOLDER'),
      reason:
          'content has been replaced — confirm the تخريج was verified, '
          'then delete this test',
    );
  });
}
