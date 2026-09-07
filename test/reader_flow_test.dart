import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/app.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:mishkat/features/reader/reader_controller.dart';
import 'package:mishkat/features/reader/reader_screen.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/athkar_repository.dart';
import 'package:mishkat/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

/// The reader keeps the screen on; in tests there is no platform to ask.
class _FakeWakelock extends WakelockPlusPlatformInterface
    with MockPlatformInterfaceMixin {
  bool isEnabled = false;

  @override
  Future<void> toggle({required bool enable}) async => isEnabled = enable;

  @override
  Future<bool> get enabled async => isEnabled;
}

late AthkarLibrary library;

Future<void> pumpApp(WidgetTester tester, {String language = 'ar'}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  // Dispose the tree while this test's wakelock fake is still installed;
  // otherwise a reader left open disposes during the *next* test and its
  // release lands on that test's fake.
  addTearDown(() => tester.pumpWidget(const SizedBox.shrink()));

  SharedPreferences.setMockInitialValues({
    'flutter.settings.language': language,
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        // Preloaded so the widget tree has data on the first frame; otherwise
        // pumpAndSettle races the asset read and settles on an empty screen.
        athkarLibraryProvider.overrideWith((ref) => library),
      ],
      child: const MishkatApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeWakelock wakelock;

  setUpAll(() async => library = await AthkarRepository().load());

  setUp(() {
    wakelock = _FakeWakelock();
    // WakelockPlus caches the platform object in a top-level variable that is
    // initialized on first read, so overriding
    // WakelockPlusPlatformInterface.instance alone only works for whichever
    // test happens to run first. This is the hook the package exposes for it.
    wakelockPlusPlatformInstance = wakelock;
  });

  testWidgets('home lists the athkar categories and the tasbih', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('التذكير القادم'), findsOneWidget);
    expect(find.text('أذكار الصباح'), findsWidgets);
    expect(find.text('أذكار المساء'), findsOneWidget);
    expect(find.text('أذكار بعد الصلاة'), findsOneWidget);

    // The tasbih card sits below the grid.
    await tester.scrollUntilVisible(find.text('السبحة'), 200);
    expect(find.text('السبحة'), findsOneWidget);
  });

  testWidgets('opening a category starts a reading session', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('أذكار المساء'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsOneWidget);
    // Evening has four athkar; the first opens at position 1.
    expect(find.text('١ من ٤'), findsOneWidget);
    expect(wakelock.isEnabled, isTrue, reason: 'screen should stay awake');
  });

  testWidgets('tapping the reader counts down', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('أذكار المساء'));
    await tester.pumpAndSettle();

    // First evening thikr is said once; the second three times.
    expect(find.text('١'), findsWidgets);

    await tester.tap(find.byType(ReaderScreen));
    await tester.pump();
    await tester.pump(kAutoAdvanceDelay + const Duration(milliseconds: 60));
    await tester.pumpAndSettle();

    expect(find.text('٢ من ٤'), findsOneWidget);
    expect(
      find.text('٣'),
      findsWidgets,
      reason: 'second thikr is said 3 times',
    );
  });

  testWidgets('English shows the meaning under the Arabic', (tester) async {
    await pumpApp(tester, language: 'en');

    await tester.tap(find.text('Evening'));
    await tester.pumpAndSettle();

    expect(find.text('1 of 4'), findsOneWidget);
    expect(
      find.textContaining('We have entered a new evening'),
      findsOneWidget,
    );
  });

  testWidgets('Arabic mode does not show the English meaning', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('أذكار المساء'));
    await tester.pumpAndSettle();

    expect(find.textContaining('We have entered a new evening'), findsNothing);
  });

  testWidgets('closing the reader releases the wakelock', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('أذكار المساء'));
    await tester.pumpAndSettle();
    expect(wakelock.isEnabled, isTrue);

    await tester.tap(find.bySemanticsLabel('close'));
    await tester.pumpAndSettle();

    expect(find.byType(ReaderScreen), findsNothing);
    expect(wakelock.isEnabled, isFalse);
  });
}
