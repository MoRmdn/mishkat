import 'package:flutter/material.dart';

import '../theme/mishkat_tokens.dart';

/// The app's bottom sheet: 28px top radius, grab handle, surface fill, the
/// token scrim, and the only shadow in the system. Scrolls internally past
/// 88% of the screen.
Future<T?> showAppSheet<T>(BuildContext context, WidgetBuilder builder) {
  final t = context.tokens;
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: t.scrim,
    isScrollControlled: true,
    // Sheets slide at the system's pace unless motion is reduced.
    sheetAnimationStyle: Motion.reduced(context)
        ? AnimationStyle.noAnimation
        : null,
    builder: (context) => AppSheet(child: Builder(builder: builder)),
  );
}

class AppSheet extends StatelessWidget {
  const AppSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: MishkatTokens.dark.bg.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: t.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A sheet's title, 19/500.
class SheetTitle extends StatelessWidget {
  const SheetTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: MishkatType.title(context.tokens).copyWith(fontSize: 19),
    ),
  );
}

/// A small section label in sheets and settings, 12/500 muted.
class SheetSectionLabel extends StatelessWidget {
  const SheetSectionLabel(this.text, {super.key, this.topPadding = 16});

  final String text;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topPadding, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: kUiFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: context.tokens.inkMuted,
        ),
      ),
    );
  }
}
