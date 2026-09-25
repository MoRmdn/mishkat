import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/surfaces.dart';
import 'update_controller.dart';
import 'update_widgets.dart';

/// Home's card for an update downloading in the background, then «التحديث
/// جاهز» with «أعد التشغيل». Takes no room otherwise. Android only: iOS
/// never downloads in place.
class UpdateHomeCard extends ConsumerWidget {
  const UpdateHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(updateProvider);
    final Widget card = switch (state.phase) {
      UpdatePhase.downloading => _DownloadingCard(progress: state.progress),
      UpdatePhase.ready => _ReadyCard(
        onRestart: ref.read(updateProvider.notifier).restartToUpdate,
      ),
      _ => const SizedBox.shrink(),
    };
    if (card is SizedBox) return card;
    return Padding(padding: const EdgeInsets.only(bottom: 14), child: card);
  }
}

class _DownloadingCard extends StatelessWidget {
  const _DownloadingCard({required this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MishkatIcon(
                  MIcon.download,
                  color: t.isDark ? t.accentText : t.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.updateDownloading,
                    style: MishkatType.label(t).copyWith(fontSize: 13.5),
                  ),
                ),
                Text(
                  percentLabel(progress, lang),
                  style: MishkatType.label(
                    t,
                  ).copyWith(fontSize: 13, color: t.accentText),
                ),
              ],
            ),
            const SizedBox(height: 10),
            UpdateProgressBar(value: progress),
            const SizedBox(height: 10),
            Text(
              l.updateDownloadingHint,
              style: MishkatType.caption(t).copyWith(fontSize: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyCard extends StatelessWidget {
  const _ReadyCard({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.glowSoft,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Row(
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
                MIcon.check,
                color: t.isDark ? t.accentText : t.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.updateReady,
                    style: MishkatType.label(t).copyWith(fontSize: 13.5),
                  ),
                  Text(
                    l.updateReadyHint,
                    style: MishkatType.caption(
                      t,
                    ).copyWith(fontSize: 11.5, color: t.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SmallPillButton(label: l.updateRestart, onPressed: onRestart),
          ],
        ),
      ),
    );
  }
}

/// «جارٍ تطبيق التحديث…» over everything while Play installs and restarts.
class UpdateRestartingOverlay extends StatelessWidget {
  const UpdateRestartingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Material(
      color: t.primary,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlowingMark(
              box: 120,
              halo: t.cta.withValues(alpha: t.isDark ? 0.22 : 0.3),
              mark: t.isDark
                  ? const BrandMark(size: 88)
                  : BrandMark(size: 88, tile: t.onPrimary, arch: t.primary),
            ),
            const SizedBox(height: 18),
            Text(
              l.brandName,
              style: MishkatType.title(
                t,
              ).copyWith(fontSize: 22, color: t.onPrimary),
            ),
            const SizedBox(height: 18),
            Semantics(
              liveRegion: true,
              child: Text(
                l.updateApplying,
                style: MishkatType.caption(
                  t,
                ).copyWith(fontSize: 12.5, color: t.onPrimaryMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Behind the required screen after «متابعة القراءة فقط»: why a change did
/// not take, and the way back to the update.
class UpdateLockedBanner extends ConsumerWidget {
  const UpdateLockedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    return NoticeBanner(
      title: l.updateLockedTitle,
      body: l.updateLockedBody,
      actionLabel: l.updateAction,
      onAction: ref.read(updateProvider.notifier).showRequired,
    );
  }
}
