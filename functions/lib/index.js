"use strict";
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
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.notifyReply = exports.sendAnnouncement = void 0;
const app_1 = require("firebase-admin/app");
const firestore_1 = require("firebase-admin/firestore");
const messaging_1 = require("firebase-admin/messaging");
const logger = __importStar(require("firebase-functions/logger"));
const v2_1 = require("firebase-functions/v2");
const https_1 = require("firebase-functions/v2/https");
const messages_1 = require("./messages");
(0, app_1.initializeApp)();
(0, v2_1.setGlobalOptions)({ region: 'europe-west1', maxInstances: 5 });
/** Only `admins/{uid}` may send — the same document the rules read. */
async function requireOwner(uid) {
    if (!uid)
        throw new https_1.HttpsError('unauthenticated', 'Sign in first.');
    const admin = await (0, firestore_1.getFirestore)().doc(`admins/${uid}`).get();
    if (!admin.exists)
        throw new https_1.HttpsError('permission-denied', 'Owner only.');
}
function idArg(data, key) {
    const value = data?.[key];
    if (typeof value !== 'string' || !/^[A-Za-z0-9_-]{1,128}$/.test(value)) {
        throw new https_1.HttpsError('invalid-argument', `${key} is required.`);
    }
    return value;
}
/**
 * Pushes `announcements/{id}` to both language topics, each in its own
 * language. Returns whether this call sent it (false: already sent).
 */
exports.sendAnnouncement = (0, https_1.onCall)(async (request) => {
    await requireOwner(request.auth?.uid);
    const id = idArg(request.data, 'id');
    const ref = (0, firestore_1.getFirestore)().doc(`announcements/${id}`);
    // Claim the send in a transaction, so two calls cannot both push.
    const claimed = await (0, firestore_1.getFirestore)().runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (!snap.exists)
            throw new https_1.HttpsError('not-found', 'No such announcement.');
        if (snap.get('pushedAt'))
            return null;
        tx.update(ref, { pushedAt: firestore_1.FieldValue.serverTimestamp() });
        return snap.data();
    });
    if (!claimed)
        return { sent: false };
    try {
        const result = await (0, messaging_1.getMessaging)().sendEach((0, messages_1.announcementMessages)(id, claimed));
        logger.info('announcement sent', {
            id,
            success: result.successCount,
            failure: result.failureCount,
        });
        return { sent: true };
    }
    catch (e) {
        // Release the claim so the owner can retry.
        await ref.update({ pushedAt: firestore_1.FieldValue.delete() });
        throw e;
    }
});
/**
 * Pushes the owner's message `feedback/{threadId}/messages/{messageId}` to
 * every device the sender registered, in each device's language, and forgets
 * tokens FCM says are dead.
 */
exports.notifyReply = (0, https_1.onCall)(async (request) => {
    await requireOwner(request.auth?.uid);
    const threadId = idArg(request.data, 'threadId');
    const messageId = idArg(request.data, 'messageId');
    const db = (0, firestore_1.getFirestore)();
    const ref = db.doc(`feedback/${threadId}/messages/${messageId}`);
    const body = await db.runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (!snap.exists)
            throw new https_1.HttpsError('not-found', 'No such message.');
        if (snap.get('from') !== 'admin' || snap.get('pushedAt'))
            return null;
        tx.update(ref, { pushedAt: firestore_1.FieldValue.serverTimestamp() });
        return String(snap.get('body') ?? '');
    });
    if (body === null)
        return { sent: 0 };
    const uid = (await db.doc(`feedback/${threadId}`).get()).get('uid');
    if (typeof uid !== 'string')
        return { sent: 0 };
    const devices = await db.collection(`users/${uid}/devices`).get();
    if (devices.empty)
        return { sent: 0 };
    const result = await (0, messaging_1.getMessaging)().sendEach(devices.docs.map((d) => (0, messages_1.replyMessage)(d.get('token'), (0, messages_1.asLanguage)(d.get('lang')), threadId, body)));
    const dead = result.responses.flatMap((r, i) => !r.success && (0, messages_1.isDeadToken)(r.error?.code) ? [devices.docs[i].ref] : []);
    await Promise.all(dead.map((d) => d.delete()));
    logger.info('reply sent', {
        threadId,
        devices: devices.size,
        success: result.successCount,
        pruned: dead.length,
    });
    return { sent: result.successCount };
});
//# sourceMappingURL=index.js.map