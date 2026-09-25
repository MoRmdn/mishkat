# Firebase

Project `mishkat-al-wird`. Firebase does four jobs here, and reminders are none
of them — they stay local notifications, with no Cloud Messaging:

| Service | Used for | State |
|---|---|---|
| Hosting | `share_site/`: share links, privacy and terms | live |
| Auth + Firestore + App Check | the optional account (sync) and feedback | code done; console setup below |
| Crashlytics + Analytics | `lib/services/diagnostics.dart` | not wired |

The app starts Firebase in `lib/services/cloud_bootstrap.dart`. If that fails —
no config, no Play services — it runs exactly as before accounts existed, with
the account card, feedback and the reader's "report" item hidden.

## Accounts and feedback: console setup (owner, once)

The code, rules and indexes are in the repo. These steps need the owner's
Apple and Google accounts.

### Authentication

1. **Firebase console → Authentication → Sign-in method**, enable:
   - **Anonymous**. Used only when someone sends feedback while signed out, so
     the reply has somewhere to go.
   - **Google**. Then add the Android SHA-1 and SHA-256 fingerprints for both
     the debug and the release keys (Project settings → Your apps → Android):
     ```bash
     cd android && ./gradlew signingReport
     ```
     Re-download `android/app/google-services.json` afterwards. Its
     `oauth_client` must list a web client (type 3), which Credential Manager
     needs as the server client ID.
   - **Apple**. In the Apple Developer account, enable *Sign in with Apple* on
     the App ID `com.mormdn.mishkat`. For Android's web flow, create a
     Services ID and a key, and enter the Services ID, team ID, key ID and
     private key in the Firebase Apple provider. Add Firebase's
     `https://mishkat-al-wird.firebaseapp.com/__/auth/handler` as a return URL
     on the Services ID.
2. iOS: `ios/Runner/GoogleService-Info.plist` must contain `CLIENT_ID` and
   `REVERSED_CLIENT_ID` (re-download after enabling Google). The reversed ID is
   already the URL scheme in `Info.plist`; update it there if the plist changes.
   `Runner.entitlements` carries the Sign in with Apple and App Attest
   entitlements. Enable both capabilities on the App ID.

### Firestore

3. **Firestore → Create database** (production mode, a region near the users,
   for example `me-central1` or `europe-west`).
4. Deploy the rules and indexes from the repo:
   ```bash
   firebase deploy --only firestore
   ```
   Run the rules suite first (below).
5. **Make yourself the owner.** Sign in to the app once, copy your uid from
   Authentication → Users, and create the document `admins/{uid}` (it can be
   empty) in the Firestore console. The rules and the app both read it; the
   Inbox appears in Settings on your next launch. Nothing in the app hard-codes
   an owner.

### App Check

6. **App Check → Apps**: register Play Integrity (Android) and App Attest,
   with the DeviceCheck fallback (iOS). Debug builds use the debug provider:
   the first run logs a debug token, which you add under *Manage debug tokens*.
7. Watch the App Check metrics for a week of real traffic, then **enforce** for
   Firestore and Authentication.

## Rules tests

`firestore_rules_test/` runs `firestore.rules` against the emulator, with one
case per write the app makes. The emulator needs a JDK 21 and `firebase-tools`.

```bash
brew install openjdk@21        # once
cd firestore_rules_test && npm install && npm test
```

## Trying it against the emulator

```bash
firebase emulators:start --only auth,firestore
flutter run --dart-define=FIREBASE_EMULATOR=10.0.2.2   # Android emulator; use localhost on iOS
```

## Data layout

```
users/{uid}                               {lastSyncAt, lastFeedbackAt}
users/{uid}/completions/{day}_{category}  {category, day, completedAt, syncedAt}
users/{uid}/favorites/{thikrId}           {addedAt, deletedAt}
users/{uid}/settings/{app|reminders|prayer}  {…values, updatedAt}
feedback/{id}                             thread (FeedbackThread)
feedback/{id}/messages/{mid}              {from: user|admin, body, createdAt}
admins/{uid}                              console only
counters/feedback                         {next}: the owner's message numbers
```

## Diagnostics (not wired yet)

Firebase's diagnostics role is crash reporting and the four events in
`lib/services/diagnostics.dart`, which exist to answer one question: comparing
`reminder_scheduled` with `reminder_opened`, split by `exact_alarms_allowed` and
by manufacturer, shows whether a whole class of device drops reminders. Never
add events for what someone reads, when they pray, where they are, or what
they write in feedback.

To wire it:

```bash
flutter pub add firebase_crashlytics firebase_analytics
```

1. Implement `FirebaseDiagnostics` (`Diagnostics`), mapping each method to
   `FirebaseAnalytics.instance.logEvent` and `recordError` to
   `FirebaseCrashlytics.instance.recordError`.
2. In `startCloud()`, set
   `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`
   and return `diagnosticsProvider.overrideWithValue(FirebaseDiagnostics())`
   with the other overrides.
3. iOS dSYMs: the project uses Swift Package Manager, so add the Crashlytics
   `upload-symbols` run script from the checked-out package to a build phase
   after "Embed Frameworks", with Input Files
   `${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}` and
   `$(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)`.
