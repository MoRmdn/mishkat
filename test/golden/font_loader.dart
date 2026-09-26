import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the app's bundled fonts into the test binding.
///
/// Without this, golden files render in the test fallback font and prove
/// nothing about Arabic shaping — which is most of what these goldens exist
/// to protect.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> load(String family, List<String> assets) async {
    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }

  await load('Alexandria', [
    'assets/fonts/Alexandria-Light.ttf',
    'assets/fonts/Alexandria-Regular.ttf',
    'assets/fonts/Alexandria-Medium.ttf',
  ]);
  await load('Scheherazade New', [
    'assets/fonts/ScheherazadeNew-Regular.ttf',
    'assets/fonts/ScheherazadeNew-Medium.ttf',
  ]);
  await load('Amiri Quran', ['assets/fonts/AmiriQuran-Regular.ttf']);
}
