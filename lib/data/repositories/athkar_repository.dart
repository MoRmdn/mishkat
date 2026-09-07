import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/thikr.dart';

/// Loads the bundled athkar corpus.
///
/// The content ships with the app rather than being fetched — the app must work
/// with no network at all.
class AthkarRepository {
  AthkarRepository({this.assetPath = 'assets/data/athkar.json'});

  final String assetPath;
  AthkarLibrary? _cache;

  Future<AthkarLibrary> load() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(assetPath);
    final library = AthkarLibrary.fromJson(
      json.decode(raw) as Map<String, dynamic>,
    );
    return _cache = library;
  }
}

final athkarRepositoryProvider = Provider((ref) => AthkarRepository());

final athkarLibraryProvider = FutureProvider<AthkarLibrary>(
  (ref) => ref.watch(athkarRepositoryProvider).load(),
);
