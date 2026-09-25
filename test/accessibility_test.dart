import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/core/widgets/mishkat_icon.dart';
import 'package:mishkat/features/feedback/feedback_widgets.dart';
import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/feedback/feedback_models.dart';

import 'golden/font_loader.dart';
import 'support/app_harness.dart';

/// Flutter's own accessibility guidelines, on the main screens in both
/// appearances: every tap target at least 48px, every tap target labelled,
/// and text contrast measured from the rendered pixels.
void main() {
  setUpAll(() async {
    await loadAppFonts();
    await AppHarness.loadLibrary();
  });

  Future<void> check(WidgetTester tester) async {
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final appearance in ['light', 'dark']) {
    group(appearance, () {
      Future<void> start(
        WidgetTester tester, {
        String lang = 'ar',
        AppHarness? harness,
      }) async {
        final h = harness ?? AppHarness();
        await h.db.recordCompletion('wake', DateTime(2026, 9, 7, 5, 5));
        await h.pump(
          tester,
          appearance: appearance,
          language: lang,
          now: DateTime(2026, 9, 7, 9, 41),
        );
      }

      testWidgets('home', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await check(tester);
        handle.dispose();
      });

      testWidgets('home in English', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester, lang: 'en');
        await check(tester);
        handle.dispose();
      });

      testWidgets('reader', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(find.text('ابدأ'));
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });

      testWidgets('reminders', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(find.text('التذكيرات').last);
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });

      testWidgets('settings page', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(findIcon(MIcon.settings));
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });

      testWidgets('progress', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(find.text('التقدّم').last);
        await AppHarness.settleWithDatabase(tester);
        await check(tester);
        handle.dispose();
      });

      /// Signed in as the owner, with one conversation from someone else
      /// and one of the owner's own that has a reply.
      AppHarness owner() {
        final h = AppHarness(
          auth: FakeAuthService(
            initialUser: const AppUser(
              uid: 'me',
              isAnonymous: false,
              displayName: 'محمد رمضان',
              email: 'mohamed.r@gmail.com',
              provider: AuthProviderKind.apple,
            ),
          ),
        );
        FeedbackThread thread(String id, String uid) => FeedbackThread(
          id: id,
          uid: uid,
          type: FeedbackType.bug,
          status: FeedbackStatus.answered,
          preview: 'تذكير المساء تأخر ١٠ دقائق على جهازي',
          createdAt: DateTime(2026, 9, 6),
          updatedAt: DateTime(2026, 9, 6),
          unreadForUser: true,
          unreadForAdmin: true,
        );
        final messages = [
          FeedbackMessage(
            id: 'a',
            from: MessageAuthor.user,
            body: 'تذكير المساء تأخر ١٠ دقائق على جهازي',
            createdAt: DateTime(2026, 9, 6, 18),
          ),
          FeedbackMessage(
            id: 'b',
            from: MessageAuthor.admin,
            body: 'جزاك الله خيراً، جرّب تفعيل التشغيل التلقائي.',
            createdAt: DateTime(2026, 9, 6, 19),
          ),
        ];
        h.feedback
          ..admins.add('me')
          ..seed(thread('mine', 'me'), messages: messages)
          ..seed(thread('theirs', 'someone'), messages: messages);
        return h;
      }

      Future<void> openRow(WidgetTester tester, String label) async {
        final row = find.text(label);
        await tester.scrollUntilVisible(
          row,
          300,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.tap(row);
        await AppHarness.settleWithDatabase(tester);
      }

      testWidgets('sign-in sheet', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(findIcon(MIcon.settings));
        await AppHarness.settleWithDatabase(tester);
        await tester.tap(find.text('دخول'));
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });

      testWidgets('account', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester, harness: owner());
        await tester.tap(findIcon(MIcon.settings));
        await AppHarness.settleWithDatabase(tester);
        await tester.tap(find.text('محمد رمضان'));
        await AppHarness.settleWithDatabase(tester);
        await check(tester);
        handle.dispose();
      });

      testWidgets('feedback list, thread and sheet', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester, harness: owner());
        await tester.tap(findIcon(MIcon.settings));
        await AppHarness.settleWithDatabase(tester);
        await openRow(tester, 'ملاحظات واقتراحات');
        await check(tester);
        await tester.tap(find.byType(ThreadRow).first);
        await AppHarness.settleWithDatabase(tester);
        await check(tester);
        await tester.tap(find.bySemanticsLabel('رجوع').last);
        await AppHarness.settleWithDatabase(tester);
        await tester.tap(find.text('رسالة جديدة'));
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });

      testWidgets('owner inbox and thread', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester, harness: owner());
        await tester.tap(findIcon(MIcon.settings));
        await AppHarness.settleWithDatabase(tester);
        await openRow(tester, 'صندوق الوارد');
        await check(tester);
        await tester.tap(find.byType(ThreadRow).first);
        await AppHarness.settleWithDatabase(tester);
        await check(tester);
        handle.dispose();
      });

      testWidgets('reader menu and thikr report', (tester) async {
        final handle = tester.ensureSemantics();
        await start(tester);
        await tester.tap(find.text('ابدأ'));
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('المزيد'));
        await tester.pumpAndSettle();
        await check(tester);
        await tester.tap(find.text('الإبلاغ عن خطأ في هذا الذكر'));
        await tester.pumpAndSettle();
        await check(tester);
        handle.dispose();
      });
    });
  }
}
