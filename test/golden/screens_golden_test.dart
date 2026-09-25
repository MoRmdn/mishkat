@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/app.dart';
import 'package:mishkat/core/widgets/buttons.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/features/account/sign_in_sheet.dart';
import 'package:mishkat/data/models/thikr.dart';
import 'package:mishkat/features/share/share_card.dart';
import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/feedback/feedback_models.dart';

import '../support/app_harness.dart';
import 'font_loader.dart';

/// One golden per screen on the 2a design board, at the board's 340×720
/// frame and numbered to match it. Review the PNGs against
/// `assets/mishkat-2a-handoff/screens/` whenever they change.
void main() {
  const board = Size(340, 720);
  final today = DateTime(2026, 9, 7);

  setUpAll(() async {
    await loadAppFonts();
    await AppHarness.loadLibrary();
  });

  Future<void> shot(String name) => expectLater(
    find.byType(MishkatApp),
    matchesGoldenFile('images/$name.png'),
  );

  /// Nine consecutive days of every routine, ending yesterday — the board's
  /// "9-day streak" — plus whatever [todayDone] adds for today.
  Future<AppHarness> withHistory({
    List<String> todayDone = const [],
    int days = 9,
    FakePermissionService? permissions,
    FakeAuthService? auth,
  }) async {
    final h = AppHarness(permissions: permissions, auth: auth);
    for (var i = 1; i <= days; i++) {
      final day = DateTime(today.year, today.month, today.day - i, 7);
      for (final c in ['wake', 'morning', 'evening', 'sleep']) {
        await h.db.recordCompletion(c, day);
      }
    }
    for (final c in todayDone) {
      await h.db.recordCompletion(c, DateTime(2026, 9, 7, 6));
    }
    return h;
  }

  /// Counts by tapping the page, well clear of any button.
  Future<void> countOnce(WidgetTester tester) async {
    await tester.tapAt(const Offset(170, 300));
    await tester.pump(const Duration(milliseconds: 20));
  }

  group('01 onboarding', () {
    testWidgets('1.1 welcome', (tester) async {
      await AppHarness().pump(tester, size: board, onboardingComplete: false);
      await shot('1_1_welcome_ar');
    });

    testWidgets('1.2 notifications', (tester) async {
      await AppHarness().pump(tester, size: board, onboardingComplete: false);
      await tester.tap(find.text('لنبدأ'));
      await tester.pumpAndSettle();
      await shot('1_2_notifications_ar');
    });

    testWidgets('1.4 battery', (tester) async {
      await AppHarness().pump(tester, size: board, onboardingComplete: false);
      await tester.tap(find.text('لنبدأ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ليس الآن'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('المتابعة بدون دقة'));
      await tester.pumpAndSettle();
      await shot('1_4_battery_ar');
    });
  });

  group('02 home', () {
    testWidgets('2.1 routine due, Arabic light', (tester) async {
      // Eight days plus today: the board's nine-day streak.
      final h = await withHistory(todayDone: ['wake'], days: 8);
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 9, 41));
      await shot('2_1_home_light_ar');
    });

    testWidgets('2.2 English dark', (tester) async {
      final h = await withHistory(todayDone: ['wake', 'morning'], days: 8);
      await h.pump(
        tester,
        size: board,
        language: 'en',
        appearance: 'dark',
        now: DateTime(2026, 9, 7, 17, 22),
      );
      await shot('2_2_home_dark_en');
    });

    testWidgets('2.3 all done, notifications off', (tester) async {
      final h = await withHistory(
        todayDone: ['wake', 'morning', 'evening', 'sleep'],
        permissions: FakePermissionService(notifications: false),
      );
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 22, 50));
      await shot('2_3_home_done_ar');
    });

    testWidgets('2.3b zero streak', (tester) async {
      await AppHarness().pump(
        tester,
        size: board,
        now: DateTime(2026, 9, 7, 9, 41),
      );
      await shot('2_3b_home_zero_streak_ar');
    });

    testWidgets('2.4 tasbih', (tester) async {
      await AppHarness().pump(tester, size: board);
      await tester.tap(find.text('السبحة'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 47; i++) {
        await countOnce(tester);
      }
      await tester.pumpAndSettle();
      await shot('2_4_tasbih_ar');
    });
  });

  group('03 reader', () {
    Future<void> next(WidgetTester tester, String label, int times) async {
      for (var i = 0; i < times; i++) {
        await tester.tap(find.bySemanticsLabel(label));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('3.1 Arabic light', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 9, 41));
      await tester.tap(find.text('ابدأ'));
      await AppHarness.settleWithDatabase(tester);
      await next(tester, 'التالي', 2);
      await countOnce(tester);
      await tester.pumpAndSettle();
      await shot('3_1_reader_light_ar');
    });

    testWidgets('3.2 long thikr, dark, large text scrolls', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(
        tester,
        size: board,
        appearance: 'dark',
        now: DateTime(2026, 9, 7, 9, 41),
        extraPrefs: {'settings.textSize': 2},
      );
      final longest = AppHarness.library.all.reduce(
        (a, b) => a.text.length >= b.text.length ? a : b,
      );
      final index = AppHarness.library[longest.category].indexOf(longest);
      await tester.tap(find.text(_bandLabel(longest.category)));
      await AppHarness.settleWithDatabase(tester);
      await next(tester, 'التالي', index);
      expect(find.text('مرّر للمتابعة'), findsOneWidget);
      await shot('3_2_reader_long_dark_ar');
    });

    testWidgets('3.3 English shows the meaning', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(
        tester,
        size: board,
        language: 'en',
        now: DateTime(2026, 9, 7, 9, 41),
      );
      await tester.tap(find.text('Begin'));
      await AppHarness.settleWithDatabase(tester);
      await next(tester, 'Next', 2);
      await countOnce(tester);
      await tester.pumpAndSettle();
      await shot('3_3_reader_light_en');
    });

    testWidgets('3.4 session complete', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 9, 41));
      await tester.tap(find.text('ابدأ'));
      await AppHarness.settleWithDatabase(tester);
      for (final thikr in AppHarness.library[ThikrCategory.morning]) {
        for (var i = 0; i < thikr.count; i++) {
          await countOnce(tester);
        }
        await tester.pump(const Duration(milliseconds: 600));
      }
      await AppHarness.settleWithDatabase(tester);
      await shot('3_4_complete_ar');
    });
  });

  group('04 reminders', () {
    testWidgets('4.1 fixed times, exact alarms denied', (tester) async {
      final h = AppHarness(
        permissions: FakePermissionService(exactAlarms: false),
      );
      await h.pump(tester, size: board);
      await tester.tap(find.text('التذكيرات').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('4_1_reminders_fixed_ar');
    });

    testWidgets('4.2 prayer mode, manual city', (tester) async {
      await AppHarness().pump(
        tester,
        size: board,
        extraPrefs: {
          'reminders.mode': 'prayer',
          'prayer.useDeviceLocation': false,
          'prayer.manualCity': 'makkah',
        },
      );
      await tester.tap(find.text('التذكيرات').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('4_2_reminders_prayer_ar');
    });

    testWidgets('4.3 time sheet', (tester) async {
      await AppHarness().pump(tester, size: board);
      await tester.tap(find.text('التذكيرات').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('٦:٣٠ ص'));
      await tester.pumpAndSettle();
      await shot('4_3_time_sheet_ar');
    });

    testWidgets('4.4 OEM sheet', (tester) async {
      final h = AppHarness(
        permissions: FakePermissionService(batteryExempt: false),
      );
      await h.pump(tester, size: board);
      await tester.tap(find.text('التذكيرات').last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('التذكيرات لا تصل؟'), 200);
      await tester.tap(find.text('التذكيرات لا تصل؟'));
      await tester.pumpAndSettle();
      await shot('4_4_oem_sheet_ar');
    });
  });

  group('05 library and settings', () {
    testWidgets('5.1 favourites', (tester) async {
      final h = AppHarness();
      await h.db.addFavorite('mo2', DateTime(2026, 9, 7));
      await h.db.addFavorite('ev2', DateTime(2026, 9, 6));
      await h.pump(tester, size: board);
      await tester.tap(find.text('المفضلة').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('5_1_favorites_ar');
    });

    testWidgets('5.2 favourites, empty', (tester) async {
      await AppHarness().pump(tester, size: board);
      await tester.tap(find.text('المفضلة').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('5_2_favorites_empty_ar');
    });

    testWidgets('5.3 progress', (tester) async {
      // As on the board: nothing yet today (its cell is outlined), a run of
      // full days, one empty day and a couple of partial ones. Signed in, so
      // the AF 6 "save your streak" card stays out of this frame.
      final h = await withHistory(
        days: 7,
        auth: FakeAuthService(initialUser: _owner),
      );
      await h.db.recordCompletion('morning', DateTime(2026, 8, 29, 7));
      await h.db.recordCompletion('morning', DateTime(2026, 8, 25, 7));
      for (final c in ['wake', 'morning', 'evening', 'sleep']) {
        for (final d in [24, 26, 27, 28]) {
          await h.db.recordCompletion(c, DateTime(2026, 8, d, 7));
        }
      }
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 10, 2));
      await tester.tap(find.text('التقدّم').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('5_3_progress_ar');
    });

    testWidgets('5.5 content failed to load', (tester) async {
      await AppHarness().pump(
        tester,
        size: board,
        libraryError: StateError('corrupt'),
      );
      await shot('5_5_error_ar');
    });
  });

  group('3.5 share card', () {
    // Board 3.5's own text.
    const short =
        'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا '
        'عَبْدُكَ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي '
        'فَاغْفِرْ لِي';

    Future<void> pumpCard(
      WidgetTester tester,
      String text,
      ShareCardStyle style,
    ) async {
      tester.view.physicalSize = const Size(1080, 1600);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        Center(
          child: RepaintBoundary(
            child: ShareCard(
              text: text,
              reference: 'رواه البخاري ٦٣٠٦',
              brandName: 'مِشْكَاةُ',
              brandWird: 'الوِرْدِ',
              language: TextDirection.rtl,
              style: style,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('aubergine, square', (tester) async {
      await pumpCard(tester, short, ShareCardStyle.aubergine);
      await expectLater(
        find.byType(ShareCard),
        matchesGoldenFile('images/share_aubergine_square.png'),
      );
    });

    testWidgets('stone, the longest thikr in the corpus', (tester) async {
      final longest = AppHarness.library.all.reduce(
        (a, b) => a.text.length >= b.text.length ? a : b,
      );
      await pumpCard(tester, longest.text, ShareCardStyle.stone);
      await expectLater(
        find.byType(ShareCard),
        matchesGoldenFile('images/share_stone_longest.png'),
      );
    });
  });

  group('AF accounts and feedback', () {
    final now = DateTime(2026, 9, 25, 10, 20);

    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(findIcon(MIcon.settings));
      await AppHarness.settleWithDatabase(tester);
    }

    AppHarness owner() {
      final h = AppHarness(auth: FakeAuthService(initialUser: _owner));
      h.feedback.admins.add(_owner.uid);
      return h;
    }

    /// The board's four conversations, newest first.
    void seedMine(AppHarness h) {
      h.feedback
        ..seed(
          _thread(
            'f1',
            FeedbackType.thikr,
            'التشكيل في «يَضُرُّ» يختلف عن النسخة المطبوعة',
            DateTime(2026, 9, 24, 9, 36),
            status: FeedbackStatus.answered,
            unreadForUser: true,
            thikrId: 'mo3',
            issues: {ThikrIssue.text},
          ),
          messages: [
            _msg(
              MessageAuthor.user,
              'التشكيل في «يَضُرُّ» يختلف عن نسخة حصن المسلم المطبوعة لديّ.',
              DateTime(2026, 9, 24, 9, 36),
            ),
            _msg(
              MessageAuthor.admin,
              'جزاك الله خيراً. راجعنا المصدر، والتشكيل في التطبيق مطابق '
              'لرواية أبي داود. سنضيف ملاحظة توضّح اختلاف النسخ.',
              DateTime(2026, 9, 24, 10, 5),
            ),
            _msg(
              MessageAuthor.user,
              'واضح الآن، شكراً لكم.',
              DateTime(2026, 9, 24, 10, 20),
            ),
          ],
        )
        ..seed(
          _thread(
            'f2',
            FeedbackType.feature,
            'أتمنى إضافة عدّاد للتسبيح بعد كل صلاة',
            DateTime(2026, 9, 22, 8),
            status: FeedbackStatus.inReview,
          ),
        )
        ..seed(
          _thread(
            'f3',
            FeedbackType.bug,
            'تذكير المساء تأخر ١٠ دقائق على جهازي',
            DateTime(2026, 9, 21, 18),
          ),
        )
        ..seed(
          _thread(
            'f4',
            FeedbackType.feature,
            'اقتراح: ألوان أدفأ للوضع الليلي',
            DateTime(2026, 9, 3, 12),
            status: FeedbackStatus.closed,
          ),
        );
    }

    testWidgets('16a settings page, signed out', (tester) async {
      await AppHarness().pump(tester, size: board, now: now);
      await openSettings(tester);
      await shot('af_16a_settings_top_ar');
    });

    testWidgets('16a settings page, owner, scrolled', (tester) async {
      final h = owner();
      h.feedback.seed(
        _thread('i1', FeedbackType.bug, 'x', now, unreadForAdmin: true),
      );
      await h.pump(tester, size: board, now: now);
      await openSettings(tester);
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -600));
      await AppHarness.settleWithDatabase(tester);
      await shot('af_16a_settings_owner_ar');
    });

    testWidgets('16a athkar sources', (tester) async {
      await AppHarness().pump(tester, size: board, now: now);
      await openSettings(tester);
      final row = find.text('مصادر الأذكار');
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await AppHarness.settleWithDatabase(tester);
      await shot('af_16a_sources_ar');
    });

    testWidgets('1b settings, signed in owner, English dark', (tester) async {
      final h = owner();
      h.feedback.seed(
        _thread('i1', FeedbackType.bug, 'x', now, unreadForAdmin: true),
      );
      await h.pump(
        tester,
        size: board,
        now: now,
        language: 'en',
        appearance: 'dark',
        extraPrefs: {
          'sync.lastSyncAt': now
              .subtract(const Duration(minutes: 3))
              .millisecondsSinceEpoch,
        },
      );
      await openSettings(tester);
      await shot('af_1b_settings_owner_dark_en');
    });

    Future<void> signInSheet(WidgetTester tester, AppHarness h) async {
      await openSettings(tester);
      await tester.tap(find.byType(SmallPillButton).first);
      await tester.pumpAndSettle();
    }

    testWidgets('2a sign-in sheet', (tester) async {
      final h = AppHarness();
      await h.pump(tester, size: board, now: now);
      await signInSheet(tester, h);
      await shot('af_2a_sign_in_light_ar');
    });

    testWidgets('2b sign-in sheet, English dark', (tester) async {
      final h = AppHarness();
      await h.pump(
        tester,
        size: board,
        now: now,
        language: 'en',
        appearance: 'dark',
      );
      await signInSheet(tester, h);
      await shot('af_2b_sign_in_dark_en');
    });

    testWidgets('3 first sign-in merge result', (tester) async {
      final h = await withHistory(days: 10);
      await h.db.addFavorite('mo1', today);
      await h.db.addFavorite('ev2', today);
      await h.pump(
        tester,
        size: board,
        now: today.add(const Duration(hours: 10)),
      );
      await signInSheet(tester, h);
      await tester.tap(find.byType(ProviderButton).last);
      await AppHarness.settleWithDatabase(tester);
      await shot('af_3_merge_result_ar');
    });

    testWidgets('4 account screen', (tester) async {
      final h = AppHarness(
        auth: FakeAuthService(
          initialUser: const AppUser(
            uid: 'me',
            isAnonymous: false,
            displayName: 'محمد رمضان',
            email: 'mohamed.r@gmail.com',
            provider: AuthProviderKind.google,
          ),
        ),
      );
      await h.pump(
        tester,
        size: board,
        now: now,
        extraPrefs: {
          'sync.lastSyncAt': now
              .subtract(const Duration(minutes: 3))
              .millisecondsSinceEpoch,
        },
      );
      await openSettings(tester);
      await tester.tap(find.text('محمد رمضان'));
      await tester.pumpAndSettle();
      await shot('af_4_account_ar');

      await tester.tap(find.text('حذف الحساب'));
      await tester.pumpAndSettle();
      await shot('af_5_delete_account_ar');
    });

    testWidgets('6 progress nudge', (tester) async {
      final h = await withHistory(days: 10);
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 10, 4));
      await tester.tap(find.text('التقدّم').last);
      await AppHarness.settleWithDatabase(tester);
      await shot('af_6_progress_nudge_ar');
    });

    Future<void> openMorningThird(WidgetTester tester) async {
      await tester.tap(find.text('ابدأ'));
      await AppHarness.settleWithDatabase(tester);
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.bySemanticsLabel('التالي'));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('7 reader overflow and 9 thikr report', (tester) async {
      final h = await withHistory(todayDone: ['wake']);
      await h.pump(tester, size: board, now: DateTime(2026, 9, 7, 9, 43));
      await openMorningThird(tester);
      await tester.tap(find.bySemanticsLabel('المزيد'));
      await tester.pumpAndSettle();
      await shot('af_7_reader_overflow_ar');

      await tester.tap(find.text('الإبلاغ عن خطأ في هذا الذكر'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('النص'));
      await tester.enterText(
        find.byType(TextField),
        'التشكيل في «يَضُرُّ» يختلف عن نسخة حصن المسلم المطبوعة لديّ.',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await shot('af_9_thikr_report_ar');
    });

    testWidgets('8 feedback sheet and 10 sent', (tester) async {
      final h = AppHarness();
      await h.pump(tester, size: board, now: now);
      await openSettings(tester);
      await tester.ensureVisible(find.text('ملاحظات واقتراحات'));
      await tester.tap(find.text('ملاحظات واقتراحات'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('أرسل ملاحظة'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'أتمنى إضافة عدّاد للتسبيح بعد كل صلاة، يبدأ تلقائياً عند فتح أذكار '
        'بعد الصلاة.',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await shot('af_8_feedback_sheet_ar');

      await tester.ensureVisible(find.text('إرسال'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إرسال'));
      await AppHarness.settleWithDatabase(tester);
      await shot('af_10_sent_ar');
    });

    Future<void> openMessages(WidgetTester tester) async {
      await openSettings(tester);
      await tester.ensureVisible(find.text('ملاحظات واقتراحات'));
      await tester.tap(find.text('ملاحظات واقتراحات'));
      await AppHarness.settleWithDatabase(tester);
    }

    testWidgets('11 messages and 12 thread', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _owner));
      seedMine(h);
      await h.pump(tester, size: board, now: now);
      await openMessages(tester);
      await shot('af_11_messages_ar');

      await tester.tap(
        find.text('التشكيل في «يَضُرُّ» يختلف عن النسخة المطبوعة'),
      );
      await AppHarness.settleWithDatabase(tester);
      await shot('af_12_thread_ar');
    });

    testWidgets('11b messages, empty, dark', (tester) async {
      final h = AppHarness();
      await h.pump(tester, size: board, now: now, appearance: 'dark');
      await openMessages(tester);
      await shot('af_11b_messages_empty_dark_ar');
    });

    testWidgets('12b thread, closed, English dark', (tester) async {
      final h = AppHarness(auth: FakeAuthService(initialUser: _owner));
      h.feedback.seed(
        _thread(
          'c1',
          FeedbackType.bug,
          'My evening reminder arrived 10 minutes late on a Xiaomi phone.',
          DateTime(2026, 9, 21, 18, 2),
          status: FeedbackStatus.closed,
          closedAt: DateTime(2026, 9, 23, 9),
        ),
        messages: [
          _msg(
            MessageAuthor.user,
            'My evening reminder arrived 10 minutes late on a Xiaomi phone.',
            DateTime(2026, 9, 21, 18, 2),
          ),
          _msg(
            MessageAuthor.admin,
            'Thanks for the details. Xiaomi can pause apps in the background. '
            'Turning on Autostart for Mishkat usually helps, and the guide in '
            'Reminders shows the steps.',
            DateTime(2026, 9, 22, 9),
          ),
          _msg(
            MessageAuthor.user,
            'That fixed it, thank you.',
            DateTime(2026, 9, 22, 11),
          ),
        ],
      );
      await h.pump(
        tester,
        size: board,
        now: now,
        language: 'en',
        appearance: 'dark',
      );
      await openSettings(tester);
      await tester.ensureVisible(find.text('Feedback'));
      await tester.tap(find.text('Feedback'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.textContaining('My evening reminder'));
      await AppHarness.settleWithDatabase(tester);
      await shot('af_12b_thread_closed_dark_en');
    });

    testWidgets('13 inbox and 14 admin thread', (tester) async {
      final h = owner();
      h.feedback
        ..seed(
          _thread(
            'a1',
            FeedbackType.thikr,
            'التشكيل في «يَضُرُّ» يختلف عن النسخة المطبوعة لديّ.',
            DateTime(2026, 9, 25, 10, 15),
            unreadForAdmin: true,
            thikrId: 'mo3',
            issues: {ThikrIssue.text},
            language: 'ar',
          ),
          messages: [
            _msg(
              MessageAuthor.user,
              'التشكيل في «يَضُرُّ» يختلف عن نسخة حصن المسلم المطبوعة لديّ.',
              DateTime(2026, 9, 25, 10, 15),
            ),
          ],
        )
        ..seed(
          _thread(
            'a2',
            FeedbackType.bug,
            'Evening reminder late on Xiaomi',
            DateTime(2026, 9, 25, 9, 20),
            unreadForAdmin: true,
            language: 'en',
          ),
        )
        ..seed(
          _thread(
            'a3',
            FeedbackType.feature,
            'أتمنى إضافة عدّاد للتسبيح بعد كل صلاة',
            DateTime(2026, 9, 24, 16),
            unreadForAdmin: true,
            language: 'ar',
          ),
        )
        ..seed(
          _thread(
            'a4',
            FeedbackType.feature,
            'Please add an Urdu translation',
            DateTime(2026, 9, 20, 12),
            language: 'en',
          ),
        );
      await h.pump(tester, size: board, now: now);
      await openSettings(tester);
      await tester.ensureVisible(find.text('صندوق الوارد'));
      await tester.tap(find.text('صندوق الوارد'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('جديدة'));
      await AppHarness.settleWithDatabase(tester);
      await shot('af_13_inbox_ar');

      await tester.tap(find.textContaining('يختلف عن النسخة'));
      await AppHarness.settleWithDatabase(tester);
      await shot('af_14_admin_thread_ar');
    });

    testWidgets('13b inbox, empty, English dark', (tester) async {
      final h = owner();
      await h.pump(
        tester,
        size: board,
        now: now,
        language: 'en',
        appearance: 'dark',
      );
      await openSettings(tester);
      await tester.ensureVisible(find.text('Inbox'));
      await tester.tap(find.text('Inbox'));
      await AppHarness.settleWithDatabase(tester);
      await tester.tap(find.text('Athkar'));
      await tester.tap(find.text('New'));
      await AppHarness.settleWithDatabase(tester);
      await shot('af_13b_inbox_empty_dark_en');
    });
  });
}

/// The day-band label that opens [c]'s routine.
String _bandLabel(ThikrCategory c) => switch (c) {
  ThikrCategory.wake => 'استيقاظ',
  ThikrCategory.morning => 'صباح',
  ThikrCategory.evening => 'مساء',
  ThikrCategory.sleep => 'نوم',
  _ => throw ArgumentError('$c has no day-band column'),
};

const _owner = AppUser(
  uid: 'me',
  isAnonymous: false,
  displayName: 'Mohamed Ramadan',
  email: 'mohamed.r@gmail.com',
  provider: AuthProviderKind.google,
);

FeedbackThread _thread(
  String id,
  FeedbackType type,
  String preview,
  DateTime at, {
  FeedbackStatus status = FeedbackStatus.open,
  bool unreadForUser = false,
  bool unreadForAdmin = false,
  String? thikrId,
  Set<ThikrIssue> issues = const {},
  String language = 'ar',
  DateTime? closedAt,
}) => FeedbackThread(
  id: id,
  uid: 'me',
  type: type,
  status: status,
  preview: preview,
  createdAt: at,
  updatedAt: at,
  unreadForUser: unreadForUser,
  unreadForAdmin: unreadForAdmin,
  thikrId: thikrId,
  issues: issues,
  contentVersion: thikrId == null ? null : '2026-09-24-draft.1',
  closedAt: closedAt,
  device: DeviceDetails(
    appVersion: '1.2.0 (34)',
    platform: 'Android 14 · Pixel 7',
    language: language,
  ),
);

FeedbackMessage _msg(MessageAuthor from, String body, DateTime at) =>
    FeedbackMessage(
      id: '${at.millisecondsSinceEpoch}',
      from: from,
      body: body,
      createdAt: at,
    );
