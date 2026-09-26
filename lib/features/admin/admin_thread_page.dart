import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/format/relative_time.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../services/feedback/feedback_models.dart';
import '../../services/feedback/feedback_providers.dart';
import '../../services/feedback/feedback_repository.dart';
import '../feedback/feedback_list_page.dart';
import '../feedback/feedback_widgets.dart';
import '../reader/reader_screen.dart';
import '../settings/settings_controller.dart';

Future<void> openAdminThread(BuildContext context, String id) =>
    pushPage(context, (_) => AdminThreadPage(id));

/// Board AF 14: one conversation from the owner's side — what was attached,
/// the status, and a reply that marks it answered.
class AdminThreadPage extends ConsumerStatefulWidget {
  const AdminThreadPage(this.id, {super.key});

  final String id;

  @override
  ConsumerState<AdminThreadPage> createState() => _AdminThreadPageState();
}

class _AdminThreadPageState extends ConsumerState<AdminThreadPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(feedbackRepositoryProvider);
      final thread = await ref.read(threadProvider(widget.id).future);
      if (thread == null) return;
      try {
        if (thread.unreadForAdmin) {
          await repo.markRead(widget.id, reader: MessageAuthor.admin);
        }
        if (thread.number == null) await repo.assignNumber(widget.id);
      } on FeedbackOffline {
        return;
      }
      if (mounted) refreshFeedbackFromWidget(ref);
    });
  }

  Future<void> _setStatus(FeedbackStatus status) async {
    try {
      await ref.read(feedbackRepositoryProvider).setStatus(widget.id, status);
    } catch (_) {
      if (mounted) showToast(context, L.of(context).sendFailedTitle);
      return;
    }
    if (mounted) refreshFeedbackFromWidget(ref);
  }

  Future<bool> _reply(String body) async {
    try {
      await ref
          .read(feedbackRepositoryProvider)
          .reply(widget.id, from: MessageAuthor.admin, body: body)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      if (mounted) showToast(context, L.of(context).sendFailedTitle);
      return false;
    }
    if (mounted) refreshFeedbackFromWidget(ref);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final now = ref.watch(clockProvider)();
    final thread = ref.watch(threadProvider(widget.id)).value;
    final messages = ref.watch(messagesProvider(widget.id)).value ?? const [];
    if (thread == null) {
      return PageScaffold(title: l.messageUnnumbered, body: const SizedBox());
    }

    return PageScaffold(
      title: thread.number == null
          ? l.messageUnnumbered
          : l.messageNumber(localizeDigits(thread.number!, lang)),
      subtitle:
          '${feedbackTypeLabel(l, thread.type)} · '
          '${formatRelative(l, thread.createdAt, now, lang, short: true)}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
        children: [
          _Metadata(thread),
          const SizedBox(height: 10),
          Text(
            l.statusLabel,
            style: MishkatType.label(
              t,
            ).copyWith(fontSize: 12, color: t.inkMuted),
          ),
          const SizedBox(height: 6),
          _StatusControl(value: thread.status, onChanged: _setStatus),
          const SizedBox(height: 4),
          ...conversation(
            context: context,
            messages: messages,
            lang: lang,
            bubble: (m, time) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: m.from == MessageAuthor.user
                  ? MessageBubble(
                      body: m.body,
                      time: time,
                      atEnd: false,
                      background: t.surface,
                      label: l.theUser,
                    )
                  : MessageBubble(
                      body: m.body,
                      time: time,
                      atEnd: true,
                      background: t.glowSoft,
                      label: l.mishkatTeam,
                      labelColor: t.accentText,
                    ),
            ),
          ),
        ],
      ),
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                l.adminReplyNote,
                style: MishkatType.caption(t).copyWith(fontSize: 11),
              ),
            ),
            const SizedBox(height: 6),
            Composer(hint: l.writeReplyToUser, onSend: _reply),
          ],
        ),
      ),
    );
  }
}

/// Type, version, platform, language and date, then the reported thikr with
/// «افتح الذكر». Device rows read «غير مرفق» when the sender switched it off.
class _Metadata extends ConsumerWidget {
  const _Metadata(this.thread);

  final FeedbackThread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final library = ref.watch(athkarLibraryProvider).value;
    final thikr = thread.thikrId == null
        ? null
        : library?.byId(thread.thikrId!);
    final device = thread.device;

    final type = [
      feedbackTypeLabel(l, thread.type),
      for (final i in thread.issues) issueLabel(l, i),
    ].join(' · ');
    final language = switch (device?.language) {
      'ar' => l.languageArabic,
      'en' => l.languageEnglish,
      _ => null,
    };
    final rows = <(String, String?, bool)>[
      (l.metaType, type, false),
      (l.metaVersion, device?.appVersion, true),
      (l.metaPlatform, device?.platform, true),
      (l.language, language, false),
      (l.metaDate, formatDateTime(l, thread.createdAt, lang), false),
      if (thread.contactEmail != null) (l.metaEmail, thread.contactEmail, true),
    ];

    final key = MishkatType.caption(
      t,
    ).copyWith(fontSize: 12, fontWeight: FontWeight.w400);
    final value = MishkatType.label(t).copyWith(fontSize: 12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
            },
            children: [
              for (final (k, v, ltr) in rows)
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: 14,
                        bottom: 5,
                      ),
                      child: Text(k, style: key),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      // A version or a device model stays left-to-right but
                      // lines up with the Arabic values beside it.
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          v ?? l.notAttached,
                          textDirection: v != null && ltr
                              ? TextDirection.ltr
                              : null,
                          style: v == null
                              ? value.copyWith(
                                  color: t.inkMuted,
                                  fontWeight: FontWeight.w300,
                                )
                              : value,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (thikr != null) ...[
            Divider(height: 16, thickness: 1, color: t.lineSoft),
            Text(
              thikr.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: kThikrFont,
                fontSize: 16,
                height: 1.8,
                color: t.ink,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${thikr.id} · ${library!.referenceLine(thikr, lang)}',
                    style: MishkatType.caption(t).copyWith(fontSize: 11.5),
                  ),
                ),
                Semantics(
                  link: true,
                  button: true,
                  label: l.openThikr,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => openReader(context, ref, thikr.category, [
                      thikr,
                    ], subset: true),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l.openThikr,
                            style: TextStyle(
                              fontFamily: kUiFont,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: t.accentText,
                            ),
                          ),
                          const SizedBox(width: 4),
                          MishkatIcon(
                            MIcon.chevronRight,
                            color: t.accentText,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (thread.contentVersion != null)
              Text(
                thread.contentVersion!,
                textDirection: TextDirection.ltr,
                style: MishkatType.caption(t).copyWith(fontSize: 10.5),
              ),
          ],
        ],
      ),
    );
  }
}

/// The four statuses, the current one in its own colour.
class _StatusControl extends StatelessWidget {
  const _StatusControl({required this.value, required this.onChanged});

  final FeedbackStatus value;
  final ValueChanged<FeedbackStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (final s in FeedbackStatus.values)
            Expanded(
              flex: s == FeedbackStatus.inReview ? 13 : 9,
              child: Semantics(
                button: true,
                selected: s == value,
                label: statusLabel(l, s),
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: s == value ? null : () => onChanged(s),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: s == value ? statusColors(t, s).bg : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel(l, s),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kUiFont,
                        fontSize: 11.5,
                        fontWeight: s == value
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: s == value ? statusColors(t, s).fg : t.inkMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
