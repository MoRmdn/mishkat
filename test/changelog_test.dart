import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/services/update/app_version.dart';
import 'package:mishkat/services/update/release_notes.dart';

/// The bundled «ما الجديد». A release shipped without its entry would
/// announce an update with nothing to show for it.
void main() {
  final raw = File(Changelog.assetPath).readAsStringSync();
  final changelog = Changelog.decode(raw);

  test('every entry parses: a version, and notes in both languages', () {
    final entries = (RegExp(r'"version"').allMatches(raw)).length;
    expect(changelog.releases, hasLength(entries));
    for (final release in changelog.releases) {
      expect(release.notes, isNotEmpty, reason: '${release.version}');
      for (final note in release.notes) {
        expect(note.ar.trim(), isNotEmpty);
        expect(note.en.trim(), isNotEmpty);
      }
    }
  });

  test('icons are ones this build draws', () {
    final names = RegExp(
      r'"icon":\s*"([^"]+)"',
    ).allMatches(raw).map((m) => m[1]).toSet();
    final known = {
      for (final r in changelog.releases) ...r.notes.map((n) => n.icon.name),
    };
    expect(names, known, reason: 'an unknown icon name falls back to ⓘ');
  });

  test('newest first, no version twice', () {
    final versions = changelog.releases.map((r) => r.version).toList();
    expect(versions.toSet(), hasLength(versions.length));
    for (var i = 1; i < versions.length; i++) {
      expect(versions[i - 1] > versions[i], isTrue);
    }
  });

  test('names the version in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final line = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!;
    final version = AppVersion.parse(line[1]!);
    expect(
      changelog.release(version),
      isNotNull,
      reason: 'add $version to ${Changelog.assetPath}',
    );
  });
}
