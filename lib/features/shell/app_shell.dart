import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format/hijri_date.dart';
import '../../core/format/numerals.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_icons.dart';
import '../../core/widgets/streak_ring.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_sheet.dart';

enum ShellTab { home, reminders, favorites, progress }

final shellTabProvider = NotifierProvider<ShellTabController, ShellTab>(
  ShellTabController.new,
);

class ShellTabController extends Notifier<ShellTab> {
  @override
  ShellTab build() => ShellTab.home;

  void select(ShellTab tab) => state = tab;
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final tab = ref.watch(shellTabProvider);
    final lang = ref.watch(settingsProvider).language;

    final title = switch (tab) {
      ShellTab.home => l.titleHome,
      ShellTab.reminders => l.titleReminders,
      ShellTab.favorites => l.titleFavorites,
      ShellTab.progress => l.titleProgress,
    };

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(title: title, languageCode: lang.name),
            Expanded(
              child: IndexedStack(
                index: tab.index,
                children: const [
                  _TabPlaceholder(tab: ShellTab.home, milestone: 'M2'),
                  _TabPlaceholder(tab: ShellTab.reminders, milestone: 'M4'),
                  _TabPlaceholder(tab: ShellTab.favorites, milestone: 'M6'),
                  _TabPlaceholder(tab: ShellTab.progress, milestone: 'M6'),
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

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.languageCode});

  final String title;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    // Streak is placeholder state until M6 introduces the progress store.
    const streakDays = 12;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatHijriHeader(DateTime.now(), languageCode),
                  style: TextStyle(fontSize: 13, color: t.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: t.surface,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const StreakRing(percent: (streakDays % 30) / 30 * 100),
                const SizedBox(width: 8),
                Text(
                  '${localizeDigits(streakDays, languageCode)} ${L.of(context).dayUnit}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showSettingsSheet(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.surface,
                border: Border.all(color: t.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: GearIcon(color: t.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = L.of(context);
    final current = ref.watch(shellTabProvider);

    Widget item(ShellTab tab, String path, String label) {
      final selected = tab == current;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => ref.read(shellTabProvider.notifier).select(tab),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StrokeIcon(path, color: selected ? t.accent : t.navOff),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: selected ? t.accent : t.navOff,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            item(ShellTab.home, AppIcons.home, l.navHome),
            item(ShellTab.reminders, AppIcons.bell, l.navReminders),
            item(ShellTab.favorites, AppIcons.heart, l.navFavorites),
            item(ShellTab.progress, AppIcons.chart, l.navProgress),
          ],
        ),
      ),
    );
  }
}

/// Stand-in for tabs whose content arrives in a later milestone. Naming the
/// milestone keeps it obvious this is scaffolding, not a finished screen.
class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.tab, required this.milestone});

  final ShellTab tab;
  final String milestone;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tab.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: t.muted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Arrives in $milestone',
              style: TextStyle(fontSize: 13, color: t.faint),
            ),
          ],
        ),
      ),
    );
  }
}
