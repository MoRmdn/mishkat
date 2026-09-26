import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/features/settings/settings_controller.dart';
import 'package:mishkat/services/auth/auth_service.dart';
import 'package:mishkat/services/feedback/feedback_models.dart';
import 'package:mishkat/services/feedback/feedback_outbox.dart';
import 'package:mishkat/services/feedback/feedback_providers.dart';
import 'package:mishkat/services/feedback/feedback_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/cloud_fakes.dart';

FeedbackDraft _draft(String id) => FeedbackDraft(
  id: id,
  type: FeedbackType.bug,
  body: 'تذكير المساء تأخر ١٠ دقائق على جهازي',
  createdAt: DateTime(2026, 9, 21, 18, 2),
);

void main() {
  late FakeAuthService auth;
  late FakeFeedbackRepository repo;
  late ProviderContainer container;
  late SharedPreferences prefs;

  Future<void> start({Map<String, Object> stored = const {}}) async {
    SharedPreferences.setMockInitialValues(stored);
    prefs = await SharedPreferences.getInstance();
    auth = FakeAuthService();
    repo = FakeFeedbackRepository();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authServiceProvider.overrideWithValue(auth),
        feedbackRepositoryProvider.overrideWithValue(repo),
      ],
    );
    container.listen(accountProvider, (_, _) {});
    await pumpEventQueue();
  }

  FeedbackOutbox outbox() => container.read(feedbackOutboxProvider.notifier);

  tearDown(() => container.dispose());

  test('a first message creates the anonymous sender and arrives', () async {
    await start();
    expect(await outbox().send(_draft('f1')), SendResult.sent);
    expect(repo.threads['f1']!.uid, 'uid-anon');
    expect(container.read(feedbackOutboxProvider), isEmpty);
    expect(prefs.getString('feedback.outbox'), isNull);
  });

  test('offline before any account exists: kept and queued', () async {
    await start();
    auth.online = false;
    expect(await outbox().send(_draft('f1')), SendResult.queued);
    expect(container.read(feedbackOutboxProvider).single.id, 'f1');
    expect(prefs.getString('feedback.outbox'), contains('f1'));
  });

  test('offline with an account: kept and queued', () async {
    await start();
    await auth.ensureAnonymous();
    repo.online = false;
    expect(await outbox().send(_draft('f1')), SendResult.queued);
    expect(repo.threads, isEmpty);
  });

  test(
    'a queued draft survives a restart and goes on the next flush',
    () async {
      await start();
      auth.online = false;
      await outbox().send(_draft('f1'));
      final stored = prefs.getString('feedback.outbox')!;
      container.dispose();

      await start(stored: {'feedback.outbox': stored});
      expect(
        container.read(feedbackOutboxProvider).single.body,
        contains('١٠'),
      );
      await outbox().flush();
      expect(repo.threads.keys, ['f1']);
      expect(container.read(feedbackOutboxProvider), isEmpty);
    },
  );

  test('a rejected send is kept as a draft for retry', () async {
    await start();
    repo.rejectNext = true;
    expect(await outbox().send(_draft('f1')), SendResult.failed);
    expect(container.read(feedbackOutboxProvider), hasLength(1));
    expect(await outbox().send(_draft('f1')), SendResult.sent);
    expect(container.read(feedbackOutboxProvider), isEmpty);
  });

  test('a resend after the server already has it is harmless', () async {
    await start();
    await outbox().send(_draft('f1'));
    await outbox().send(_draft('f1'));
    expect(repo.threads, hasLength(1));
  });

  test('queued drafts are listed first, marked as waiting', () async {
    await start();
    await outbox().send(_draft('sent'));
    repo.online = false;
    await outbox().send(_draft('waiting'));
    repo.online = true;

    final threads = await container.read(myThreadsProvider.future);
    expect(threads.map((t) => (t.id, t.queued)), [
      ('waiting', true),
      ('sent', false),
    ]);
  });
}
