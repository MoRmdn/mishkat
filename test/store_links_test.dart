import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/store_links.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';

import 'support/app_harness.dart';

void main() {
  setUpAll(AppHarness.loadLibrary);

  test('the links point at the live listings', () {
    expect(
      rateAppUri(TargetPlatform.iOS),
      Uri.parse('https://apps.apple.com/app/id6815677954?action=write-review'),
    );
    expect(
      rateAppUri(TargetPlatform.android),
      Uri.parse(
        'https://play.google.com/store/apps/details?id=com.mormdn.mishkat',
      ),
    );
  });

  testWidgets('«قيّم التطبيق» opens the store page', (tester) async {
    final h = AppHarness();
    await h.pump(tester, language: 'en');
    await tester.tap(findIcon(MIcon.settings));
    await AppHarness.settleWithDatabase(tester);

    await tester.ensureVisible(find.text('About'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    final row = find.text('Rate the app');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(h.openedPages, [rateAppUri(defaultTargetPlatform)]);
  });
}
