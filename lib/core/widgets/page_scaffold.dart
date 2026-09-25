import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/mishkat_tokens.dart';
import 'app_sheet.dart' show dismissKeyboard;
import 'buttons.dart';
import 'mishkat_icon.dart';

/// Pushes a full page: Settings, Account, Feedback, a thread, the Inbox.
/// Leaving it always closes the keyboard (a thread's composer may be focused).
Future<T?> pushPage<T>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context)
        .push<T>(MaterialPageRoute(builder: builder))
        .whenComplete(dismissKeyboard);

/// A pushed page: back button and title on the page background, then the
/// body. Back returns to where the user came from, so there is no «تم».
class PageScaffold extends StatefulWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.divider = false,
  });

  final String title;
  final String? subtitle;

  /// Beside the title: the Inbox's unread count, a thread's status chip.
  final Widget? trailing;
  final Widget body;

  /// Pinned under the body: a composer, "New message".
  final Widget? bottom;

  /// A hairline under the header once the body has scrolled beneath it
  /// (Settings, board AF 16a: absent at the top, present when scrolled).
  final bool divider;

  @override
  State<PageScaffold> createState() => _PageScaffoldState();
}

class _PageScaffoldState extends State<PageScaffold> {
  bool _scrolled = false;

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    final scrolled = n.metrics.pixels > n.metrics.minScrollExtent;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: widget.title,
              subtitle: widget.subtitle,
              trailing: widget.trailing,
              divider: widget.divider && _scrolled,
              // Room for the hairline, kept whether or not it shows so the
              // header never jumps.
              bottomGap: widget.divider ? 12 : 0,
            ),
            Expanded(
              child: widget.divider
                  ? NotificationListener<ScrollNotification>(
                      onNotification: _onScroll,
                      child: widget.body,
                    )
                  : widget.body,
            ),
            ?widget.bottom,
          ],
        ),
      ),
    );
  }
}

/// 44px back button on surface, then a 17/500 title (15/500 over a caption
/// when there is a [subtitle]).
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.divider = false,
    this.bottomGap = 0,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool divider;
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, bottomGap),
      foregroundDecoration: divider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: t.line)),
            )
          : null,
      child: Row(
        children: [
          IconCircleButton(
            icon: MIcon.arrowLeft,
            iconSize: 18,
            semanticLabel: l.back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MishkatType.headline(
                      t,
                    ).copyWith(fontSize: subtitle == null ? 17 : 15),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: MishkatType.caption(t).copyWith(fontSize: 11.5),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
  }
}
