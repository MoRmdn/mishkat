import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/list_rows.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../../services/feedback/feedback_models.dart';

MIcon feedbackTypeIcon(FeedbackType type) => switch (type) {
  FeedbackType.feature => MIcon.edit,
  FeedbackType.thikr => MIcon.flag,
  FeedbackType.bug => MIcon.warning,
};

String feedbackTypeLabel(L l, FeedbackType type) => switch (type) {
  FeedbackType.feature => l.typeFeature,
  FeedbackType.thikr => l.typeThikr,
  FeedbackType.bug => l.typeBug,
};

String issueLabel(L l, ThikrIssue issue) => switch (issue) {
  ThikrIssue.text => l.issueText,
  ThikrIssue.source => l.issueSource,
  ThikrIssue.count => l.issueCount,
  ThikrIssue.translation => l.issueTranslation,
};

String statusLabel(L l, FeedbackStatus s) => switch (s) {
  FeedbackStatus.open => l.statusNew,
  FeedbackStatus.inReview => l.statusInReview,
  FeedbackStatus.answered => l.statusAnswered,
  FeedbackStatus.closed => l.statusClosed,
};

/// The board's status colours, all existing token pairs: new on glowSoft,
/// in review on the warn ramp, replied on primary, closed on lineSoft.
({Color bg, Color fg}) statusColors(MishkatTokens t, FeedbackStatus s) =>
    switch (s) {
      FeedbackStatus.open => (bg: t.glowSoft, fg: t.accentText),
      FeedbackStatus.inReview => (bg: t.warnBg, fg: t.warnInk),
      FeedbackStatus.answered =>
        t.isDark ? (bg: t.cta, fg: t.onCta) : (bg: t.primary, fg: t.onPrimary),
      FeedbackStatus.closed => (bg: t.lineSoft, fg: t.inkMuted),
    };

class StatusChip extends StatelessWidget {
  const StatusChip(this.thread, {super.key, this.height = 24});

  final FeedbackThread thread;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    if (thread.queued) {
      return TagChip(
        label: l.statusQueued,
        background: t.bg,
        foreground: t.inkMuted,
        height: height,
      );
    }
    final c = statusColors(t, thread.status);
    return TagChip(
      label: statusLabel(l, thread.status),
      background: c.bg,
      foreground: c.fg,
      height: height,
    );
  }
}

/// «٢٤ سبتمبر ٢٠٢٦، ٩:٣٦ ص».
String formatDateTime(L l, DateTime at, String lang) {
  final date = localizeDigits(DateFormat('d MMMM y', lang).format(at), lang);
  return '$date${lang == 'ar' ? '،' : ','} ${formatTime(at, lang, am: l.am, pm: l.pm)}';
}

/// The direction of what a user wrote, by its first strong character: an
/// English message in the Arabic inbox still reads left to right.
TextDirection? writtenDirection(String text) {
  for (final rune in text.runes) {
    if (rune >= 0x0590 && rune <= 0x08FF) return TextDirection.rtl;
    if ((rune >= 0x41 && rune <= 0x5A) || (rune >= 0x61 && rune <= 0x7A)) {
      return TextDirection.ltr;
    }
  }
  return null;
}

/// A conversation in a list: type glyph, first line, unread dot, then a
/// status chip and date (the sender's list) or a language tag and relative
/// time (the owner's inbox).
class ThreadRow extends StatelessWidget {
  const ThreadRow({
    super.key,
    required this.thread,
    required this.unread,
    required this.meta,
    required this.onTap,
    this.title,
    this.dimmed = false,
  });

  final FeedbackThread thread;
  final bool unread;

  /// Closed (the sender's list) or already read (the owner's inbox).
  final bool dimmed;

  /// The line under the title.
  final Widget meta;
  final VoidCallback? onTap;

