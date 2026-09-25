import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/surfaces.dart';
import '../../core/format/relative_time.dart';
import '../../services/feedback/feedback_models.dart';
import '../../services/feedback/feedback_outbox.dart';
import '../../services/feedback/feedback_providers.dart';
import '../settings/settings_controller.dart';
import 'feedback_sheet.dart';
import 'feedback_widgets.dart';
import 'thread_page.dart';

Future<void> openFeedbackList(BuildContext context) =>
    pushPage(context, (_) => const FeedbackListPage());

/// From a sheet that has just closed, where its own context is gone.
Future<void> pushFeedbackList(NavigatorState navigator) =>
    navigator.push(MaterialPageRoute(builder: (_) => const FeedbackListPage()));

/// Board AF 11: the sender's conversations, newest first, with drafts still
/// waiting to send on top. Replies only ever appear here.
class FeedbackListPage extends ConsumerWidget {
  const FeedbackListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final threads = ref.watch(myThreadsProvider);
    final lang = ref.watch(settingsProvider).language.name;

    Future<void> refresh() async {
      await ref.read(feedbackOutboxProvider.notifier).flush();
      refreshFeedbackFromWidget(ref);
      await ref.read(myThreadsProvider.future);
    }

    final list = threads.value;
    if (list != null && list.isEmpty) {
      return PageScaffold(title: l.feedback, body: const _Empty());
    }

    return PageScaffold(
      title: l.feedback,
      body: RefreshIndicator(
        color: t.accentText,
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          children: [
            if (list != null)
              GroupCard(
                children: [
                  for (final thread in list)
                    ThreadRow(
                      thread: thread,
                      unread: thread.unreadForUser,
                      title: thread.preview.isEmpty
                          ? _reportTitle(l, thread)
                          : null,
                      onTap: thread.queued
                          ? null
                          : () => openThread(context, thread.id),
                      meta: Row(
                        children: [
                          StatusChip(thread),
                          const SizedBox(width: 8),
                          Text(
                            formatDayMonth(thread.createdAt, lang),
                            style: MishkatType.caption(
                              t,
                            ).copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              l.repliesInAppOnly,
              textAlign: TextAlign.center,
              style: MishkatType.caption(t).copyWith(fontSize: 11.5),
            ),
          ],
        ),
      ),
      bottom: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: PrimaryButton(
          label: l.newMessage,
          icon: MIcon.plus,
          onPressed: () => showFeedbackSheet(context),
        ),
      ),
    );
  }
}

/// A report sent without details is titled by what was wrong.
String _reportTitle(L l, FeedbackThread thread) => [
  feedbackTypeLabel(l, thread.type),
  for (final i in thread.issues) issueLabel(l, i),
].join(' · ');

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.surface,
                shape: BoxShape.circle,
              ),
              child: MishkatIcon(MIcon.message, color: t.accentText, size: 28),
            ),
            const SizedBox(height: 16),
            Text(l.noMessagesTitle, style: MishkatType.headline(t)),
            const SizedBox(height: 10),
            Text(
              l.noMessagesBody,
              textAlign: TextAlign.center,
              style: MishkatType.bodyMuted(t).copyWith(fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: l.sendFeedback,
              expand: false,
              onPressed: () => showFeedbackSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared by the sender's thread and the owner's: the date the conversation
/// started, then each message, with a date line whenever the day changes.
List<Widget> conversation({
  required BuildContext context,
  required List<FeedbackMessage> messages,
  required String lang,
  required Widget Function(FeedbackMessage m, String time) bubble,
}) {
  final l = L.of(context);
  final widgets = <Widget>[];
  DateTime? day;
  for (final m in messages) {
    final d = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
    if (day != d) {
      day = d;
      widgets.add(DayDivider(formatDayMonth(m.createdAt, lang)));
    }
    widgets.add(bubble(m, formatTimeOf(l, m.createdAt, lang)));
  }
  return widgets;
}
