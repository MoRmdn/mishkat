import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/surfaces.dart';
import '../reminders/reminder_controller.dart';
import '../settings/settings_controller.dart';

/// One rung of the permission ladder.
///
/// Each screen asks for exactly one thing and states what happens if it is
/// declined; no denial blocks the app.
enum OnboardingStep { intro, notifications, exactAlarm, battery }

/// Boards 1.1–1.4.
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
    return Scaffold(
      backgroundColor: t.bg,
      body: _step == OnboardingStep.intro
          ? _Welcome(onStart: _primary, onSkip: _secondary, busy: _busy)
          : _PermissionStep(
              step: _step,
              busy: _busy,
              onPrimary: _primary,
              onSecondary: _secondary,
            ),
    );
  }
}

/// Step dots: done, current (a wider pill), still to come.
class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.onPrimary});

  final int current;

  /// On the welcome hero the dots sit on the primary panel.
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final total = OnboardingStep.values.length;
    Color colour(int i) {
      if (onPrimary) {
        return i == current
            ? t.cta
            : Color.alphaBlend(t.onPrimary.withValues(alpha: 0.3), t.primary);
      }
      if (i == current) return t.glow;
      return i < current ? (t.isDark ? t.ink : t.primary) : t.trackOff;
    }

    return Semantics(
      label: l.onbStep('${current + 1}', '$total'),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            AnimatedContainer(
              duration: Motion.of(context, Motion.base),
              width: i == current ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: colour(i),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 1.1: the aubergine hero with the lamp, then the promise.
class _Welcome extends StatelessWidget {
  const _Welcome({
    required this.onStart,
    required this.onSkip,
    required this.busy,
  });

  final VoidCallback onStart, onSkip;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.51).clamp(
      260.0,
      370.0 + top,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: heroHeight,
          padding: EdgeInsets.fromLTRB(26, top + 14, 26, 24),
          decoration: BoxDecoration(
            color: t.primary,
            border: t.isDark
                ? Border(bottom: BorderSide(color: t.glowLine))
                : null,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(34),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: BrandMark.onPrimary(
                    context,
                    size: (heroHeight * 0.38).clamp(96.0, 140.0),
                  ),
                ),
              ),
              const _Dots(current: 0, onPrimary: true),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(26, 28, 26, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l.onb1Title,
                    style: MishkatType.display(t).copyWith(height: 1.4),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l.onb1Body,
                  style: MishkatType.bodyMuted(t).copyWith(height: 1.9),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 14),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: l.onb1Primary,
                    onPressed: busy ? null : onStart,
                  ),
                ),
                const SizedBox(width: 10),
                SecondaryButton(
                  label: l.onb1Secondary,
                  expand: false,
                  muted: true,
                  onPressed: onSkip,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 1.2–1.4: one permission, why it matters, and what happens without it.
class _PermissionStep extends ConsumerWidget {
  const _PermissionStep({
    required this.step,
    required this.busy,
    required this.onPrimary,
    required this.onSecondary,
  });

  final OnboardingStep step;
  final bool busy;
  final VoidCallback onPrimary, onSecondary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final vendor = ref.watch(permissionsProvider).manufacturer;

    final (icon, title, body, note, primary, secondary) = switch (step) {
      OnboardingStep.notifications => (
        MIcon.bell,
        l.onb2Title,
        l.onb2Body,
        l.onb2Note,
        l.onb2Primary,
        l.onb2Secondary,
      ),
      OnboardingStep.exactAlarm => (
        MIcon.clock,
        l.onb3Title,
        l.onb3Body,
        l.onb3Note,
        l.onb3Primary,
        l.onb3Secondary,
      ),
      _ => (
        MIcon.battery,
        l.onb4Title,
        l.onb4Body,
        vendor.isEmpty ? l.onb4Note : l.onb4NoteVendor(vendor),
        l.onb4Primary,
        l.onb4Secondary,
      ),
    };
    final isBattery = step == OnboardingStep.battery;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _Dots(current: step.index, onPrimary: false),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconTile(icon),
                    const SizedBox(height: 26),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: MishkatType.display(
                          t,
                        ).copyWith(fontSize: 28, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      body,
                      style: MishkatType.bodyMuted(t).copyWith(height: 1.9),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: isBattery ? 12 : 14,
                      ),
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(Radii.lg),
                      ),
                      child: Row(
                        children: [
                          if (isBattery) ...[
                            MishkatIcon(
                              MIcon.device,
                              color: t.inkMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Text(
                              note,
                              style: MishkatType.caption(t).copyWith(
                                fontSize: isBattery ? 12.5 : 13,
                                height: 1.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
            child: Column(
              children: [
                PrimaryButton(
                  label: primary,
                  onPressed: busy ? null : onPrimary,
                ),
                const SizedBox(height: 6),
                TextAction(label: secondary, onPressed: onSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
