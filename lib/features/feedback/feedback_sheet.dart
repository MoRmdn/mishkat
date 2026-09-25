import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/l10n/labels.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../core/widgets/segmented_control.dart';
import '../../core/widgets/surfaces.dart';
import '../../data/models/thikr.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../services/app_info.dart';
import '../../services/feedback/feedback_models.dart';
import '../../services/feedback/feedback_outbox.dart';
import '../settings/settings_controller.dart';
import 'feedback_list_page.dart';
import 'feedback_widgets.dart';

/// Board AF 8, or 9 when [thikr] is given: the report is then about that
/// thikr, so the type is fixed and the issue chips replace the segments.
///
/// [position] is the reader's «٣ من ٦», shown on the attached thikr.
Future<void> showFeedbackSheet(
  BuildContext context, {
  Thikr? thikr,
  String? position,
}) => showAppSheet<void>(
  context,
  (_) => FeedbackSheet(thikr: thikr, position: position),
);

class FeedbackSheet extends ConsumerStatefulWidget {
  const FeedbackSheet({super.key, this.thikr, this.position});

  final Thikr? thikr;
  final String? position;

  @override
  ConsumerState<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<FeedbackSheet> {
  late FeedbackType _type = widget.thikr == null
      ? FeedbackType.feature
      : FeedbackType.thikr;
  final _body = TextEditingController();
  final _email = TextEditingController();
  final Set<ThikrIssue> _issues = {};
  bool _attachDevice = true;
  bool _sending = false;
  SendResult? _result;

  /// Generated once, so retrying the same message can never create two.
  late final String _draftId = _newId();

  static String _newId() {
    final r = Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(20, (_) => chars[r.nextInt(chars.length)]).join();
  }

  bool get _isReport => widget.thikr != null;

  @override
  void initState() {
    super.initState();
    _body.addListener(() => setState(() {}));
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _body.dispose();
    _email.dispose();
    super.dispose();
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  bool get _emailValid {
    final e = _email.text.trim();
    return e.isEmpty || _emailPattern.hasMatch(e);
  }

  bool get _canSend {
    final length = _body.text.trim().length;
    return !_sending &&
        _emailValid &&
        length <= FeedbackDraft.maxBody &&
        (_isReport ? _issues.isNotEmpty : length >= FeedbackDraft.minBody);
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final lang = ref.read(settingsProvider).language.name;
    final info = _attachDevice ? await ref.read(appInfoProvider.future) : null;
    final draft = FeedbackDraft(
      id: _draftId,
      type: _type,
      body: _body.text.trim(),
      createdAt: ref.read(clockProvider)(),
      issues: _isReport ? {..._issues} : const {},
      thikrId: widget.thikr?.id,
      contentVersion: _isReport
          ? ref.read(athkarLibraryProvider).value?.contentVersion
          : null,
      contactEmail: _email.text.trim().isEmpty ? null : _email.text.trim(),
      device: info == null
          ? null
          : DeviceDetails(
              appVersion: info.version,
              platform: info.platform,
              language: lang,
            ),
    );
    final result = await ref.read(feedbackOutboxProvider.notifier).send(draft);
    if (!mounted) return;
    setState(() {
      _sending = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result == SendResult.sent) return const _SentView();

    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final count = _body.text.trim().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: SheetTitle(_isReport ? l.reportTitle : l.feedback)),
            IconCircleButton(
              icon: MIcon.close,
              iconSize: 16,
              background: t.bg,
              semanticLabel: l.close,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        if (_isReport)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _AttachedThikr(widget.thikr!, position: widget.position),
          )
        else ...[
          Text(
            l.feedbackIntro,
            style: MishkatType.caption(t).copyWith(fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          SegmentedControl<FeedbackType>(
            value: _type,
            onSurface: true,
            fontSize: 12,
            onChanged: (v) => setState(() => _type = v),
            options: [
              for (final type in FeedbackType.values)
                SegmentedOption(
                  type,
                  feedbackTypeLabel(l, type),
                  flex: type == FeedbackType.bug ? 5 : 4,
                ),
            ],
          ),
        ],
        if (_isReport) ...[
          SheetSectionLabel(l.whatsWrong, topPadding: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final issue in ThikrIssue.values)
                // The meaning is only shown in English, so only an English
                // reader can report it.
                if (issue != ThikrIssue.translation || lang == 'en')
                  _IssueChip(
                    label: issueLabel(l, issue),
                    selected: _issues.contains(issue),
                    onTap: () => setState(
                      () => _issues.contains(issue)
                          ? _issues.remove(issue)
                          : _issues.add(issue),
                    ),
                  ),
            ],
          ),
        ],
        SheetSectionLabel(
          _isReport ? l.details : l.yourMessage,
          topPadding: 12,
        ),
        FeedbackField(
          controller: _body,
          hint: l.messageHint,
          minLines: 4,
          maxLines: 6,
          maxLength: FeedbackDraft.maxBody,
        ),
        if (!_isReport)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l.charCount(
                localizeDigits(count, lang),
                localizeDigits(FeedbackDraft.maxBody, lang),
              ),
              textAlign: TextAlign.end,
              style: MishkatType.caption(
                t,
              ).copyWith(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        if (!_isReport) ...[
          SheetSectionLabel(l.replyEmail, topPadding: 12),
          FeedbackField(
            controller: _email,
            hint: 'name@example.com',
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            errorText: _emailValid ? null : l.invalidEmail,
          ),
          const SizedBox(height: 6),
          Text(
            l.replyEmailNote,
            style: MishkatType.caption(t).copyWith(fontSize: 11.5),
          ),
        ],
        const SizedBox(height: 12),
        _DeviceSwitch(
          value: _attachDevice,
          onChanged: () => setState(() => _attachDevice = !_attachDevice),
        ),
        const SizedBox(height: 12),
        switch (_result) {
          SendResult.queued => _StateCard(
            icon: MIcon.cloudOff,
            title: l.queuedTitle,
            body: l.queuedBody,
          ),
          SendResult.failed => _StateCard(
            icon: MIcon.warning,
            title: l.sendFailedTitle,
            body: l.sendFailedBody,
            error: true,
            onRetry: _send,
          ),
          _ => PrimaryButton(
            label: _isReport ? l.sendReport : l.send,
            icon: MIcon.send,
            onPressed: _canSend ? _send : null,
          ),
        },
      ],
    );
  }
}

/// The reported thikr, clipped to two lines, with its reference and where it
/// sits in the routine.
class _AttachedThikr extends ConsumerWidget {
  const _AttachedThikr(this.thikr, {this.position});

