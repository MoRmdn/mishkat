import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icons.dart';
import '../reminders/reminder_controller.dart';
import '../settings/settings_controller.dart';

/// One rung of the permission ladder.
///
/// Each screen asks for exactly one thing and states what happens if it is
/// declined; no denial blocks the app.
enum OnboardingStep { intro, notifications, exactAlarm, battery }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  OnboardingStep _step = OnboardingStep.intro;
  bool _busy = false;

  void _finish() => ref.read(settingsProvider.notifier).completeOnboarding();

  void _next() {
    final i = _step.index;
    if (i + 1 < OnboardingStep.values.length) {
      setState(() => _step = OnboardingStep.values[i + 1]);
    } else {
      _finish();
    }
  }

  Future<void> _primary() async {
    if (_busy) return;
    setState(() => _busy = true);
    final permissions = ref.read(permissionsProvider.notifier);
    try {
      switch (_step) {
        case OnboardingStep.intro:
          break;
        case OnboardingStep.notifications:
          await permissions.requestNotifications();
        case OnboardingStep.exactAlarm:
          await permissions.requestExactAlarms();
        case OnboardingStep.battery:
          await permissions.requestBatteryExemption();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) _next();
  }

  void _secondary() {
    // Skipping from the first screen lands on a working home with reminders
    // off; skipping a permission just moves to the next rung.
    if (_step == OnboardingStep.intro) {
      _finish();
    } else {
      _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final copy = _copyFor(l, _step);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [t.onb1, t.onb2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    for (final s in OnboardingStep.values) ...[
                      Expanded(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: s.index <= _step.index ? t.gold : t.onbLine,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (s != OnboardingStep.values.last)
                        const SizedBox(width: 6),
                    ],
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 78,
                        height: 78,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: t.onbFill,
                          border: Border.all(color: t.onbLine),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: StrokeIcon(
                          AppIcons.mark,
                          color: t.gold,
                          size: 34,
                          strokeWidth: 1.4,
                          extraShapes: AppIcons.markShapes,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        copy.title,
                        style: TextStyle(
                          fontSize: 30,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: t.onbInk,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        copy.body,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.85,
                          color: t.onbDim,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: t.onbFill,
                          border: Border.all(color: t.onbLine),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              copy.noteLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                                color: t.gold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              copy.note,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.8,
                                color: t.onbDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _primary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    decoration: BoxDecoration(
                      color: t.gold,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      copy.primary,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: t.onGold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _secondary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Text(
                      copy.secondary,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: t.onbDim),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingCopy {
  const _OnboardingCopy({
    required this.title,
    required this.body,
    required this.noteLabel,
    required this.note,
    required this.primary,
    required this.secondary,
  });

  final String title, body, noteLabel, note, primary, secondary;
}

_OnboardingCopy _copyFor(L l, OnboardingStep step) => switch (step) {
  OnboardingStep.intro => _OnboardingCopy(
    title: l.onb1Title,
    body: l.onb1Body,
    noteLabel: l.onb1NoteLabel,
    note: l.onb1Note,
    primary: l.onb1Primary,
    secondary: l.onb1Secondary,
  ),
  OnboardingStep.notifications => _OnboardingCopy(
    title: l.onb2Title,
    body: l.onb2Body,
    noteLabel: l.onb2NoteLabel,
    note: l.onb2Note,
    primary: l.onb2Primary,
    secondary: l.onb2Secondary,
  ),
  OnboardingStep.exactAlarm => _OnboardingCopy(
    title: l.onb3Title,
    body: l.onb3Body,
    noteLabel: l.onb3NoteLabel,
    note: l.onb3Note,
    primary: l.onb3Primary,
    secondary: l.onb3Secondary,
  ),
  OnboardingStep.battery => _OnboardingCopy(
    title: l.onb4Title,
    body: l.onb4Body,
    noteLabel: l.onb4NoteLabel,
    note: l.onb4Note,
    primary: l.onb4Primary,
    secondary: l.onb4Secondary,
  ),
};
