import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/features/reader/reader_screen.dart';

import 'support/app_harness.dart';

void main() {
  late AppHarness harness;

  setUpAll(AppHarness.loadLibrary);
  setUp(() => harness = AppHarness());

  testWidgets('a link that launched the app opens its thikr', (tester) async {
    harness.launchLinks = [Uri.parse('https://mishkatalwird.com/t/ev2')];
    await harness.pump(tester);

    expect(find.byType(ReaderScreen), findsOneWidget);
    // Just the shared thikr, not the whole evening routine.
    expect(find.text('١ من ١'), findsOneWidget);
    final ev2 = AppHarness.library.byId('ev2')!;
    expect(
      find.textContaining(ev2.text.split(' ').take(3).join(' ')),
      findsWidgets,
    );
  });

  testWidgets('a link tapped while the app runs opens its thikr', (
    tester,
  ) async {
    await harness.pump(tester);
    expect(find.byType(ReaderScreen), findsNothing);

    harness.links.add(Uri.parse('https://mishkatalwird.com/t/sl1'));
    await AppHarness.settleWithDatabase(tester);

    expect(find.byType(ReaderScreen), findsOneWidget);
    expect(find.text('١ من ١'), findsOneWidget);
  });

  testWidgets('an unknown id leaves the user on home', (tester) async {
    harness.launchLinks = [Uri.parse('https://mishkatalwird.com/t/zz9')];
    await harness.pump(tester);
    expect(find.byType(ReaderScreen), findsNothing);
  });

  testWidgets('a link does not skip onboarding', (tester) async {
    harness.launchLinks = [Uri.parse('https://mishkatalwird.com/t/mo1')];
    await harness.pump(tester, onboardingComplete: false);
    expect(find.byType(ReaderScreen), findsNothing);
  });

  testWidgets('settings opens the policy pages in the reader\'s language', (
    tester,
  ) async {
    await harness.pump(tester);
    await tester.tap(findIcon(MIcon.settings));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('سياسة الخصوصية'));
    await tester.tap(find.text('سياسة الخصوصية'));
    await tester.ensureVisible(find.text('الشروط والأحكام'));
    await tester.tap(find.text('الشروط والأحكام'));
    expect(harness.openedPages.map((u) => u.toString()), [
      'https://mishkatalwird.com/privacy',
      'https://mishkatalwird.com/terms',
    ]);
  });

  testWidgets('English settings open the English pages', (tester) async {
    await harness.pump(tester, language: 'en');
    await tester.tap(findIcon(MIcon.settings));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Terms of use'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terms of use'));
    expect(
      harness.openedPages.single.toString(),
      'https://mishkatalwird.com/en/terms',
    );
  });
}
