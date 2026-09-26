import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../data/repositories/progress_providers.dart';
import '../../services/auth/auth_service.dart';
import '../account/sign_in_sheet.dart';
import '../settings/settings_controller.dart';

/// A streak this long is worth protecting.
const kNudgeMinStreak = 3;

/// How long a dismissal lasts.
const kNudgeSnooze = Duration(days: 30);

/// When the dismissal was stored; bumped so the card hides at once.
class _Dismissed extends Notifier<DateTime?> {
  @override
  DateTime? build() => ref.read(settingsStoreProvider).streakNudgeDismissedAt;

  void dismiss() {
    final now = ref.read(clockProvider)();
    ref.read(settingsStoreProvider).dismissStreakNudge(now);
    state = now;
  }
}

final _dismissedProvider = NotifierProvider<_Dismissed, DateTime?>(
  _Dismissed.new,
);

/// Whether Progress should show «احفظ تتابعك»: signed out (an anonymous
/// feedback identity counts as signed out), a streak of three days or more,
/// and not dismissed in the last 30 days.
final streakNudgeVisibleProvider = Provider<bool>((ref) {
  if (!ref.watch(cloudAvailableProvider)) return false;
  if (ref.watch(accountProvider) is SignedIn) return false;
  if (ref.watch(progressStatsProvider).currentStreak < kNudgeMinStreak) {
    return false;
  }
  final dismissed = ref.watch(_dismissedProvider);
  return dismissed == null ||
      ref.watch(clockProvider)().difference(dismissed) >= kNudgeSnooze;
});

/// Board AF 6. Only on Progress — never in the reader or on Home.
class StreakNudge extends ConsumerWidget {
  const StreakNudge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    return Container(
      decoration: BoxDecoration(
        color: t.glowSoft,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.surface,
                    shape: BoxShape.circle,
                  ),
                  child: MishkatIcon(
                    MIcon.cloudSync,
                    color: t.isDark ? t.accentText : t.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.nudgeTitle,
                          style: MishkatType.label(t).copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.nudgeBody,
                          style: MishkatType.caption(
                            t,
                          ).copyWith(height: 1.7, color: t.ink),
                        ),
                        const SizedBox(height: 6),
                        SmallPillButton(
                          label: l.signIn,
                          height: 40,
                          onPressed: () => showSignInFlow(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 2,
            end: 2,
            child: IconCircleButton(
              icon: MIcon.close,
              iconSize: 14,
              background: Colors.transparent,
              color: t.inkMuted,
              semanticLabel: l.dismiss,
              onPressed: ref.read(_dismissedProvider.notifier).dismiss,
            ),
          ),
        ],
      ),
    );
  }
}