  /// Overrides the preview, for a report sent without details.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final muted = dimmed;
    final text = title ?? thread.preview;
    final direction = writtenDirection(text);
    final rtlLayout = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      button: onTap != null,
      label: [
        feedbackTypeLabel(l, thread.type),
        text,
        if (unread) l.unreadReply,
      ].join('، '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: muted ? t.bg : t.glowSoft,
                  shape: BoxShape.circle,
                ),
                child: MishkatIcon(
                  feedbackTypeIcon(thread.type),
                  color: muted
                      ? t.inkMuted
                      : (t.isDark ? t.accentText : t.primary),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: direction,
                            textAlign: rtlLayout
                                ? TextAlign.right
                                : TextAlign.left,
                            style: TextStyle(
                              fontFamily: kUiFont,
                              fontSize: 13.5,
                              fontWeight: unread
                                  ? FontWeight.w500
                                  : FontWeight.w400,
                              color: muted ? t.inkMuted : t.ink,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          const UnreadDot(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    meta,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The sender's language, «AR» / «EN», in a small outlined tag.
class LanguageTag extends StatelessWidget {
  const LanguageTag(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        code.toUpperCase(),
        style: TextStyle(
          fontFamily: kUiFont,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: t.inkMuted,
        ),
      ),
    );
  }
}

/// One message. The reader's own messages sit at the trailing side on
/// surface; the other side's at the leading side, with a small label.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.body,
    required this.time,
    required this.atEnd,
    required this.background,
    this.label,
    this.labelColor,
  });

  final String body;
  final String time;
  final bool atEnd;
  final Color background;
  final String? label;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const r = Radius.circular(18);
    const tail = Radius.circular(6);
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadiusDirectional.only(
          topStart: r,
          topEnd: r,
          bottomStart: atEnd ? r : tail,
          bottomEnd: atEnd ? tail : r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            body,
            textDirection: writtenDirection(body),
            textAlign: Directionality.of(context) == TextDirection.rtl
                ? TextAlign.right
                : TextAlign.left,
            style: MishkatType.body(t).copyWith(fontSize: 13.5, height: 1.75),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            textAlign: TextAlign.end,
            style: MishkatType.caption(t).copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
    return Align(
      alignment: atEnd
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 262),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: TextStyle(
                  fontFamily: kUiFont,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: labelColor ?? t.inkMuted,
                ),
              ),
              const SizedBox(height: 4),
            ],
            bubble,
          ],
        ),
      ),
    );
  }
}

/// A centred date between messages: «٢٤ سبتمبر».
class DayDivider extends StatelessWidget {
  const DayDivider(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    // 400, not the caption's 300: at 11px a light weight measures under
    // 4.5:1 once antialiased.
    style: MishkatType.caption(
      context.tokens,
    ).copyWith(fontSize: 11, fontWeight: FontWeight.w400),
  );
}

/// The reply field and its round send button.
class Composer extends StatefulWidget {
  const Composer({super.key, required this.hint, required this.onSend});

  final String hint;

  /// Returns false when the message could not be sent, keeping the text.
  final Future<bool> Function(String body) onSend;

  @override
  State<Composer> createState() => _ComposerState();
}

class _ComposerState extends State<Composer> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await widget.onSend(body);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    final canSend = _controller.text.trim().isNotEmpty && !_sending;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: FeedbackField(
            controller: _controller,
            hint: widget.hint,
            minLines: 1,
            maxLines: 4,
            maxLength: 2000,
            pill: true,
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          enabled: canSend,
          label: l.sendReply,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: canSend ? _send : null,
            child: AnimatedOpacity(
              duration: Motion.of(context, Motion.fast),
              opacity: canSend ? 1 : 0.45,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.isDark ? t.cta : t.primary,
                  shape: BoxShape.circle,
                ),
                child: MishkatIcon(
                  MIcon.send,
                  color: t.isDark ? t.onCta : t.onPrimary,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The white field on the feedback sheet and composers: line border,
/// accentText when focused.
class FeedbackField extends StatelessWidget {
  const FeedbackField({
    super.key,
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.pill = false,
    this.keyboardType,
    this.textDirection,
    this.errorText,
    this.semanticLabel,
  });

  final TextEditingController controller;
  final String hint;
  final int minLines, maxLines;
  final int? maxLength;

  /// Fully rounded, for a one-line composer.
  final bool pill;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final String? errorText;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final radius = BorderRadius.circular(pill ? 24 : Radii.lg);
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: c, width: w),
    );
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textDirection: textDirection,
      textInputAction: maxLines == 1 ? TextInputAction.done : null,
      style: MishkatType.body(t).copyWith(fontSize: 14, height: 1.8),
      cursorColor: t.accentText,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: t.surfaceRaised,
        hintText: hint,
        hintStyle: MishkatType.body(
          t,
        ).copyWith(fontSize: 13.5, color: t.inkFaint),
        counterText: '',
        // A tap target like any other: at least 48px tall.
        constraints: const BoxConstraints(minHeight: Sizes.touchMin),
        errorText: errorText,
        labelText: null,
        semanticCounterText: '',
        contentPadding: EdgeInsets.symmetric(
          horizontal: pill ? 16 : 14,
          vertical: pill ? 13 : 12,
        ),
        enabledBorder: border(t.line, 1),
        focusedBorder: border(t.accentText, 1.5),
        errorBorder: border(t.error, 1),
        focusedErrorBorder: border(t.error, 1.5),
      ),
    );
  }
}
