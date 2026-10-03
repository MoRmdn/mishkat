# Accounts and feedback: parked, and how to relaunch

**Status (2026-10-03):** this feature is parked. The code is kept on the
branch `feat/accounts-feedback` and on the tag `accounts-feedback-parked`.
Nothing for it runs on the Firebase project `mishkat-al-wird`.

## What was removed from Firebase

| Piece | State now | How it was done |
|---|---|---|
| Cloud Functions (`notifyReply`, `sendAnnouncement`) | Deleted | `firebase functions:delete` (those came from `feat/push-announcements`) |
| Firestore rules | **Deny everything** | Deployed a rules file with `allow read, write: if false` |
| Firestore indexes | All 6 deleted | Deployed an empty `firestore.indexes.json` |
| Firestore data (`users`, `feedback`, `admins`, `counters`, `announcements`) | Test data only. Delete it by hand (see below) | — |
| Auth providers (Apple, Google, Anonymous), App Check | Still configured in the console | Untouched; turn them off by hand if you want |

Because the rules deny everything, any build of this branch that talks to
the live project will fail quietly: sign-in may work, but sync and feedback
won't save. Release builds of other branches don't use Firestore, so they
aren't affected.

### Deleting the leftover data

```bash
firebase firestore:delete --all-collections --project mishkat-al-wird
```

Or in the console: Firestore → Data → delete each collection.

## Relaunching: step by step

1. **Get the code back**
   ```bash
   git checkout feat/accounts-feedback      # or: git checkout -b relaunch accounts-feedback-parked
   ```
   If you refactor first, keep `firestore.rules`, `firestore.indexes.json`
   and `firestore_rules_test/` in step with the new code.

2. **Test the rules against the emulator** (needs a JDK, see `docs/firebase.md` → Rules tests)
   ```bash
   cd firestore_rules_test && npm install && npm test
   ```

3. **Deploy the real rules and indexes** from the repo root
   ```bash
   firebase deploy --only firestore --project mishkat-al-wird
   ```
   Indexes take a few minutes to build. The owner inbox filters fail until they're ready.

4. **Check the console setup** in `docs/firebase.md` → "Accounts and feedback: console setup":
   - Authentication: Anonymous, Google (SHA-1/SHA-256 for debug and release keys), Apple (Services ID + key, needed to revoke tokens on account deletion)
   - App Check: Play Integrity + App Attest, enforce after a week of traffic

5. **Make yourself the owner again.** The data was deleted, so sign in once,
   copy your uid from Authentication → Users, and create an empty document `admins/{uid}`.

6. **Smoke test on a real phone:** sign in with Apple and Google, sync on two
   devices, send feedback signed out, reply from the inbox, delete the account.

7. **Before the store release:** make sure the privacy policy (`docs/privacy-policy.md`,
   `share_site/public/*privacy.html`) and the store privacy answers
   (`docs/store-listing.md`) are published to match. They describe what an account stores.

## Push notifications (separate, later)

Reply and announcement pushes live on `feat/push-announcements` and need Cloud
Functions (Blaze plan, APNs key). To bring them back after the steps above:

```bash
git checkout feat/push-announcements
firebase deploy --only functions,firestore --project mishkat-al-wird
```
