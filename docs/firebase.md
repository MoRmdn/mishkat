# Firebase (Crashlytics + Analytics)

Not wired up in this repo. It needs a Firebase project, which only the app's
owner can create — `flutterfire configure` signs in with a Google account and
writes `lib/firebase_options.dart` plus the platform config files.

Firebase's role here is **only** crash reporting and the four events defined in
`lib/services/diagnostics.dart`. There is no Auth, no Firestore, no Cloud
Messaging: the reminders are local notifications and the app works offline.

## What to run

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project <your-firebase-project>
flutter pub add firebase_core firebase_crashlytics firebase_analytics
```

That writes `lib/firebase_options.dart`, `android/app/google-services.json` and
`ios/Runner/GoogleService-Info.plist`. Add the Google services Gradle plugin to
`android/settings.gradle.kts` and `android/app/build.gradle.kts` as the
flutterfire output instructs.

## What to add

1. A `FirebaseDiagnostics` implementing `Diagnostics`, mapping each method to
   `FirebaseAnalytics.instance.logEvent` and `recordError` to
   `FirebaseCrashlytics.instance.recordError`.

2. In `main()`, before `runApp`:

```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

3. Override the provider:

```dart
diagnosticsProvider.overrideWithValue(FirebaseDiagnostics()),
```

## iOS dSYMs

Crashlytics cannot symbolicate release crashes without them. Add a run-script
build phase to the Runner target, after "Embed Frameworks":

```
"${PODS_ROOT}/FirebaseCrashlytics/upload-symbols" -gsp "${PROJECT_DIR}/Runner/GoogleService-Info.plist" -p ios "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
```

with Input Files `${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}` and
`$(TARGET_BUILD_DIR)/$(INFOPLIST_PATH)`.

## The one question these events exist to answer

Reminders fail silently in the field. Comparing `reminder_scheduled` against
`reminder_opened`, split by `exact_alarms_allowed` and by device manufacturer,
is how you find out that a whole class of device is dropping them. Nothing else
here is worth collecting.
