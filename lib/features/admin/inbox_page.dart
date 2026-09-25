import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/format/relative_time.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/page_scaffold.dart';
import '../../core/widgets/surfaces.dart';
import '../../services/feedback/feedback_models.dart';
import '../../services/feedback/feedback_providers.dart';
import '../feedback/feedback_widgets.dart';
import '../settings/settings_controller.dart';
import 'admin_thread_page.dart';

Future<void> openInbox(BuildContext context) =>
    pushPage(context, (_) => const InboxPage());

/// Board AF 13, owner only. Type as segments, status as chips; read and
/// unread are separate from status.
class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> {
  FeedbackType? _type;
  FeedbackStatus? _status;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final now = ref.watch(clockProvider)();
    final filter = (type: _type, status: _status);
    final threads = ref.watch(inboxProvider(filter)).value;
    final unread = ref.watch(feedbackBadgesProvider).value?.adminUnread ?? 0;

    return PageScaffold(
      title: l.inbox,
      trailing: unread == 0
          ? null
          : Text(
              l.unreadCount(unread, localizeDigits(unread, lang)),
              style: MishkatType.caption(t),
            ),
      body: RefreshIndicator(
        color: t.accentText,
        onRefresh: () async {
          refreshFeedbackFromWidget(ref);
          await ref.read(inboxProvider(filter).future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
          children: [
            _TypeFilter(
              value: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (final s in FeedbackStatus.values) ...[
                    _StatusFilterChip(
                      label: statusLabel(l, s),
                      selected: _status == s,
                      onTap: () =>
                          setState(() => _status = _status == s ? null : s),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (threads != null && threads.isEmpty)
              _Empty(
                onClear: _type == null && _status == null
                    ? null
                    : () => setState(() {
                        _type = null;
                        _status = null;
                      }),
              )
            else if (threads != null)
              GroupCard(
                children: [
                  for (final thread in threads)
                    ThreadRow(
                      thread: thread,
                      unread: thread.unreadForAdmin,
                      title: thread.preview.isEmpty
                          ? [
                              feedbackTypeLabel(l, thread.type),
                              for (final i in thread.issues) issueLabel(l, i),
                            ].join(' · ')
                          : null,
                      onTap: () => openAdminThread(context, thread.id),
                      meta: Row(
                        children: [
                          if (thread.device != null) ...[
                            LanguageTag(thread.device!.language),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            formatRelative(
                              l,
                              thread.updatedAt,
                              now,
                              lang,
                              short: true,
                            ),
                            style: MishkatType.caption(
                              t,
                            ).copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// «الكل · اقتراحات · أذكار · مشكلات», the selected one filled.
class _TypeFilter extends StatelessWidget {
  const _TypeFilter({required this.value, required this.onChanged});

  final FeedbackType? value;
  final ValueChanged<FeedbackType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final options = <(FeedbackType?, String)>[
      (null, l.filterAll),
      (FeedbackType.feature, l.filterIdeas),
      (FeedbackType.thikr, l.filterAthkar),
      (FeedbackType.bug, l.filterApp),
    ];
    final fill = t.isDark ? t.cta : t.primary;
    final onFill = t.isDark ? t.onCta : t.onPrimary;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          for (final (type, label) in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: value == type,
                label: label,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(type),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == type ? fill : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: kUiFont,
                        fontSize: 12,
                        fontWeight: value == type
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: value == type ? onFill : t.inkMuted,
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

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: Sizes.touchMin,
          child: Center(
            widthFactor: 1,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected ? t.ink : t.surface,
                border: selected ? null : Border.all(color: t.line),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    MishkatIcon(MIcon.check, color: t.bg, size: 12),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: selected ? t.bg : t.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({this.onClear});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
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
          Text(l.inboxEmptyTitle, style: MishkatType.headline(t)),
          const SizedBox(height: 10),
          Text(
            l.inboxEmptyBody,
            textAlign: TextAlign.center,
            style: MishkatType.bodyMuted(t).copyWith(fontSize: 13.5),
          ),
          if (onClear != null) ...[
            const SizedBox(height: 16),
            SecondaryButton(
              label: l.clearFilters,
              expand: false,
              onPressed: onClear,
            ),
          ],
        ],
      ),
    );
  }
}
