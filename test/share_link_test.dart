import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/share_link.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/athkar_repository.dart';

void main() {
  late AthkarLibrary library;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    library = await AthkarRepository().load();
  });

  test('a thikr link is https on the share host', () {
    final link = thikrLink(library.byId('mo1')!);
    expect(link.toString(), 'https://mishkatalwird.com/t/mo1');
  });

  test('every thikr id round-trips through its link', () {
    for (final thikr in library.all) {
      expect(thikrIdFromLink(thikrLink(thikr)), thikr.id, reason: thikr.id);
    }
  });

  test('a trailing slash and host case are tolerated', () {
    expect(
      thikrIdFromLink(Uri.parse('https://mishkatalwird.com/t/ev2/')),
      'ev2',
    );
    expect(
      thikrIdFromLink(Uri.parse('https://MishkatAlWird.com/t/ev2')),
      'ev2',
    );
  });

  test('anything that is not a thikr link is refused', () {
    for (final link in [
      'http://mishkatalwird.com/t/mo1',
      'https://www.mishkatalwird.com/t/mo1',
      'https://example.com/t/mo1',
      'https://mishkatalwird.com/',
      'https://mishkatalwird.com/t/',
      'https://mishkatalwird.com/t/mo1/extra',
      'https://mishkatalwird.com/x/mo1',
      'mishkat://t/mo1',
    ]) {
      expect(thikrIdFromLink(Uri.parse(link)), isNull, reason: link);
    }
  });

  test('policy pages are Arabic at the root and English under /en', () {
    expect(
      legalPage(LegalPage.privacy, 'ar').toString(),
      'https://mishkatalwird.com/privacy',
    );
    expect(
      legalPage(LegalPage.terms, 'en').toString(),
      'https://mishkatalwird.com/en/terms',
    );
  });

  test('every policy page the app links to exists on the site', () {
    for (final page in LegalPage.values) {
      for (final lang in ['ar', 'en']) {
        final path = legalPage(page, lang).path;
        expect(
          File('share_site/public$path.html').existsSync(),
          isTrue,
          reason: path,
        );
      }
    }
  });

  // The host is written in four places that no compiler connects.
  test('the native claims and the site agree on the host', () {
    final entitlements = File(
      'ios/Runner/Runner.entitlements',
    ).readAsStringSync();
    expect(entitlements, contains('applinks:$kShareLinkHost<'));

    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:host="$kShareLinkHost"'));

    final aasa = jsonDecode(
      File(
        'share_site/public/.well-known/apple-app-site-association',
      ).readAsStringSync(),
    );
    final details = (aasa['applinks']['details'] as List).single;
    expect(details['appIDs'], ['64WR7QH47B.com.mormdn.mishkat']);

    final assetLinks =
        jsonDecode(
              File(
                'share_site/public/.well-known/assetlinks.json',
              ).readAsStringSync(),
            )
            as List;
    expect(assetLinks.single['target']['package_name'], 'com.mormdn.mishkat');
  });
}
