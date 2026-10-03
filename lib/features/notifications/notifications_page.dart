import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/relative_time.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/segmented_control.dart';
import '../../core/widgets/surfaces.dart';
import '../../services/push/push_models.dart';
import '../../services/push/push_providers.dart';
import '../settings/settings_controller.dart';

/// Home's bell, or a tapped announcement push ([highlight] is its id).
Future<void> openNotifications(BuildContext context, {String? highlight}) =>
    pushPage(context, (_) => NotificationsPage(highlight: highlight));

/// The owner's announcements, newest first — the ones that arrived as a push
/// and the ones that did not (pushes off, offline, installed since). Opening
/// the page marks them seen and clears the bell's dot.
///
/// Reminders are not listed: they are local, and live on the Reminders tab.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key, this.highlight});

  final String? highlight;

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  /// What counted as seen when the page opened: newer ones keep their dot
  /// while the page is open, though the bell's has already cleared.
  late final DateTime? _seenAtOpen = ref.read(announcementsSeenProvider);

  void _markSeen(List<Announcement> list) =>
      ref.read(announcementsSeenProvider.notifier).markSeen(list);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final list = ref.read(announcementsProvider).value;
      if (list != null) _markSeen(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final now = ref.watch(clockProvider)();
    final announcements = ref.watch(announcementsProvider);
    ref.listen(announcementsProvider, (_, next) {
      if (next.value case final list?) _markSeen(list);
    });

    Future<void> refresh() async {
      refreshAnnouncements(ref);
      await ref.read(announcementsProvider.future);
    }

    final list = announcements.value;
    return PageScaffold(
      title: l.notifications,
      body: RefreshIndicator(
        color: t.accentText,
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const _PushToggle(),
            const SizedBox(height: 18),
            if (list != null && list.isEmpty)
              const _Empty()
            else if (list != null)
              GroupCard(
                children: [
                  for (final a in list)
                    AnnouncementRow(
                      announcement: a,
                      lang: lang,
                      when: formatRelative(l, a.createdAt, now, lang),
                      unread:
                          _seenAtOpen == null ||
                          a.createdAt.isAfter(_seenAtOpen),
                      highlighted: a.id == widget.highlight,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// One announcement: title, the full text, when. Shared with the owner's
/// composer, which lists what was sent.
class AnnouncementRow extends StatelessWidget {
  const AnnouncementRow({
    super.key,
    required this.announcement,
    required this.lang,
    required this.when,
    this.unread = false,
    this.highlighted = false,
    this.trailing,
  });

  final Announcement announcement;
  final String lang;
  final String when;
  final bool unread;

  /// The one a tapped push opened.
  final bool highlighted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final title = announcement.title(lang);
    return Semantics(
      container: true,
      label: unread ? l.withUnread(title, l.unreadAnnouncement) : null,
      child: ColoredBox(
        color: highlighted ? t.glowSoft : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: MishkatType.label(
                        t,
                      ).copyWith(fontSize: 14.5, height: 1.5),
                    ),
                  ),
                  if (unread) ...[
                    const SizedBox(width: 10),
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: UnreadDot(),
                    ),
                  ],
                  ?trailing,
                ],
              ),
              const SizedBox(height: 4),
              Text(
                announcement.body(lang),
                style: MishkatType.bodyMuted(t).copyWith(fontSize: 13.5),
              ),
              const SizedBox(height: 8),
              Text(
                when,
                style: MishkatType.caption(t).copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Whether announcements arrive as a push. The page lists them either way.
class _PushToggle extends ConsumerWidget {
  const _PushToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final on = ref.watch(announcementPushProvider);
    void toggle() => ref.read(announcementPushProvider.notifier).set(!on);
    return Material(
      color: t.surface,
      borderRadius: BorderRadius.circular(Radii.lg),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        toggled: on,
        button: true,
        label: l.announcementPushLabel,
        excludeSemantics: true,
        child: InkWell(
          onTap: toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.announcementPushLabel,
                        style: MishkatType.label(t).copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.announcementPushBody,
                        style: MishkatType.caption(t).copyWith(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppSwitch(value: on, onChanged: toggle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: t.surface, shape: BoxShape.circle),
            child: MishkatIcon(MIcon.inbox, color: t.accentText, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            l.noAnnouncementsTitle,
            textAlign: TextAlign.center,
            style: MishkatType.headline(t),
          ),
          const SizedBox(height: 10),
          Text(
            l.noAnnouncementsBody,
            textAlign: TextAlign.center,
            style: MishkatType.bodyMuted(t).copyWith(fontSize: 13.5),
          ),
        ],
      ),
    );
  }
}
