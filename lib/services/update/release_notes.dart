import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/mishkat_icon.dart';
import 'app_version.dart';

/// One line of «ما الجديد»: a glyph and the same sentence in both languages.
class ReleaseNote {
  const ReleaseNote({required this.icon, required this.ar, required this.en});

  final MIcon icon;
  final String ar;
  final String en;

  String text(String languageCode) => languageCode == 'ar' ? ar : en;

  static final _icons = MIcon.values.asNameMap();

  /// `{"icon": "bell", "ar": "…", "en": "…"}`. An icon name the build does
  /// not know — one added to a later release — falls back to ⓘ.
  static ReleaseNote? fromJson(Object? json) {
    if (json is! Map) return null;
    final ar = json['ar'], en = json['en'];
    if (ar is! String || en is! String || ar.isEmpty || en.isEmpty) {
      return null;
    }
    return ReleaseNote(
      icon: _icons[json['icon']] ?? MIcon.info,
      ar: ar,
      en: en,
    );
  }
}

/// What one version brought.
class Release {
  const Release({required this.version, required this.notes});

  final AppVersion version;
  final List<ReleaseNote> notes;

  /// `{"version": "1.3.0", "notes": [ReleaseNote, …]}`. The same shape in the
  /// bundled changelog and in Remote Config's `release_notes`.
  static Release? fromJson(Object? json) {
    if (json is! Map) return null;
    final version = AppVersion.tryParse(json['version'] as String?);
    final raw = json['notes'];
    if (version == null || raw is! List) return null;
    final notes = [for (final n in raw) ?ReleaseNote.fromJson(n)];
    if (notes.isEmpty) return null;
    return Release(version: version, notes: notes);
  }

  /// Remote Config's string value; null when unset or malformed.
  static Release? tryDecode(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      return fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }
}

/// The bundled changelog, newest first. `test/changelog_test.dart` checks
/// that it names the pubspec version and that every note has both languages.
class Changelog {
  const Changelog(this.releases);

  static const assetPath = 'assets/data/changelog.json';

  final List<Release> releases;

  static Changelog decode(String raw) {
    final json = jsonDecode(raw) as Map<String, Object?>;
    return Changelog([
      for (final r in json['releases'] as List) ?Release.fromJson(r),
    ]);
  }

  Release? release(AppVersion version) {
    for (final r in releases) {
      if (r.version == version) return r;
    }
    return null;
  }

  /// Everything released after [lastSeen] up to [installed], newest first:
  /// a user who skipped a version sees what it brought too.
  List<Release> since(AppVersion lastSeen, AppVersion installed) => [
    for (final r in releases)
      if (r.version > lastSeen && r.version <= installed) r,
  ];
}

final changelogProvider = FutureProvider<Changelog>(
  (ref) async =>
      Changelog.decode(await rootBundle.loadString(Changelog.assetPath)),
);
