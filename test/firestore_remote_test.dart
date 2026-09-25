import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/services/feedback/feedback_models.dart';
import 'package:mishkat/services/feedback/firestore_feedback_repository.dart';
import 'package:mishkat/services/sync/firestore_sync_remote.dart';
import 'package:mishkat/services/sync/sync_models.dart';

FeedbackDraft _draft(String id, {FeedbackType type = FeedbackType.feature}) =>
    FeedbackDraft(
      id: id,
      type: type,
      body: 'أتمنى إضافة عدّاد للتسبيح بعد كل صلاة\nوشكراً',
      createdAt: DateTime(2026, 9, 25, 9, 36),
      issues: type == FeedbackType.thikr ? {ThikrIssue.text} : const {},
      thikrId: type == FeedbackType.thikr ? 'mo3' : null,
      contentVersion: type == FeedbackType.thikr ? '2026-09-24-draft.1' : null,
      device: const DeviceDetails(
        appVersion: '1.2.0 (34)',
        platform: 'Android 14 · Pixel 7',
        language: 'ar',
      ),
    );

void main() {
  group('FirestoreSyncRemote', () {
    late FakeFirebaseFirestore db;
    late FirestoreSyncRemote remote;

    setUp(() {
      db = FakeFirebaseFirestore();
      remote = FirestoreSyncRemote(db);
    });

    test(
      'rows round-trip under users/{uid}, keyed by their natural id',
      () async {
        await remote.putCompletions('u', [
          SyncCompletion(
            category: 'morning',
            day: '2026-09-24',
            completedAt: DateTime(2026, 9, 24, 6),
          ),
        ]);
        await remote.putFavorites('u', [
          SyncFavorite(
            thikrId: 'mo1',
            addedAt: DateTime(2026, 9, 1),
            deletedAt: DateTime(2026, 9, 2),
          ),
        ]);
        await remote.putSettings(
          'u',
          SettingsSnapshot(
            group: SyncGroup.reminders,
            updatedAt: DateTime(2026, 9, 3),
            values: const {'mode': 'prayer'},
          ),
        );

        final doc = await db
            .doc('users/u/completions/2026-09-24_morning')
            .get();
        expect(doc.exists, isTrue);

        final state = await remote.fetch('u');
        expect(state.completions.single.key, '2026-09-24_morning');
        expect(state.favorites.single.deletedAt, DateTime(2026, 9, 2));
        final settings = state.settings[SyncGroup.reminders]!;
        expect(settings.values, {'mode': 'prayer'});
        expect(settings.updatedAt, DateTime(2026, 9, 3));
        expect(state.completionsCursor, isNotNull);
      },
    );

    test('pushing the same completion twice leaves one document', () async {
      final c = SyncCompletion(
        category: 'evening',
        day: '2026-09-24',
        completedAt: DateTime(2026, 9, 24, 17),
      );
      await remote.putCompletions('u', [c]);
      await remote.putCompletions('u', [c]);
      expect((await db.collection('users/u/completions').get()).size, 1);
    });

    test('another user\'s rows are never read', () async {
      await remote.putFavorites('other', [
        SyncFavorite(thikrId: 'x', addedAt: DateTime(2026)),
      ]);
      expect((await remote.fetch('u')).favorites, isEmpty);
    });

    test('deleting the account removes the whole tree', () async {
      await remote.putFavorites('u', [
        SyncFavorite(thikrId: 'mo1', addedAt: DateTime(2026)),
      ]);
      await remote.putSettings(
        'u',
        SettingsSnapshot(
          group: SyncGroup.app,
          updatedAt: DateTime(2026),
          values: const {},
        ),
      );
      await remote.deleteAll('u');
      expect((await db.collection('users/u/favorites').get()).size, 0);
      expect((await db.collection('users/u/settings').get()).size, 0);
      expect((await db.doc('users/u').get()).exists, isFalse);
    });
  });

  group('FirestoreFeedbackRepository', () {
    late FakeFirebaseFirestore db;
    late FirestoreFeedbackRepository repo;

    setUp(() {
      db = FakeFirebaseFirestore();
      repo = FirestoreFeedbackRepository(db);
    });

    test(
      'a submission is a thread, a first message and a rate stamp',
      () async {
        await repo.submit(_draft('f1', type: FeedbackType.thikr), uid: 'u');

        final thread = (await repo.thread('f1'))!;
        expect(thread.uid, 'u');
        expect(thread.status, FeedbackStatus.open);
        expect(thread.preview, 'أتمنى إضافة عدّاد للتسبيح بعد كل صلاة');
        expect(thread.thikrId, 'mo3');
        expect(thread.contentVersion, '2026-09-24-draft.1');
        expect(thread.issues, {ThikrIssue.text});
        expect(thread.device!.platform, 'Android 14 · Pixel 7');
        expect(thread.unreadForAdmin, isTrue);

        final messages = await repo.messages('f1');
        expect(messages.single.from, MessageAuthor.user);
        expect(
          (await db.doc('users/u').get()).data()!['lastFeedbackAt'],
          isNotNull,
        );
      },
    );

    test('sending the same draft twice creates one thread', () async {
      await repo.submit(_draft('f1'), uid: 'u');
      await repo.submit(_draft('f1'), uid: 'u');
      expect((await db.collection('feedback').get()).size, 1);
      expect(await repo.messages('f1'), hasLength(1));
    });

    test(
      'an owner reply answers the thread and marks it unread for the sender',
      () async {
        await repo.submit(_draft('f1'), uid: 'u');
        await repo.markRead('f1', reader: MessageAuthor.admin);
        await repo.reply(
          'f1',
          from: MessageAuthor.admin,
          body: 'جزاك الله خيراً',
        );

        final thread = (await repo.thread('f1'))!;
        expect(thread.status, FeedbackStatus.answered);
        expect(thread.unreadForUser, isTrue);
        expect(thread.unreadForAdmin, isFalse);
        expect((await repo.badges('u', isAdmin: false)).userUnread, 1);

        await repo.markRead('f1', reader: MessageAuthor.user);
        expect((await repo.badges('u', isAdmin: false)).userUnread, 0);
      },
    );

    test('the inbox filters by type and status', () async {
      await repo.submit(_draft('a', type: FeedbackType.thikr), uid: 'u1');
      await repo.submit(_draft('b', type: FeedbackType.bug), uid: 'u2');
      await repo.setStatus('b', FeedbackStatus.closed);

      expect((await repo.inbox()).map((t) => t.id).toSet(), {'a', 'b'});
      expect((await repo.inbox(type: FeedbackType.thikr)).map((t) => t.id), [
        'a',
      ]);
      expect(
        (await repo.inbox(status: FeedbackStatus.closed)).map((t) => t.id),
        ['b'],
      );
      expect((await repo.thread('b'))!.closedAt, isNotNull);
    });

    test('numbers are assigned once, in order', () async {
      await repo.submit(_draft('a'), uid: 'u');
      await repo.submit(_draft('b'), uid: 'u');
      expect(await repo.assignNumber('a'), 1);
      expect(await repo.assignNumber('b'), 2);
      expect(await repo.assignNumber('a'), 1);
    });

    test('the owner is whoever has an admins document', () async {
      await db.doc('admins/owner').set({});
      expect(await repo.isAdmin('owner'), isTrue);
      expect(await repo.isAdmin('u'), isFalse);
    });

    test('deleting a user removes their threads and messages only', () async {
      await repo.submit(_draft('mine'), uid: 'u');
      await repo.submit(_draft('theirs'), uid: 'v');
      await repo.deleteAllFor('u');
      expect(await repo.thread('mine'), isNull);
      expect(await repo.messages('mine'), isEmpty);
      expect(await repo.thread('theirs'), isNotNull);
    });
  });
}
