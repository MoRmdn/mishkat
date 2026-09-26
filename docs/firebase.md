# Firebase

Project `mishkat-al-wird`. Firebase does five jobs here, and reminders are none
of them — they stay local notifications, with no Cloud Messaging:

| Service | Used for | State |
|---|---|---|
| Hosting | `share_site/`: share links, privacy and terms | live |
| Auth + Firestore + App Check | the optional account (sync) and feedback | code done; console setup below |
| Remote Config | optional and required app updates | code done; parameters below |
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
     the App ID `com.mormdn.mishkat`. Create a Services ID and a key with
     Sign in with Apple enabled, and enter the Services ID, team ID, key ID
     and private key in the Firebase Apple provider. **Do this even for an
     iOS-only release:** sign-in works without them, but deleting an account
     must revoke the user's Apple token (App Store guideline 5.1.1(v)), and
     Firebase can only revoke with that key. Without it the app still
     deletes the account and logs `Apple token revocation failed`, and the
     person stays listed under Settings → Apple ID → Sign in with Apple. The
     same Services ID serves Android's web flow. Add Firebase's
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

## Remote Config: app updates

The update gate (board "Mishkat Update Required",
`lib/features/update/`, rules in `lib/services/update/update_policy.dart`)
reads four parameters. Create them in **Remote Config → Parameters**; until
they exist the defaults apply and nothing is ever suggested or required.

| Parameter | Type | Default | Meaning |
|---|---|---|---|
| `recommended_version` | string | `0.0.0` | Below it, the «تحديث جديد متاح» sheet is offered — once per version, then at most every 3 days. |
| `min_supported_version` | string | `0.0.0` | Below it, «يلزم تحديث مشكاة» covers the app; sync, the account and reminder changes stop. |
| `release_notes` | JSON string | empty | What the sheet lists for `recommended_version` (below). Shown only when its `version` matches. |
| `update_allow_reading` | boolean | `true` | Offers «متابعة القراءة فقط» behind the required screen. |

`release_notes` has the same shape as a release in the bundled
`assets/data/changelog.json`; `icon` is an `MIcon` name, and a name this
build does not know shows ⓘ:

```json
{"version": "1.3.0", "notes": [
  {"icon": "bell", "ar": "تذكيرات أدق على أجهزة شاومي وهواوي", "en": "More accurate reminders on Xiaomi and Huawei"}
]}
```

- **Per platform**: iOS review lags Android, so give each parameter a
  *Platform* condition (Android / iOS) rather than inventing separate keys.
- **Raise `min_supported_version` only once the store build is live** on that
  platform; otherwise the button leads to a store that cannot install it.
- A version is `major.minor.patch`; a mistyped value switches the gate off
  rather than blocking anyone.
- Fetches time out after 10 s and are throttled to one an hour in release.
  The last activated values persist, so a required update holds offline; a
  failed fetch never blocks a launch.
- Android installs through Play In-App Updates, which only works for a build
  installed from Play — test it from an internal-testing track. Everywhere
  else the buttons open the store page (`storePageUri` in
  `lib/core/store_links.dart`; iOS needs `kAppStoreId`).

## Rules tests

`firestore_rules_test/` runs `firestore.rules` against the emulator, with one
case per write the app makes. The emulator needs a JDK and `firebase-tools`;
Android Studio's bundled one works:

```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
cd firestore_rules_test && npm install && npm test
```

## Trying it against the emulator

```bash
firebase emulators:start --only auth,firestore
flutter run --dart-define=FIREBASE_EMULATOR=10.0.2.2   # Android emulator; use localhost on iOS
```

## Data layout

Laid out so a sync touches few documents: a full pull reads two documents plus
one per month of history (about twelve a year), and a resume pull reads only
the months changed since the last one, normally one.

```
users/{uid}                        {schema: 2, profile, providers, createdAt,
                                    lastSignInAt, app, lastActiveAt,
                                    lastFeedbackAt}
  profile: {displayName, email, emailVerified, photoUrl, givenName,
            familyName, locale, hostedDomain, isPrivateEmail}
  app:     {version, platform, language}
users/{uid}/data/settings          {app|reminders|prayer: {…values, updatedAt}}
users/{uid}/data/favorites         {items: {thikrId: {addedAt, deletedAt}}, updatedAt}
users/{uid}/completions/{yyyy-MM}  {days: {'2026-09-25': {morning: at, …}}, updatedAt}
feedback/{id}                      thread (FeedbackThread)
feedback/{id}/messages/{mid}       {from: user|admin, body, createdAt}
admins/{uid}                       console only
counters/feedback                  {next}: the owner's message numbers
```

`users/{uid}` is written on sign-in (with the provider's claims) and once per
launch (`app`, `lastActiveAt`); fields a write leaves out keep their value, so
Apple withholding the name after the first sign-in erases nothing. No
location or time zone is stored. The first layout (`favorites/{id}`,
`settings/{group}`, `completions/{day}_{category}`) may remain on early test
accounts; the rules allow only reading and deleting it, account deletion
clears it, and the next full sync rewrites the data in the new layout.

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
