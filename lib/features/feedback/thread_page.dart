import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/numerals.dart';
import '../../core/format/relative_time.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../services/feedback/feedback_models.dart';
import '../../services/feedback/feedback_providers.dart';
import '../../services/feedback/feedback_repository.dart';
import '../settings/settings_controller.dart';
import 'feedback_list_page.dart';
import 'feedback_sheet.dart';
import 'feedback_widgets.dart';

Future<void> openThread(BuildContext context, String id) =>
    pushPage(context, (_) => ThreadPage(id));

/// «٩:٣٦ ص».
String formatTimeOf(L l, DateTime at, String lang) =>
    formatTime(at, lang, am: l.am, pm: l.pm);

/// Board AF 12: one conversation from the sender's side. Opening it marks
/// the team's reply read and clears the dot.
class ThreadPage extends ConsumerStatefulWidget {
  const ThreadPage(this.id, {super.key});

  final String id;

  @override
  ConsumerState<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends ConsumerState<ThreadPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final thread = await ref.read(threadProvider(widget.id).future);
      if (thread == null || !thread.unreadForUser) return;
      try {
        await ref
            .read(feedbackRepositoryProvider)
            .markRead(widget.id, reader: MessageAuthor.user);
      } on FeedbackOffline {
        return;
      }
      if (mounted) refreshFeedbackFromWidget(ref);
    });
  }

  Future<bool> _reply(String body) async {
    try {
      await ref
          .read(feedbackRepositoryProvider)
          .reply(widget.id, from: MessageAuthor.user, body: body)
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
    final thread = ref.watch(threadProvider(widget.id)).value;
    final messages = ref.watch(messagesProvider(widget.id)).value ?? const [];
    if (thread == null) {
      return PageScaffold(title: l.feedback, body: const SizedBox.shrink());
    }
    final library = ref.watch(athkarLibraryProvider).value;
    final thikr = thread.thikrId == null
        ? null
        : library?.byId(thread.thikrId!);

    return PageScaffold(
      title: feedbackTypeLabel(l, thread.type),
      subtitle: l.startedOn(formatDayMonth(thread.createdAt, lang)),
      trailing: StatusChip(thread, height: 26),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
        children: [
          if (thikr != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(Radii.md),
              ),
              child: Row(
                children: [
                  MishkatIcon(MIcon.flag, color: t.inkMuted, size: 14),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      thikr.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: kThikrFont,
                        fontSize: 16,
                        color: t.ink,
                      ),
                    ),
                  ),
                  if (thread.issues.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Text(
                      thread.issues.map((i) => issueLabel(l, i)).join('، '),
                      style: MishkatType.caption(t).copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...conversation(
            context: context,
            messages: messages,
            lang: lang,
            bubble: (m, time) => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: m.from == MessageAuthor.user
                  ? MessageBubble(
                      body: m.body,
                      time: time,
                      atEnd: true,
                      background: t.surface,
                    )
                  : MessageBubble(
                      body: m.body,
                      time: time,
                      atEnd: false,
                      background: t.glowSoft,
                      label: l.mishkatTeam,
                      labelColor: t.accentText,
                    ),
            ),
          ),
          if (thread.isClosed && thread.closedAt != null) ...[
            const SizedBox(height: 12),
            DayDivider(l.closedOn(formatDayMonth(thread.closedAt!, lang))),
          ],
        ],
      ),
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
        child: thread.isClosed
            ? const _ClosedCard()
            : Composer(hint: l.writeReply, onSend: _reply),
      ),
    );
  }
}

class _ClosedCard extends StatelessWidget {
  const _ClosedCard();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.threadClosedTitle,
                  style: MishkatType.label(t).copyWith(fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(l.threadClosedBody, style: MishkatType.caption(t)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SmallPillButton(
            label: l.newMessage,
            onPressed: () {
              Navigator.of(context).pop();
              showFeedbackSheet(context);
            },
          ),
        ],
      ),
    );
  }
}
