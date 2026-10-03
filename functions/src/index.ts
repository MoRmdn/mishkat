// Mishkat's Cloud Functions: FCM pushes for the owner's announcements and
// for replies to feedback. Reminders are never sent from here — they are
// local notifications scheduled on the device and need no network.
//
//   cd functions && npm install && npm test
//   firebase deploy --only functions
//
// Needs the Blaze plan. See docs/firebase.md → Push notifications.
//
// Callables, not Firestore triggers: the database is in me-central2, where
// neither Cloud Functions nor Firestore's Eventarc triggers are offered. The
// owner's app writes the document, then calls the function with its id.
// Each send is stamped `pushedAt`, so a retried call never pushes twice.

import { initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import * as logger from 'firebase-functions/logger';
import { setGlobalOptions } from 'firebase-functions/v2';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

import {
  type Announcement,
  announcementMessages,
  asLanguage,
  isDeadToken,
  replyMessage,
} from './messages';

initializeApp();

setGlobalOptions({ region: 'europe-west1', maxInstances: 5 });

/** Only `admins/{uid}` may send — the same document the rules read. */
async function requireOwner(uid: string | undefined): Promise<void> {
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');
  const admin = await getFirestore().doc(`admins/${uid}`).get();
  if (!admin.exists) throw new HttpsError('permission-denied', 'Owner only.');
}

function idArg(data: unknown, key: string): string {
  const value = (data as Record<string, unknown> | null)?.[key];
  if (typeof value !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(value)) {
    throw new HttpsError('invalid-argument', `${key} is required.`);
  }
  return value;
}

/**
 * Pushes `announcements/{id}` to both language topics, each in its own
 * language. Returns whether this call sent it (false: already sent).
 */
export const sendAnnouncement = onCall(async (request) => {
  await requireOwner(request.auth?.uid);
  const id = idArg(request.data, 'id');
  const ref = getFirestore().doc(`announcements/${id}`);

  // Claim the send in a transaction, so two calls cannot both push.
  const claimed = await getFirestore().runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError('not-found', 'No such announcement.');
    if (snap.get('pushedAt')) return null;
    tx.update(ref, { pushedAt: FieldValue.serverTimestamp() });
    return snap.data() as Announcement;
  });
  if (!claimed) return { sent: false };

  try {
    const result = await getMessaging().sendEach(announcementMessages(id, claimed));
    logger.info('announcement sent', {
      id,
      success: result.successCount,
      failure: result.failureCount,
    });
    return { sent: true };
  } catch (e) {
    // Release the claim so the owner can retry.
    await ref.update({ pushedAt: FieldValue.delete() });
    throw e;
  }
});

/**
 * Pushes the owner's message `feedback/{threadId}/messages/{messageId}` to
 * every device the sender registered, in each device's language, and forgets
 * tokens FCM says are dead.
 */
export const notifyReply = onCall(async (request) => {
  await requireOwner(request.auth?.uid);
  const threadId = idArg(request.data, 'threadId');
  const messageId = idArg(request.data, 'messageId');
  const db = getFirestore();
  const ref = db.doc(`feedback/${threadId}/messages/${messageId}`);

  const body = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError('not-found', 'No such message.');
    if (snap.get('from') !== 'admin' || snap.get('pushedAt')) return null;
    tx.update(ref, { pushedAt: FieldValue.serverTimestamp() });
    return String(snap.get('body') ?? '');
  });
  if (body === null) return { sent: 0 };

  const uid = (await db.doc(`feedback/${threadId}`).get()).get('uid');
  if (typeof uid !== 'string') return { sent: 0 };
  const devices = await db.collection(`users/${uid}/devices`).get();
  if (devices.empty) return { sent: 0 };

  const result = await getMessaging().sendEach(
    devices.docs.map((d) =>
      replyMessage(d.get('token'), asLanguage(d.get('lang')), threadId, body),
    ),
  );
  const dead = result.responses.flatMap((r, i) =>
    !r.success && isDeadToken(r.error?.code) ? [devices.docs[i].ref] : [],
  );
  await Promise.all(dead.map((d) => d.delete()));
  logger.info('reply sent', {
    threadId,
    devices: devices.size,
    success: result.successCount,
    pruned: dead.length,
  });
  return { sent: result.successCount };
});
