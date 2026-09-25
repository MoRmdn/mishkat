import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/brand_mark.dart';
import '../../core/widgets/buttons.dart';
import '../../services/update/update_policy.dart';
import 'update_widgets.dart';

/// Offers [update]; true when the user chose to update.
Future<bool> showOptionalUpdateSheet(
  BuildContext context,
  OptionalUpdate update,
) async =>
    await showAppSheet<bool>(
      context,
      (_) => OptionalUpdateSheet(update: update),
    ) ??
    false;

/// «تحديث جديد متاح» (board "Mishkat Update Required", optional): the mark,
/// the version, what it brings when the owner published notes for it, and
/// the button — a background download on Android, the App Store on iOS.
class OptionalUpdateSheet extends StatelessWidget {
  const OptionalUpdateSheet({super.key, required this.update});

  final OptionalUpdate update;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    final notes = update.notes?.notes ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: GlowingMark(
            box: 84,
            halo: t.isDark ? t.lineSoft : t.glowSoft,
            mark: BrandMark(size: 64, arch: t.isDark ? null : t.surface),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: VersionChip(l.updateVersionChip(update.target.display(lang))),
        ),
        const SizedBox(height: 10),
        Center(child: SheetTitle(l.updateAvailableTitle)),
        const SizedBox(height: 6),
        Text(
          l.updateAvailableBody,
          textAlign: TextAlign.center,
          style: MishkatType.caption(t).copyWith(fontSize: 13, height: 1.7),
        ),
        if (notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          ReleaseNoteList(notes: notes, languageCode: lang),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          label: ios ? l.updateFromAppStore : l.updateNow,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 4),
        TextAction(
          label: l.updateLater,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        const SizedBox(height: 2),
        Text(
          ios ? l.updateMetaStore : l.updateMetaInApp,
          textAlign: TextAlign.center,
          style: MishkatType.caption(t).copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
