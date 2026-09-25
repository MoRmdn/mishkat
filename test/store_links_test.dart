import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/store_links.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';

import 'support/app_harness.dart';

void main() {
  setUpAll(AppHarness.loadLibrary);

  test('until the App Store ID exists, release builds hide the row', () {
    expect(kStoreLinksReady, kAppStoreId.isNotEmpty);
    // Tests run in debug, where the row shows with a placeholder link.
    expect(kShowRateApp, isTrue);
    if (!kStoreLinksReady) {
      expect(
        rateAppUri(TargetPlatform.iOS),
        Uri.parse('https://mishkatalwird.com/'),
      );
    } else {
      expect(
        rateAppUri(TargetPlatform.iOS).toString(),
        contains('action=write-review'),
      );
      expect(
        rateAppUri(TargetPlatform.android).queryParameters['id'],
        kPlayPackage,
      );
    }
  });

  testWidgets('«قيّم التطبيق» opens the store page', (tester) async {
    final h = AppHarness();
    await h.pump(tester, language: 'en');
    await tester.tap(findIcon(MIcon.settings));
    await AppHarness.settleWithDatabase(tester);

    final row = find.text('Rate the app');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(h.openedPages, [rateAppUri(defaultTargetPlatform)]);
  });
}
