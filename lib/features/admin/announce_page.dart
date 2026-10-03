import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/format/relative_time.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/surfaces.dart';
import '../../services/auth/auth_service.dart';
import '../../services/push/announcement_repository.dart';
import '../../services/push/push_models.dart';
import '../../services/push/push_providers.dart';
import '../feedback/feedback_widgets.dart';
import '../notifications/notifications_page.dart';
import '../settings/settings_controller.dart';
import '../update/update_controller.dart';

Future<void> openAnnounce(BuildContext context) =>
    pushPage(context, (_) => const AnnouncePage());

/// The owner's composer: one announcement in both languages. Publishing
/// writes `announcements/{id}` and `functions/` pushes it to each language's
/// topic; the rules let only `admins/{uid}` do so. What was sent is listed
/// underneath, with a way to take it off the notifications page.
class AnnouncePage extends ConsumerStatefulWidget {
  const AnnouncePage({super.key});

  @override
  ConsumerState<AnnouncePage> createState() => _AnnouncePageState();
}

class _AnnouncePageState extends ConsumerState<AnnouncePage> {
  final _titleAr = TextEditingController();
  final _bodyAr = TextEditingController();
  final _titleEn = TextEditingController();
  final _bodyEn = TextEditingController();
  late final _fields = [_titleAr, _bodyAr, _titleEn, _bodyEn];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    for (final c in _fields) {
      c.addListener(_changed);
    }
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    for (final c in _fields) {
      c.dispose();
    }
    super.dispose();
  }

  AnnouncementDraft get _draft => AnnouncementDraft(
    titleAr: _titleAr.text,
    titleEn: _titleEn.text,
    bodyAr: _bodyAr.text,
    bodyEn: _bodyEn.text,
  );

  Future<bool> _confirm(String title, String body, String action) async {
    final l = L.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _send() async {
    final l = L.of(context);
    final uid = ref.read(accountProvider).uid;
    if (uid == null) return;
    if (!await _confirm(
      l.announcementConfirmTitle,
      l.announcementConfirmBody,
      l.send,
    )) {
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(announcementRepositoryProvider).publish(_draft, uid: uid);
      for (final c in _fields) {
        c.clear();
      }
      refreshAnnouncements(ref);
      if (mounted) showToast(context, l.announcementSent);
    } catch (_) {
      if (mounted) showToast(context, l.announcementFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _remove(Announcement a) async {
    final l = L.of(context);
    if (!await _confirm(
      l.removeAnnouncement,
      l.removeAnnouncementBody,
      l.remove,
    )) {
      return;
    }
    try {
      await ref.read(announcementRepositoryProvider).delete(a.id);
    } catch (_) {
      if (mounted) showToast(context, l.announcementFailed);
    }
    refreshAnnouncements(ref);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final now = ref.watch(clockProvider)();
    final sent = ref.watch(announcementsProvider).value ?? const [];
    final locked = ref.watch(updateBlocksWritesProvider);

    Widget field(
      String label,
      TextEditingController c,
      int max, {
      required TextDirection direction,
      bool long = false,
    }) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetSectionLabel(label, topPadding: 14),
        FeedbackField(
          controller: c,
          hint: label,
          minLines: long ? 3 : 1,
          maxLines: long ? 6 : 1,
          maxLength: max,
          textDirection: direction,
          semanticLabel: label,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            l.charCount(
              localizeDigits(c.text.trim().length, lang),
              localizeDigits(max, lang),
            ),
            textAlign: TextAlign.end,
            style: MishkatType.caption(t).copyWith(fontSize: 12),
          ),
        ),
      ],
    );

    return PageScaffold(
      title: l.sendAnnouncement,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          field(
            l.announcementTitleAr,
            _titleAr,
            AnnouncementDraft.maxTitle,
            direction: TextDirection.rtl,
          ),
          field(
            l.announcementBodyAr,
            _bodyAr,
            AnnouncementDraft.maxBody,
            direction: TextDirection.rtl,
            long: true,
          ),
          field(
            l.announcementTitleEn,
            _titleEn,
            AnnouncementDraft.maxTitle,
            direction: TextDirection.ltr,
          ),
          field(
            l.announcementBodyEn,
            _bodyEn,
            AnnouncementDraft.maxBody,
            direction: TextDirection.ltr,
            long: true,
          ),
          if (sent.isNotEmpty) ...[
            SheetSectionLabel(l.sentAnnouncements, topPadding: 24),
            GroupCard(
              children: [
                for (final a in sent)
                  AnnouncementRow(
                    announcement: a,
                    lang: lang,
                    when: formatRelative(l, a.createdAt, now, lang),
                    trailing: IconCircleButton(
                      icon: MIcon.trash,
                      size: 36,
                      iconSize: 16,
                      background: t.bg,
                      semanticLabel: l.removeAnnouncement,
                      onPressed: () => _remove(a),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: PrimaryButton(
          label: l.send,
          icon: MIcon.send,
          onPressed: _sending || locked || !_draft.isValid ? null : _send,
        ),
      ),
    );
  }
}