  final Thikr thikr;
  final String? position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final lang = ref.watch(settingsProvider).language.name;
    final library = ref.watch(athkarLibraryProvider).value;
    final where = [categoryLabel(l, thikr.category), ?position].join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            thikr.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: kThikrFont,
              fontSize: 19,
              height: 1.9,
              color: t.ink,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            children: [
              Text(
                library?.referenceLine(thikr, lang) ?? '',
                style: MishkatType.caption(t).copyWith(fontSize: 11.5),
              ),
              Text(
                where,
                style: MishkatType.caption(t).copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IssueChip extends StatelessWidget {
  const _IssueChip({
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
    final fill = t.isDark ? t.cta : t.primary;
    final fg = selected ? (t.isDark ? t.onCta : t.onPrimary) : t.ink;
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
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: selected ? 14 : 16),
              decoration: BoxDecoration(
                color: selected ? fill : t.surfaceRaised,
                border: selected ? null : Border.all(color: t.line),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    MishkatIcon(MIcon.check, color: fg, size: 14),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: fg,
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

/// «إرفاق معلومات الجهاز», on by default, naming exactly what is attached.
class _DeviceSwitch extends StatelessWidget {
  const _DeviceSwitch({required this.value, required this.onChanged});

  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Semantics(
      toggled: value,
      button: true,
      label: '${l.attachDevice}، ${l.attachDeviceBody}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: t.bg,
            borderRadius: BorderRadius.circular(Radii.lg),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.attachDevice,
                      style: MishkatType.label(t).copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.attachDeviceBody,
                      style: MishkatType.caption(t).copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// Board AF 10 queued / error: replaces the send button.
class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.body,
    this.error = false,
    this.onRetry,
  });

  final MIcon icon;
  final String title, body;
  final bool error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: error ? t.errorSoft : t.bg,
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: t.surfaceRaised,
                    shape: BoxShape.circle,
                  ),
                  child: MishkatIcon(
                    icon,
                    color: error ? t.error : t.inkMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: MishkatType.label(t).copyWith(fontSize: 14),
                      ),
                      Text(
                        body,
                        style: MishkatType.caption(
                          t,
                        ).copyWith(color: error ? t.ink : null),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              Semantics(
                button: true,
                label: l.retry,
                excludeSemantics: true,
                child: Material(
                  color: t.error,
                  shape: const StadiumBorder(),
                  child: InkWell(
                    customBorder: const StadiumBorder(),
                    onTap: onRetry,
                    child: SizedBox(
                      height: 44,
                      child: Center(
                        child: Text(
                          l.retry,
                          style: TextStyle(
                            fontFamily: kUiFont,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: t.onError,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Board AF 10 sent.
class _SentView extends StatelessWidget {
  const _SentView();

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          const Center(
            child: IconHalo(icon: MIcon.check, size: 64, iconSize: 28),
          ),
          const SizedBox(height: 12),
          Text(
            l.sentTitle,
            textAlign: TextAlign.center,
            style: MishkatType.title(t),
          ),
          const SizedBox(height: 12),
          Text(
            l.sentBody,
            textAlign: TextAlign.center,
            style: MishkatType.bodyMuted(t),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: l.viewMyMessages,
            onPressed: () {
              final navigator = Navigator.of(context)..pop();
              pushFeedbackList(navigator);
            },
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: l.done,
            background: t.bg,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
