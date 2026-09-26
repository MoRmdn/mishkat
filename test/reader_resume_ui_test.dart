import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:mishkat/core/l10n/app_localizations.dart';
import 'package:mishkat/core/theme/mishkat_tokens.dart';
import 'package:mishkat/data/local/app_database.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/data/repositories/athkar_repository.dart';
import 'package:mishkat/data/repositories/progress_providers.dart';
import 'package:mishkat/features/reader/reader_controller.dart';
import 'package:mishkat/features/reader/reader_screen.dart';
import 'package:mishkat/features/settings/settings_controller.dart';

import 'support/app_harness.dart';
import 'golden/font_loader.dart';

void main() {
  setUpAll(loadAppFonts);
  late AppDatabase db;
  late SharedPreferences prefs;
  late ProviderContainer container;
  late FakeWakelock wakelock;
  final items = [
    const Thikr(
      id: 'a',
      category: ThikrCategory.morning,
      text: 'ذكر أول',
      count: 3,
      sourceId: 'muslim',
      reference: 1,
      meaningEn: 'First',
    ),
    const Thikr(
      id: 'b',
      category: ThikrCategory.morning,
      text: 'ذكر ثان',
      count: 5,
      sourceId: 'muslim',
      reference: 1,
      meaningEn: 'Second',
    ),
  ];
  final library = AthkarLibrary(
    sources: {
      'muslim': const ThikrSource(id: 'muslim', ar: 'مسلم', en: 'Muslim'),
    },
    byCategory: {ThikrCategory.morning: items},
  );

  void newContainer() {
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
        athkarLibraryProvider.overrideWith((_) => library),
      ],
    );
  }

  Future<void> cleanup(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(
      container.read(readerControllerProvider.notifier).flush,
    );
    container.dispose();
    await tester.runAsync(db.close);
  }

  Future<void> showApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          supportedLocales: L.supportedLocales,
          localizationsDelegates: L.localizationsDelegates,
          theme: buildMishkatTheme(Brightness.light),
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () =>
                      openReader(context, ref, ThikrCategory.morning, items),
                  child: const Text('Open reader'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await AppHarness.settleWithDatabase(tester);
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('Open reader'));
    await AppHarness.settleWithDatabase(tester);
  }

  setUp(() async {
    db = AppDatabase.memory();
    SharedPreferences.setMockInitialValues({'settings.language': 'en'});
    prefs = await SharedPreferences.getInstance();
    wakelock = FakeWakelock();
    wakelockPlusPlatformInstance = wakelock;
    newContainer();
  });

  testWidgets('a recreated app resumes the saved index and count', (
    tester,
  ) async {
    try {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await showApp(tester);
      await open(tester);
      final controller = container.read(readerControllerProvider.notifier);
      controller.advance(items);
      controller.countOne(items);
      await tester.runAsync(controller.flush);
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      newContainer();
      await showApp(tester);
      await open(tester);
      expect(find.text('2 of 2'), findsOneWidget);
      expect(container.read(readerControllerProvider).remaining['b'], 4);
      expect(wakelock.isOn, isTrue);
    } finally {
      await cleanup(tester);
    }
  });

  testWidgets(
    'system Back cancels auto-advance but preserves a resumable checkpoint',
    (tester) async {
      try {
        await showApp(tester);
        await open(tester);
        final controller = container.read(readerControllerProvider.notifier);
        controller.countOne(items);
        controller.countOne(items);
        controller.countOne(items);
        await tester.binding.handlePopRoute();
        await AppHarness.settleWithDatabase(tester);
        expect(container.read(readerControllerProvider).session, isNull);
        expect(wakelock.isOn, isFalse);
        await open(tester);
        await tester.pump(kAutoAdvanceDelay + const Duration(milliseconds: 50));
        await AppHarness.settleWithDatabase(tester);
        expect(container.read(readerControllerProvider).session!.index, 1);
      } finally {
        await cleanup(tester);
      }
    },
  );

  testWidgets('Start again requires confirmation and resets the routine', (
    tester,
  ) async {
    try {
      await showApp(tester);
      await open(tester);
      final controller = container.read(readerControllerProvider.notifier);
      controller.countOne(items);
      // Start again lives in the header's overflow menu (board AF 7).
      await tester.tap(find.bySemanticsLabel('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start again'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start again').last);
      await AppHarness.settleWithDatabase(tester);
      expect(container.read(readerControllerProvider).remaining['a'], 3);
      expect(container.read(readerControllerProvider).session!.index, 0);
    } finally {
      await cleanup(tester);
    }
  });
}
