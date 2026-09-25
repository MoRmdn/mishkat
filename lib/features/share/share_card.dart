import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/share_link.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/segmented_control.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../settings/settings_controller.dart';

/// Exported images are 1080 wide: square when the thikr fits, 1080×1350
/// (4:5) when it does not, and taller still for the very longest — the text
/// is never shrunk or cut.
const double kShareImageWidth = 1080;

/// The card is laid out at a third of its exported size, as on the board.
const double _designWidth = 360;
const double _pixelRatio = kShareImageWidth / _designWidth;
const double _squareHeight = 360;
const double _portraitHeight = 450;

const double _padding = 30;
const double _thikrSize = 21;
const double _thikrHeight = 2;

/// The two looks from board 3.5.
enum ShareCardStyle { aubergine, stone }

/// The card's colours for [style], always from the light identity: an
/// exported image leaves the app, so it looks the same whoever shares it.
class _CardColors {
  factory _CardColors(ShareCardStyle style) {
    const t = MishkatTokens.light;
    return switch (style) {
      ShareCardStyle.aubergine => _CardColors._(
        bg: t.primary,
        text: t.onPrimary,
        muted: t.onPrimaryMuted,
        hairline: Color.alphaBlend(
          t.onPrimary.withValues(alpha: 0.25),
          t.primary,
        ),
        arch: t.onPrimary,
        lamp: t.cta,
      ),
      ShareCardStyle.stone => _CardColors._(
        bg: t.bg,
        text: t.ink,
        muted: t.inkMuted,
        hairline: t.line,
        arch: t.primary,
        lamp: t.glow,
      ),
    };
  }

  const _CardColors._({
    required this.bg,
    required this.text,
    required this.muted,
    required this.hairline,
    required this.arch,
    required this.lamp,
  });

  final Color bg, text, muted, hairline, arch, lamp;
}

TextStyle _thikrStyle(Color color) => TextStyle(
  fontFamily: kThikrFont,
  fontSize: _thikrSize,
  height: _thikrHeight,
  color: color,
);

/// The card's logical height for [text]: the square if the thikr fits,
/// otherwise 4:5, otherwise exactly as tall as the text needs.
double shareCardHeight(String text) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: _thikrStyle(MishkatTokens.light.ink)),
    textAlign: TextAlign.center,
    textDirection: TextDirection.rtl,
  )..layout(maxWidth: _designWidth - 2 * _padding);
  // Header and source line, plus breathing room above and below the text.
  const chrome = 2 * _padding + 22 + 17 + 2 * 24;
  final needed = painter.height + chrome;
  painter.dispose();
  if (needed <= _squareHeight) return _squareHeight;
  if (needed <= _portraitHeight) return _portraitHeight;
  return needed.ceilToDouble();
}

/// The shareable thikr card from board 3.5.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.text,
    required this.reference,
    required this.brandName,
    required this.brandWird,
    required this.language,
    this.style = ShareCardStyle.aubergine,
  });

  final String text, reference, brandName, brandWird;

  /// Direction of the wordmark row; the thikr itself is always Arabic.
  final TextDirection language;
  final ShareCardStyle style;

  @override
  Widget build(BuildContext context) {
    final c = _CardColors(style);
    Widget hairline() => Container(width: 16, height: 1, color: c.hairline);

    // Self-contained theme: the offscreen capture has no MaterialApp above.
    return Theme(
      data: buildMishkatTheme(Brightness.light),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: _designWidth,
          height: shareCardHeight(text),
          color: c.bg,
          padding: const EdgeInsets.all(_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Directionality(
                textDirection: language,
                child: Row(
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: brandName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: c.text,
                            ),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: brandWird,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: c.muted,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(fontFamily: kUiFont),
                    ),
                    const Spacer(),
                    BrandMark(
                      size: 22,
                      showTile: false,
                      smallCut: false,
                      arch: c.arch,
                      lamp: c.lamp,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: _thikrStyle(c.text),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  hairline(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      reference,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kUiFont,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w300,
                        color: c.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  hairline(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders [card] to a PNG 1080 wide.
Future<Uint8List> renderShareImage(ShareCard card) {
  return ScreenshotController().captureFromWidget(
    card,
    pixelRatio: _pixelRatio,
    targetSize: Size(_designWidth, shareCardHeight(card.text)),
    // Long enough for the mark's SVG, already cached by the preview.
    delay: const Duration(milliseconds: 120),
  );
}

Future<void> showShareSheet(BuildContext context, Thikr thikr) =>
    showAppSheet(context, (_) => ShareSheet(thikr: thikr));

class ShareSheet extends ConsumerStatefulWidget {
  const ShareSheet({super.key, required this.thikr});

  final Thikr thikr;

  @override
  ConsumerState<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends ConsumerState<ShareSheet> {
  bool _busy = false;
  ShareCardStyle _style = ShareCardStyle.aubergine;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final settings = ref.watch(settingsProvider);
    final lang = settings.language.name;
    final library = ref.watch(athkarLibraryProvider).value;

    final card = ShareCard(
      text: widget.thikr.text,
      reference: library?.referenceLine(widget.thikr, lang) ?? '',
      brandName: l.brandName,
      brandWird: l.brandWird,
      language: settings.language.isRtl ? TextDirection.rtl : TextDirection.ltr,
      style: _style,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.shareTitle, style: MishkatType.title(context.tokens)),
        const SizedBox(height: Space.md),
        SegmentedControl<ShareCardStyle>(
          value: _style,
          onChanged: (s) => setState(() => _style = s),
          options: [
            SegmentedOption(ShareCardStyle.aubergine, l.shareStyleAubergine),
            SegmentedOption(ShareCardStyle.stone, l.shareStyleStone),
          ],
        ),
        const SizedBox(height: Space.md),
        // The exported card, scaled to the sheet's width.
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.lg),
          child: FittedBox(fit: BoxFit.contain, child: card),
        ),
        const SizedBox(height: Space.md),
        PrimaryButton(
          label: l.share,
          icon: MIcon.share,
          onPressed: _busy ? null : () => _share(card),
        ),
      ],
    );
  }

  Future<void> _share(ShareCard card) async {
    setState(() => _busy = true);
    try {
      final bytes = await renderShareImage(card);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/thikr.png');
      await file.writeAsBytes(bytes);

      // The link rides along as text: a URL drawn inside the image can't be
      // tapped. Some targets drop the text when an image is attached.
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: thikrLink(widget.thikr).toString(),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
