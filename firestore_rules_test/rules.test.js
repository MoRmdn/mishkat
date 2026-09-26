// firestore.rules against the emulator:
//
//   cd firestore_rules_test && npm install && npm test
//
// Every write here mirrors one the app makes (lib/services/sync and
// lib/services/feedback), so a rule that rejects the app fails here first.
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getCountFromServer,
  getDoc,
  getDocs,
  query,
  runTransaction,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
  writeBatch,
} from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-mishkat',
    firestore: { rules: readFileSync('../firestore.rules', 'utf8') },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    await setDoc(doc(ctx.firestore(), 'admins/owner'), {});
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();
const anon = () => env.unauthenticatedContext().firestore();

/** What FirestoreFeedbackRepository.submit writes, in one transaction. */
function submit(db, uid, id, overrides = {}) {
  return runTransaction(db, async (tx) => {
    const thread = doc(db, 'feedback', id);
    if ((await tx.get(thread)).exists()) return;
    tx.set(thread, {
      uid,
      type: 'bug',
      status: 'new',
      preview: 'Evening reminder late',
      issues: [],
      thikrId: null,
      contentVersion: null,
      contactEmail: null,
      device: { appVersion: '1.2.0 (34)', platform: 'Android 14', language: 'en' },
      createdAt: serverTimestamp(),
      updatedAt: serverTimestamp(),
      unreadForUser: false,
      unreadForAdmin: true,
      ...overrides,
    });
    tx.set(doc(db, 'feedback', id, 'messages', 'first'), {
      from: 'user',
      body: 'My evening reminder arrived 10 minutes late.',
      createdAt: serverTimestamp(),
    });
    tx.set(doc(db, 'users', uid), { lastFeedbackAt: serverTimestamp() }, { merge: true });
  });
}

/** A thread that already exists, bypassing the rules. */
async function seedThread(id, uid, fields = {}) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'feedback', id), {
      uid,
      type: 'bug',
      status: 'new',
      preview: 'x',
      issues: [],
      createdAt: new Date(),
      updatedAt: new Date(),
      unreadForUser: false,
      unreadForAdmin: true,
      ...fields,
    });
    await setDoc(doc(db, 'feedback', id, 'messages', 'first'), {
      from: 'user',
      body: 'x',
      createdAt: new Date(),
    });
  });
}

describe('users/{uid}', () => {
  test('a user reads and writes their own synced data', async () => {
    const db = as('alice');
    await assertSucceeds(
      setDoc(
        doc(db, 'users/alice/completions/2026-09'),
        { days: { '2026-09-25': { morning: new Date() } }, updatedAt: serverTimestamp() },
        { merge: true },
      ),
    );
    await assertSucceeds(
      setDoc(
        doc(db, 'users/alice/data/favorites'),
        { items: { mo1: { addedAt: new Date(), deletedAt: null } }, updatedAt: serverTimestamp() },
        { merge: true },
      ),
    );
    await assertSucceeds(
      setDoc(
        doc(db, 'users/alice/data/settings'),
        { app: { language: 'ar', updatedAt: new Date() } },
        { merge: true },
      ),
    );
    await assertSucceeds(getDocs(collection(db, 'users/alice/completions')));
    await assertSucceeds(getDoc(doc(db, 'users/alice/data/settings')));
  });

  test('the profile is written with the fields the app sends', async () => {
    await assertSucceeds(
      setDoc(
        doc(as('alice'), 'users/alice'),
        {
          schema: 2,
          profile: {
            displayName: 'Alice',
            email: 'a@privaterelay.appleid.com',
            emailVerified: true,
            givenName: 'Alice',
            isPrivateEmail: true,
          },
          providers: ['apple.com'],
          createdAt: new Date(2026, 8, 1),
          lastSignInAt: new Date(2026, 8, 25),
          app: { version: '1.2.0 (34)', platform: 'iOS 26.0 · iPhone', language: 'ar' },
          lastActiveAt: serverTimestamp(),
        },
        { merge: true },
      ),
    );
  });

  test('nothing else goes into the profile document', async () => {
    const db = as('alice');
    await assertFails(setDoc(doc(db, 'users/alice'), { location: [30.0, 31.2] }, { merge: true }));
    await assertFails(setDoc(doc(db, 'users/alice'), { profile: { timezone: 'Africa/Cairo' } }, { merge: true }));
    await assertFails(setDoc(doc(db, 'users/alice'), { app: { lat: 30 } }, { merge: true }));
  });

  test('only the known documents and month ids are written', async () => {
    const db = as('alice');
    await assertFails(setDoc(doc(db, 'users/alice/data/other'), { x: 1 }));
    await assertFails(setDoc(doc(db, 'users/alice/completions/2026-09-25_morning'), { x: 1 }));
    await assertFails(setDoc(doc(db, 'users/alice/favorites/mo1'), { addedAt: new Date() }));
    await assertFails(setDoc(doc(db, 'users/alice/anything/x'), { x: 1 }));
  });

  test('nobody else can read or write it', async () => {
    await assertFails(getDoc(doc(as('bob'), 'users/alice/data/favorites')));
    await assertFails(setDoc(doc(as('bob'), 'users/alice/data/settings'), {}));
    await assertFails(getDocs(collection(anon(), 'users/alice/completions')));
    await assertFails(getDocs(collection(as('owner'), 'users/alice/completions')));
    await assertFails(getDoc(doc(as('bob'), 'users/alice')));
  });

  test('the rate-limit stamp cannot be backdated', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'users/alice'), { lastFeedbackAt: new Date(2020, 0, 1) }),
    );
  });

  test('a user can delete their account data, first layout included', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, 'users/alice'), { lastSyncAt: new Date() });
      await setDoc(doc(db, 'users/alice/favorites/mo1'), { addedAt: new Date() });
      await setDoc(doc(db, 'users/alice/settings/app'), { updatedAt: new Date() });
      await setDoc(doc(db, 'users/alice/completions/2026-09-24_morning'), {});
    });
    const db = as('alice');
    await setDoc(doc(db, 'users/alice/data/favorites'), { items: {} });
    await assertSucceeds(deleteDoc(doc(db, 'users/alice/favorites/mo1')));
    await assertSucceeds(deleteDoc(doc(db, 'users/alice/settings/app')));
    await assertSucceeds(deleteDoc(doc(db, 'users/alice/completions/2026-09-24_morning')));
    await assertSucceeds(deleteDoc(doc(db, 'users/alice/data/favorites')));
    await assertSucceeds(deleteDoc(doc(db, 'users/alice')));
  });

  test('an early account with lastSyncAt can still be updated', async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), 'users/alice'), { lastSyncAt: new Date() });
    });
    await assertSucceeds(
      setDoc(doc(as('alice'), 'users/alice'), { schema: 2, lastActiveAt: serverTimestamp() }, { merge: true }),
    );
  });
});

