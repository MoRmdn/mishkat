import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/theme/mishkat_tokens.dart';
import 'features/account/cloud_scope.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/reminders/reminder_sync_scope.dart';
import 'features/settings/settings_controller.dart';
import 'features/share/share_link_scope.dart';
import 'features/shell/app_shell.dart';
import 'features/update/update_scope.dart';

class MishkatApp extends ConsumerWidget {
  const MishkatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      onGenerateTitle: (context) => L.of(context).appName,
      debugShowCheckedModeBanner: false,
      locale: settings.language.locale,
      supportedLocales: L.supportedLocales,
      localizationsDelegates: const [
        L.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildMishkatTheme(Brightness.light),
      darkTheme: buildMishkatTheme(Brightness.dark),
      themeMode: settings.appearance.themeMode,
      // The required-update screen covers every route, onboarding included.
      builder: (context, child) => UpdateGate(child: child!),
      // Onboarding runs the permission ladder before the shell appears.
      // Skipping it lands on a working home with reminders off.
      home: settings.onboardingComplete
          ? const ReminderSyncScope(
              child: CloudScope(
                child: UpdatePrompts(child: ShareLinkScope(child: AppShell())),
              ),
            )
          : const OnboardingScreen(),
    );
  }
}
