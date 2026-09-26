# Mishkat Al-Wird — 2a "Dusk Grid" design handoff

Everything needed to apply the approved redesign to `MoRmdn/mishkat`.

## What's inside

| Folder | Contents |
|---|---|
| `HANDOFF_PROMPT.md` | Paste-ready instructions for Claude Code or Codex |
| `design-system.md` | Tokens, type, components, states, accessibility and migration rules |
| `design/Mishkat 2a Screens.dc.html` | The full screen board: 25 screens and states, AR/EN, light/dark. Open it in a browser. |
| `screens/*.png` | The same board as PNGs, one per flow |
| `tokens/mishkat.tokens.json` | Source of truth for colour, type, spacing, radius, motion |
| `flutter/lib/core/theme/mishkat_tokens.dart` | Drop-in ThemeExtension, generated from the tokens |
| `flutter/lib/core/widgets/mishkat_icon.dart` | `MIcon` enum + `MishkatIcon` widget (RTL-aware) |
| `icons/svg/` | 42 UI icons — 24×24, 1.5 stroke, `currentColor` |
| `brand/svg/` | Logo masters: symbol, small-size cut, mono, app icon, notification, splash, AR/EN lockups |
| `brand/png/` | Raster exports only where a platform requires them: iOS 1024 icon, transparent dark and tinted variants, Play 512, and splash (mark at ½ size so Android 12's circle never clips it) |
| `android/app/src/main/res/` | Vector adaptive icon (fore/mono), notification small icon, colours |
| `config/` | `flutter_launcher_icons.yaml`, `flutter_native_splash.yaml`, `pubspec-additions.yaml` |
| `fonts/FONTS.md` | Which fonts to download and their licence |

## Using it with Claude Code or Codex

1. Unzip into the repository root as `design-handoff/`, so paths look like `mishkat/design-handoff/HANDOFF_PROMPT.md`.
2. Download the two fonts listed in `fonts/FONTS.md` into `assets/fonts/`. Agents usually can't download fonts themselves.
3. Create a branch: `git checkout -b feat/redesign-2a`.
4. Start the agent in the repo root:
   - **Claude Code:** run `claude`, then type: *Read design-handoff/HANDOFF_PROMPT.md and carry it out phase by phase. Stop after each phase for my review.*
   - **Codex CLI:** run `codex`, then use the same sentence. You can also copy `HANDOFF_PROMPT.md` into `AGENTS.md` so Codex loads it automatically.
5. Review each phase's diff and the regenerated golden PNGs before letting it continue.

The agent should read `design-system.md` and open the board HTML to check exact values. Every hex, size and radius on the board comes from the tokens.

## Notes

- Lockup SVGs use live Alexandria text so you can edit them. Before print or store use, open them in Figma or Illustrator with Alexandria installed and convert the text to outlines.
- iOS rejects app icons with an alpha channel. The config sets `remove_alpha_ios: true`, so the generator flattens the icon for you.
- Athkar text is the repo's placeholder corpus. The design doesn't change religious text, and the تخريج still needs human verification before release.
