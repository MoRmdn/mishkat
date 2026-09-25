import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../firebase_options.dart';
import 'auth/auth_service.dart';
import 'auth/firebase_auth_service.dart';
import 'feedback/feedback_repository.dart';
import 'feedback/firestore_feedback_repository.dart';
import 'sync/firestore_sync_remote.dart';
import 'sync/sync_remote.dart';

/// `--dart-define=FIREBASE_EMULATOR=10.0.2.2` points Auth and Firestore at
/// the local emulator suite (`firebase emulators:start`) for manual testing.
const _emulatorHost = String.fromEnvironment('FIREBASE_EMULATOR');

/// Starts Firebase for accounts and feedback, and returns the provider
/// overrides that switch them on.
///
/// Never fatal: when Firebase cannot start — no config, no Play services, a
/// sideloaded build — the app runs exactly as it did before accounts
/// existed, with every account and feedback surface hidden.
Future<List<Override>> startCloud() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? const AppleDebugProvider()
          : const AppleAppAttestWithDeviceCheckFallbackProvider(),
    );
    final firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(persistenceEnabled: true);
    if (_emulatorHost.isNotEmpty) {
      firestore.useFirestoreEmulator(_emulatorHost, 8080);
      await FirebaseAuth.instance.useAuthEmulator(_emulatorHost, 9099);
    }
    return [
      cloudAvailableProvider.overrideWithValue(true),
      authServiceProvider.overrideWithValue(FirebaseAuthService()),
      syncRemoteProvider.overrideWithValue(FirestoreSyncRemote(firestore)),
      feedbackRepositoryProvider.overrideWithValue(
        FirestoreFeedbackRepository(firestore),
      ),
    ];
  } catch (e, st) {
    debugPrint('Firebase unavailable, accounts and feedback hidden: $e\n$st');
    return const [];
  }
}