describe('sending feedback', () => {
  test('a signed-in (or anonymous) user sends a conversation', async () => {
    await assertSucceeds(submit(as('alice'), 'alice', 'f1'));
  });

  test('sending the same draft again is a no-op, not an error', async () => {
    const db = as('alice');
    await submit(db, 'alice', 'f1');
    await assertSucceeds(submit(db, 'alice', 'f1'));
  });

  test('signed out cannot send', async () => {
    await assertFails(submit(anon(), 'alice', 'f1'));
  });

  test('nobody sends in someone else\'s name', async () => {
    const db = as('mallory');
    await assertFails(
      runTransaction(db, async (tx) => {
        tx.set(doc(db, 'feedback/f1'), { uid: 'alice' });
      }),
    );
    await assertFails(submit(db, 'mallory', 'f1', { uid: 'alice' }));
  });

  test('the rate limit cannot be reset through users/{uid}', async () => {
    const db = as('alice');
    await submit(db, 'alice', 'f1');
    await assertFails(
      setDoc(doc(db, 'users/alice'), { lastFeedbackAt: new Date(2020, 0, 1) }, { merge: true }),
    );
    await assertFails(submit(db, 'alice', 'f2'));
  });

  test('a new conversation cannot set its own status or unread flags', async () => {
    await assertFails(submit(as('alice'), 'alice', 'f1', { status: 'answered' }));
    await assertFails(submit(as('alice'), 'alice', 'f2', { unreadForAdmin: false }));
    await assertFails(submit(as('alice'), 'alice', 'f3', { number: 1 }));
  });

  test('a second conversation within a minute is refused', async () => {
    const db = as('alice');
    await assertSucceeds(submit(db, 'alice', 'f1'));
    await assertFails(submit(db, 'alice', 'f2'));
  });

  test('a message over 2000 characters is refused', async () => {
    const db = as('alice');
    await assertFails(
      runTransaction(db, async (tx) => {
        tx.set(doc(db, 'feedback/f1/messages/first'), {
          from: 'user',
          body: 'x'.repeat(2001),
          createdAt: serverTimestamp(),
        });
      }),
    );
  });
});

