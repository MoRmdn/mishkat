import 'package:flutter/material.dart';

import '../../core/format/numerals.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../services/update/app_version.dart';
import '../../services/update/release_notes.dart';

/// The brand mark on a slowly breathing halo: the update sheet, the required
/// screen's hero and the restart splash.
///
/// Breathes a few times and rests rather than looping forever — a screen
/// that never settles also never lets a widget test settle — and not at all
/// when motion is reduced.
class GlowingMark extends StatefulWidget {
  const GlowingMark({
    super.key,
    required this.box,
    required this.mark,
    required this.halo,
  });

  /// The halo's diameter; the mark sits centred inside it.
  final double box;
  final BrandMark mark;
  final Color halo;

  @override
  State<GlowingMark> createState() => _GlowingMarkState();
}

class _GlowingMarkState extends State<GlowingMark>
    with SingleTickerProviderStateMixin {
  static const _breaths = 3;
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _breathe();
    }
  }

  Future<void> _breathe() async {
    try {
      for (var i = 0; i < _breaths && mounted; i++) {
        await _controller.forward();
        await _controller.reverse();
      }
    } on TickerCanceled {
      // Disposed mid-breath.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.box,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final v = Curves.easeInOut.transform(_controller.value);
              return Transform.scale(
                scale: 1 + 0.25 * v,
                child: Opacity(
                  opacity: 1 - 0.65 * v,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.halo,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          widget.mark,
        ],
      ),
    );
  }
}

/// A 26px pill with a version: «الإصدار ١٫٣٫٠», or either end of `1.2.0 → 1.3.0`.
class VersionChip extends StatelessWidget {
  const VersionChip(this.label, {super.key, this.current = true});

  final String label;

  /// The version being moved to (rose); false is the one being left (grey).
  final bool current;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      constraints: const BoxConstraints(minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: current ? t.glowSoft : t.lineSoft,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kUiFont,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: current ? t.accentText : t.inkMuted,
        ),
      ),
    );
  }
}

/// `١٫٢٫٠ ← ١٫٣٫٠`: the installed version, then the one the store has.
class VersionStep extends StatelessWidget {
  const VersionStep({
    super.key,
    required this.from,
    required this.to,
    required this.languageCode,
    required this.semanticLabel,
  });

  final AppVersion from;
  final AppVersion to;
  final String languageCode;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VersionChip(from.display(languageCode), current: false),
          const SizedBox(width: 8),
          MishkatIcon(MIcon.arrowRight, color: t.inkMuted, size: 14),
          const SizedBox(width: 8),
          VersionChip(to.display(languageCode)),
        ],
      ),
    );
  }
}

/// The download bar. Indeterminate while the platform reports no progress —
/// and then still, rather than sweeping, when motion is reduced.
class UpdateProgressBar extends StatelessWidget {
  const UpdateProgressBar({super.key, required this.value, this.height = 6});

  final double? value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fill = t.isDark ? t.cta : t.primary;
    final v = value ?? (Motion.reduced(context) ? 0.35 : null);
    return LinearProgressIndicator(
      value: v,
      minHeight: height,
      color: fill,
      backgroundColor: t.lineSoft,
      borderRadius: BorderRadius.circular(height / 2),
    );
  }
}

/// «١٥٪» / «15%», for the download card and the required screen.
String percentLabel(double? value, String languageCode) {
  if (value == null) return '';
  final n = (value * 100).clamp(0, 100).round();
  return languageCode == 'ar' ? '${toArabicIndic('$n')}٪' : '$n%';
}

/// The glyph-and-sentence rows of «ما الجديد», on a page-coloured card.
class ReleaseNoteList extends StatelessWidget {
  const ReleaseNoteList({
    super.key,
    required this.notes,
    required this.languageCode,
    this.onPage = false,
  });

  final List<ReleaseNote> notes;
  final String languageCode;

  /// On the page background (the «ما الجديد» page) the card and the glyph
  /// circles swap colours with the sheet's.
  final bool onPage;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: onPage ? t.surface : t.bg,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < notes.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: onPage ? t.glowSoft : t.surface,
                    shape: BoxShape.circle,
                  ),
                  child: MishkatIcon(
                    notes[i].icon,
                    color: t.isDark ? t.accentText : t.primary,
                    size: 15,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notes[i].text(languageCode),
                    style: MishkatType.body(
                      t,
                    ).copyWith(fontSize: 13, height: 1.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
