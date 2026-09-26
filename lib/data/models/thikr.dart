import 'package:flutter/foundation.dart';

import '../../core/format/numerals.dart';

/// The seven athkar groupings in the design.
///
/// [tasbih] is a free counter rather than a reading session: it holds a single
/// repeated thikr and never completes a daily session.
enum ThikrCategory {
  morning('morning'),
  evening('evening'),
  sleep('sleep'),
  wake('wake'),
  afterPrayer('after_prayer'),
  misc('misc'),
  tasbih('tasbih');

  const ThikrCategory(this.key);

  /// The key used in `assets/data/athkar.json`.
  final String key;

  static ThikrCategory fromKey(String key) =>
      ThikrCategory.values.firstWhere((c) => c.key == key);

  /// Categories shown as cards on the home grid, in design order.
  static const List<ThikrCategory> homeGrid = [
    ThikrCategory.morning,
    ThikrCategory.evening,
    ThikrCategory.sleep,
    ThikrCategory.wake,
    ThikrCategory.afterPrayer,
    ThikrCategory.misc,
  ];

  bool get isCountedSession => this != ThikrCategory.tasbih;
}

/// A hadith collection, with its name in both languages.
@immutable
class ThikrSource {
  const ThikrSource({required this.id, required this.ar, required this.en});

  factory ThikrSource.fromJson(String id, Map<String, dynamic> json) =>
      ThikrSource(id: id, ar: json['ar'] as String, en: json['en'] as String);

  final String id, ar, en;

  String label(String languageCode) => languageCode == 'ar' ? ar : en;
}

@immutable
class Thikr {
  const Thikr({
    required this.id,
    required this.category,
    required this.text,
    required this.count,
    required this.sourceId,
    required this.reference,
    required this.meaningEn,
    this.virtueAr,
    this.virtueEn,
  });

  factory Thikr.fromJson(ThikrCategory category, Map<String, dynamic> json) {
    final virtue = json['virtue'] as Map<String, dynamic>?;
    return Thikr(
      id: json['id'] as String,
      category: category,
      text: json['text'] as String,
      count: json['count'] as int,
      sourceId: json['source'] as String,
      reference: json['reference'] as int,
      meaningEn: json['meaningEn'] as String,
      virtueAr: virtue?['ar'] as String?,
      virtueEn: virtue?['en'] as String?,
    );
  }

  final String id;
  final ThikrCategory category;

  /// The Arabic text. Never replaced by a translation — in English the meaning
  /// is shown *underneath* it.
  final String text;

  /// How many times it is said.
  final int count;

  final String sourceId;

  /// Hadith number within [sourceId].
  final int reference;

  final String meaningEn;
  final String? virtueAr, virtueEn;

  bool get hasVirtue => virtueAr != null;

  String? virtue(String languageCode) =>
      languageCode == 'ar' ? virtueAr : virtueEn;
}

/// The whole bundled corpus, held in memory — it is a few dozen short records.
@immutable
class AthkarLibrary {
  const AthkarLibrary({
    required this.sources,
    required this.byCategory,
    this.contentVersion,
  });

  factory AthkarLibrary.fromJson(Map<String, dynamic> json) {
    final sources = (json['sources'] as Map<String, dynamic>).map(
      (id, v) =>
          MapEntry(id, ThikrSource.fromJson(id, v as Map<String, dynamic>)),
    );

    final byCategory = <ThikrCategory, List<Thikr>>{};
    (json['categories'] as Map<String, dynamic>).forEach((key, list) {
      final category = ThikrCategory.fromKey(key);
      byCategory[category] = [
        for (final item in list as List)
          Thikr.fromJson(category, item as Map<String, dynamic>),
      ];
    });

    return AthkarLibrary(
      sources: sources,
      byCategory: byCategory,
      contentVersion: json['contentVersion'] as String?,
    );
  }

  final Map<String, ThikrSource> sources;

  /// The edition of athkar.json, attached to a wrong-thikr report so the
  /// reviewer knows which text the reporter was reading.
  final String? contentVersion;
  final Map<ThikrCategory, List<Thikr>> byCategory;

  List<Thikr> operator [](ThikrCategory c) => byCategory[c] ?? const [];

  Iterable<Thikr> get all => byCategory.values.expand((l) => l);

  Thikr? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// `رواه مسلم ٢٧٢٣` / `Muslim 2723`.
  String referenceLine(Thikr thikr, String languageCode) {
    final source = sources[thikr.sourceId];
    if (source == null) return '';
    return '${source.label(languageCode)} '
        '${localizeDigits(thikr.reference, languageCode)}';
  }
}
