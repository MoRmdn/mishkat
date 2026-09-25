import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/mishkat_tokens.dart';
import 'buttons.dart';
import 'mishkat_icon.dart';

/// Pushes a full page: Settings, Account, Feedback, a thread, the Inbox.
Future<T?> pushPage<T>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: builder));

/// A pushed page: back button and title on the page background, then the
/// body. Back returns to where the user came from, so there is no «تم».
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.divider = false,
    this.top,
  });

  final String title;
  final String? subtitle;

  /// A hairline under the header, for a page whose body scrolls beneath it
  /// (Settings, board AF 16a).
  final bool divider;

  /// Pinned between the header and the body, full width: Settings' account
  /// card.
  final Widget? top;

  /// Beside the title: the Inbox's unread count, a thread's status chip.
  final Widget? trailing;
  final Widget body;

  /// Pinned under the body: a composer, "New message".
  final Widget? bottom;

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
              title: title,
              subtitle: subtitle,
              trailing: trailing,
              divider: divider,
            ),
            ?top,
            Expanded(child: body),
            ?bottom,
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
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = L.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, divider ? 12 : 0),
      decoration: divider
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
