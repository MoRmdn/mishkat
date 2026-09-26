import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/mishkat_tokens.dart';
import '../../core/widgets/mishkat_icon.dart';
import '../favorites/favorites_tab.dart';
import '../home/home_tab.dart';
import '../progress/progress_tab.dart';
import '../reminders/reminders_tab.dart';

enum ShellTab { home, reminders, favorites, progress }

final shellTabProvider = NotifierProvider<ShellTabController, ShellTab>(
  ShellTabController.new,
);

class ShellTabController extends Notifier<ShellTab> {
  @override
  ShellTab build() => ShellTab.home;

  void select(ShellTab tab) => state = tab;
}

/// The four tabs and the bottom navigation. Each tab draws its own header:
/// Home has the brand row, the others a page title.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final tab = ref.watch(shellTabProvider);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: tab.index,
                children: const [
                  HomeTab(),
                  RemindersTab(),
                  FavoritesTab(),
                  ProgressTab(),
                ],
              ),
            ),
            const _BottomNav(),
          ],
        ),
      ),
    );
  }
}

/// Four items with labels always shown. The active one sits on a 56×30
/// glowSoft pill.
class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final current = ref.watch(shellTabProvider);

    Widget item(ShellTab tab, MIcon iconGlyph, String name) {
      final selected = tab == current;
      // Inactive icons may be faint; their labels are text and need 4.5:1.
      final icon = selected ? t.ink : t.inkFaint;
      final label = selected ? t.ink : t.inkMuted;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          label: name,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(shellTabProvider.notifier).select(tab),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Sizes.touchMin),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: Motion.of(context, Motion.base),
                    curve: Motion.curve,
                    width: 56,
                    height: 30,
                    decoration: BoxDecoration(
                      color: selected
                          ? t.glowSoft
                          : t.glowSoft.withValues(alpha: 0),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: MishkatIcon(iconGlyph, color: icon),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: kUiFont,
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                      color: label,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: t.bg,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
          child: Row(
            children: [
              item(ShellTab.home, MIcon.home, l.navHome),
              item(ShellTab.reminders, MIcon.bell, l.navReminders),
              item(ShellTab.favorites, MIcon.heart, l.navFavorites),
              item(ShellTab.progress, MIcon.progress, l.navProgress),
            ],
          ),
        ),
      ),
    );
  }
}
