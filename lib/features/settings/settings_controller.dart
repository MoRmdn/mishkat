import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/settings_store.dart';
import '../../data/models/app_settings.dart';

/// Overridden in `main()` once preferences have loaded, so settings are
/// available synchronously from the first frame.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) =>
      throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final settingsStoreProvider = Provider<SettingsStore>(
  (ref) => SettingsStore(ref.watch(sharedPreferencesProvider)),
);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsStoreProvider).read();

  void _update(AppSettings next) {
    state = next;
    // Fire-and-forget: the in-memory state is the source of truth for the UI,
    // and a failed write only costs the preference on next launch.
    ref.read(settingsStoreProvider).write(next);
  }

  void setAppearance(AppearanceMode v) =>
      _update(state.copyWith(appearance: v));
  void setLanguage(AppLanguage v) => _update(state.copyWith(language: v));
  void setTextSize(ThikrSize v) => _update(state.copyWith(textSize: v));
  void toggleQuranFont() =>
      _update(state.copyWith(useQuranFont: !state.useQuranFont));
  void completeOnboarding() =>
      _update(state.copyWith(onboardingComplete: true));

  void stepTextSize(int delta) {
    final i = (state.textSize.index + delta).clamp(
      0,
      ThikrSize.values.length - 1,
    );
    setTextSize(ThikrSize.values[i]);
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
