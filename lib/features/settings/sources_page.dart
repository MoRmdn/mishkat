import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart' show SheetSectionLabel;
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/repositories/athkar_repository.dart';
import 'settings_controller.dart';

Future<void> openSources(BuildContext context) =>
    pushPage(context, (_) => const SourcesPage());

/// «مصادر الأذكار» (board AF 16a, «عن التطبيق»): the collections the athkar
/// are taken from, read from `athkar.json` so the page cannot drift from the
/// content, and the edition a wrong-thikr report carries.
class SourcesPage extends ConsumerWidget {
  const SourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final library = ref.watch(athkarLibraryProvider).value;
    final body = MishkatType.body(t).copyWith(fontSize: 14);
    final caption = MishkatType.caption(
      t,
    ).copyWith(fontSize: 12.5, height: 1.8);

    Widget row(String text, {TextDirection? direction}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(text, textDirection: direction, style: body),
      ),
    );

    return PageScaffold(
      title: l.thikrSources,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        children: [
          Text(l.sourcesIntro, style: caption),
          const SizedBox(height: 16),
          if (library != null) ...[
            GroupCard(
              children: [
                for (final source in library.sources.values)
                  row(source.label(lang)),
              ],
            ),
            if (library.contentVersion != null) ...[
              const SizedBox(height: 16),
              SheetSectionLabel(l.contentVersionLabel, topPadding: 0),
              GroupCard(
                children: [
                  // `2026-09-24-draft.1` would reorder in an RTL run.
                  row(library.contentVersion!, direction: TextDirection.ltr),
                ],
              ),
            ],
          ],
          const SizedBox(height: 16),
          Text(l.sourcesReview, style: caption),
        ],
      ),
    );
  }
}
