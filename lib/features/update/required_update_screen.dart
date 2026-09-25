import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../services/update/update_policy.dart';
import 'update_controller.dart';
import 'update_widgets.dart';

/// «يلزم تحديث مشكاة» (board "Mishkat Update Required", required): drawn
/// over everything, onboarding included, while the installed version is
/// below `min_supported_version`.
///
/// Reading the bundled athkar never touches the server, so «متابعة القراءة
/// فقط» can open the app behind it; sync, the account and reminder changes
/// stay stopped. Reminders already scheduled keep firing.
class RequiredUpdateScreen extends ConsumerWidget {
  const RequiredUpdateScreen({super.key, required this.update});

  final RequiredUpdate update;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final phase = ref.watch(updateProvider.select((s) => s.phase));
    final progress = ref.watch(updateProvider.select((s) => s.progress));
    final controller = ref.read(updateProvider.notifier);
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    final cta = ios ? l.updateFromAppStore : l.updateFromPlay;

    final Widget actions = switch (phase) {
      UpdatePhase.updating => _UpdatingCard(progress: progress),
      UpdatePhase.offline => _OfflineCard(
        onRetry: controller.startRequiredUpdate,
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: cta,
            icon: MIcon.download,
            onPressed: controller.startRequiredUpdate,
          ),
          if (update.allowReading) ...[
            const SizedBox(height: 4),
            _AccentTextButton(
              label: l.keepReadingOnly,
              onPressed: controller.keepReading,
            ),
          ],
        ],
      ),
    };

    return Scaffold(
      backgroundColor: t.bg,
      body: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Hero(height: (box.maxHeight * 0.47).clamp(250, 340)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(26, 6, 26, 0),
                    child: Column(
                      children: [
                        VersionStep(
                          from: update.installed,
                          to: update.target,
                          languageCode: lang,
                          semanticLabel: l.updateVersions(
                            update.installed.display(lang),
                            update.target.display(lang),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Semantics(
                          header: true,
                          child: Text(
                            l.updateRequiredTitle,
                            textAlign: TextAlign.center,
                            style: MishkatType.title(t).copyWith(fontSize: 23),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.updateRequiredBody,
                          textAlign: TextAlign.center,
                          style: MishkatType.bodyMuted(
                            t,
                          ).copyWith(fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(26, 20, 26, 26),
                    child: AnimatedSwitcher(
                      duration: Motion.of(context, Motion.base),
                      child: KeyedSubtree(key: ValueKey(phase), child: actions),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The primary panel with the two arches of the niche behind the mark, and
/// the page's colour rising into it along a shallow curve.
class _Hero extends StatelessWidget {
  const _Hero({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final markSize = height * 96 / 340;
    return SizedBox(
      height: height,
      child: ClipRect(
        child: CustomPaint(
          painter: _HeroPainter(
            panel: t.primary,
            outer: Color.alphaBlend(
              t.onPrimary.withValues(alpha: t.isDark ? 0.04 : 0.07),
              t.primary,
            ),
            inner: Color.alphaBlend(
              t.onPrimary.withValues(alpha: t.isDark ? 0.07 : 0.11),
              t.primary,
            ),
            page: t.bg,
          ),
          child: Align(
            alignment: const Alignment(0, 0.08),
            child: GlowingMark(
              box: markSize * 132 / 96,
              halo: t.cta.withValues(alpha: t.isDark ? 0.22 : 0.35),
              mark: t.isDark
                  ? BrandMark(size: markSize)
                  : BrandMark(
                      size: markSize,
                      tile: t.onPrimary,
                      arch: t.primary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  const _HeroPainter({
    required this.panel,
    required this.outer,
    required this.inner,
    required this.page,
  });

  final Color panel;
  final Color outer;
  final Color inner;
  final Color page;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = panel);

    // The board's 260×300 arches in a 340-tall panel, scaled with it.
    final s = size.height / 340;
    final left = size.width / 2 - 130 * s;
    final bottom = size.height + 2 * s;
    Path arch(double inset, double radius, double springs) {
      final x0 = left + inset * s, x1 = left + (260 - inset) * s;
      return Path()
        ..moveTo(x0, bottom)
        ..lineTo(x0, bottom - springs * s)
        ..arcToPoint(
          Offset(x1, bottom - springs * s),
          radius: Radius.circular(radius * s),
        )
        ..lineTo(x1, bottom)
        ..close();
    }

    canvas.drawPath(arch(0, 130, 170), Paint()..color = outer);
    canvas.drawPath(arch(40, 90, 166), Paint()..color = inner);

    // M0 40V28 C60 8 120 0 170 0 s110 8 170 28 v12z, stretched to the width.
    final w = size.width / 340, h = size.height;
    final curve = Path()
      ..moveTo(0, h + 1)
      ..lineTo(0, h - 12)
      ..cubicTo(60 * w, h - 32, 120 * w, h - 40, 170 * w, h - 40)
      ..cubicTo(220 * w, h - 40, 280 * w, h - 32, 340 * w, h - 12)
      ..lineTo(340 * w, h + 1)
      ..close();
    canvas.drawPath(curve, Paint()..color = page);
  }

  @override
  bool shouldRepaint(_HeroPainter old) =>
      old.panel != panel ||
      old.outer != outer ||
      old.inner != inner ||
      old.page != page;
}

/// «متابعة القراءة فقط»: a text action in the accent colour.
class _AccentTextButton extends StatelessWidget {
  const _AccentTextButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Sizes.touchMin),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kUiFont,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: t.accentText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdatingCard extends StatelessWidget {
  const _UpdatingCard({required this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.updateUpdating,
                  style: MishkatType.label(t).copyWith(fontSize: 13.5),
                ),
              ),
              Text(
                percentLabel(progress, lang),
                style: MishkatType.label(
                  t,
                ).copyWith(fontSize: 13.5, color: t.accentText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          UpdateProgressBar(value: progress, height: 8),
          const SizedBox(height: 10),
          Text(
            l.updateAutoRestart,
            style: MishkatType.caption(t).copyWith(fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _OfflineCard extends StatelessWidget {
  const _OfflineCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: t.errorSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.surfaceRaised,
                  shape: BoxShape.circle,
                ),
                child: MishkatIcon(MIcon.cloudOff, color: t.error, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.updateOfflineTitle,
                      style: MishkatType.label(t).copyWith(fontSize: 14),
                    ),
                    Text(l.updateOfflineBody, style: MishkatType.caption(t)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        PrimaryButton(label: L.of(context).retry, onPressed: onRetry),
      ],
    );
  }
}
