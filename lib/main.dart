import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/local/settings_store.dart';
import 'features/settings/settings_controller.dart';
import 'services/cloud_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Loaded before the first frame so the app opens directly in the stored
  // theme and language — no flash of the wrong appearance.
  final prefs = await SharedPreferences.getInstance();
  await SettingsStore(prefs).migrate();

  // Accounts and feedback only. Reminders, reading and progress never wait
  // on this and work the same when it fails.
  final cloud = await startCloud();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs), ...cloud],
      child: const MishkatApp(),
    ),
  );
}
