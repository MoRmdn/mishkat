import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/palettes.dart';
import '../../core/widgets/app_sheet.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../settings/settings_controller.dart';

/// The exported artboard is square, at the size social apps expect.
const double kShareImageSize = 1080;

/// Rendered at half scale on screen, captured at 2× to reach 1080².
const double _designSize = 540;

/// The shareable thikr card from the design board.
///
/// Deliberately self-contained rather than theme-dependent: an exported image
/// leaves the app, so it should look the same whoever shares it.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.text,
    required this.reference,
    required this.appName,
    required this.label,
    this.scale = 1,
  });

  final String text, reference, appName, label;

  /// 1 draws at [_designSize]; the capture uses the same widget.
  final double scale;

  @override
  Widget build(BuildContext context) {
    // The share card always uses the teal palette's deep ink, so a shared
    // image is recognisably from this app regardless of the sender's theme.
    final spec = kPalettes[AppPalette.teal]!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: _designSize,
        height: _designSize,
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 64),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [spec.accentInk, spec.reader.bg],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: kUiFont,
                    fontSize: 14,
                    letterSpacing: 2,
                    color: spec.gold,
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    border: Border.all(color: spec.gold.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kQuranFont,
                    // Long athkar step down rather than clipping: no shared
                    // image may ever cut the text.
                    fontSize: _fontSizeFor(text),
                    height: 2.1,
                    color: const Color(0xFFEAF2EE),
                  ),
                ),
              ),
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.14)),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    reference,
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: 13,
                      color: spec.gold,
                    ),
                  ),
                ),
                Text(
                  appName,
                  style: TextStyle(
                    fontFamily: kUiFont,
                    fontSize: 13,
                    letterSpacing: 1,
                    color: const Color(0xFFEAF2EE).withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Steps down in bands so even the longest thikr fits the square.
  static double _fontSizeFor(String text) {
    if (text.length > 320) return 20;
    if (text.length > 200) return 25;
    if (text.length > 120) return 29;
    return 34;
  }
}

/// Renders [card] to a PNG at [kShareImageSize] square.
Future<Uint8List> renderShareImage(Widget card) {
  return ScreenshotController().captureFromWidget(
    card,
    pixelRatio: kShareImageSize / _designSize,
    targetSize: const Size(_designSize, _designSize),
    delay: const Duration(milliseconds: 40),
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

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final library = ref.watch(athkarLibraryProvider).value;

    final card = ShareCard(
      text: widget.thikr.text,
      reference: library?.referenceLine(widget.thikr, lang) ?? '',
      appName: l.appName,
      label: l.shareCardLabel,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.shareTitle,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        // Shown at half the exported size.
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _designSize,
              height: _designSize,
              child: card,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _busy ? null : () => _share(card),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: t.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l.share,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: t.onAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _share(Widget card) async {
    setState(() => _busy = true);
    try {
      final bytes = await renderShareImage(card);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/thikr.png');
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