describe('reading feedback', () => {
  beforeEach(async () => {
    await seedThread('a1', 'alice', { unreadForUser: true });
    await seedThread('b1', 'bob');
  });

  test('a sender lists and reads only their own conversations', async () => {
    const db = as('alice');
    await assertSucceeds(getDocs(query(collection(db, 'feedback'), where('uid', '==', 'alice'))));
    await assertSucceeds(getDoc(doc(db, 'feedback/a1')));
    await assertSucceeds(getDocs(collection(db, 'feedback/a1/messages')));
    await assertSucceeds(
      getCountFromServer(
        query(
          collection(db, 'feedback'),
          where('uid', '==', 'alice'),
          where('unreadForUser', '==', true),
        ),
      ),
    );
  });

  test("a sender cannot read anyone else's", async () => {
    const db = as('alice');
    await assertFails(getDoc(doc(db, 'feedback/b1')));
    await assertFails(getDocs(collection(db, 'feedback/b1/messages')));
    await assertFails(getDocs(collection(db, 'feedback')));
  });

  test('the owner reads everything; admins/ is private', async () => {
    const owner = as('owner');
    await assertSucceeds(getDocs(collection(owner, 'feedback')));
    await assertSucceeds(getDocs(collection(owner, 'feedback/b1/messages')));
    await assertSucceeds(getDoc(doc(owner, 'admins/owner')));
    await assertFails(getDoc(doc(as('alice'), 'admins/owner')));
    await assertFails(setDoc(doc(as('alice'), 'admins/alice'), {}));
  });
});

describe('replies and status', () => {
  beforeEach(async () => {
    await seedThread('a1', 'alice');
  });

  test('the owner replies, answering the thread', async () => {
    const db = as('owner');
    const batch = writeBatch(db);
    batch.set(doc(collection(db, 'feedback/a1/messages')), {
      from: 'admin',
      body: 'Thanks for the details.',
      createdAt: serverTimestamp(),
    });
    batch.update(doc(db, 'feedback/a1'), {
      updatedAt: serverTimestamp(),
      unreadForUser: true,
      status: 'answered',
    });
    await assertSucceeds(batch.commit());
  });

  test('a sender cannot reply as the team', async () => {
    await assertFails(
      setDoc(doc(as('alice'), 'feedback/a1/messages/m1'), {
        from: 'admin',
        body: 'hi',
        createdAt: serverTimestamp(),
      }),
    );
  });

  test('a sender replies to their open conversation and marks replies read', async () => {
    const db = as('alice');
    const batch = writeBatch(db);
    batch.set(doc(collection(db, 'feedback/a1/messages')), {
      from: 'user',
      body: 'That fixed it, thank you.',
      createdAt: serverTimestamp(),
    });
    batch.update(doc(db, 'feedback/a1'), {
      updatedAt: serverTimestamp(),
      unreadForAdmin: true,
    });
    await assertSucceeds(batch.commit());
    await assertSucceeds(updateDoc(doc(db, 'feedback/a1'), { unreadForUser: false }));
  });

  test('only the owner changes status or numbers', async () => {
    await assertFails(updateDoc(doc(as('alice'), 'feedback/a1'), { status: 'closed' }));
    await assertFails(updateDoc(doc(as('alice'), 'feedback/a1'), { number: 7 }));
    await assertSucceeds(
      updateDoc(doc(as('owner'), 'feedback/a1'), { status: 'closed', closedAt: serverTimestamp() }),
    );
    await assertSucceeds(updateDoc(doc(as('owner'), 'feedback/a1'), { number: 104 }));
    await assertSucceeds(setDoc(doc(as('owner'), 'counters/feedback'), { next: 105 }));
    await assertFails(setDoc(doc(as('alice'), 'counters/feedback'), { next: 1 }));
  });

  test('nobody else touches the thread', async () => {
    await assertFails(updateDoc(doc(as('bob'), 'feedback/a1'), { unreadForUser: false }));
    await assertFails(
      setDoc(doc(as('bob'), 'feedback/a1/messages/m1'), {
        from: 'user',
        body: 'hi',
        createdAt: serverTimestamp(),
      }),
    );
  });

  test('a closed conversation takes no more replies', async () => {
    await seedThread('c1', 'alice', { status: 'closed' });
    await assertFails(
      setDoc(doc(as('alice'), 'feedback/c1/messages/m1'), {
        from: 'user',
        body: 'one more thing',
        createdAt: serverTimestamp(),
      }),
    );
  });
});

describe('deleting the account', () => {
  test('a sender deletes their own conversations and messages', async () => {
    await seedThread('a1', 'alice');
    const db = as('alice');
    const batch = writeBatch(db);
    batch.delete(doc(db, 'feedback/a1/messages/first'));
    batch.delete(doc(db, 'feedback/a1'));
    await assertSucceeds(batch.commit());
  });

  test("but not anyone else's", async () => {
    await seedThread('b1', 'bob');
    await assertFails(deleteDoc(doc(as('alice'), 'feedback/b1')));
  });
});
