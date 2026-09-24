# Task: apply the Mishkat Al-Wird "2a Dusk Grid" redesign

You are working in the `mishkat` Flutter repo. The approved design lives in `design-handoff/`. Read these first, in this order:
1. `design-handoff/design-system.md` (rules, tokens, components, migration)
2. `design-handoff/design/Mishkat 2a Screens.dc.html` (open the source — exact values are inline) and `design-handoff/screens/*.png`
3. The repo's `CLAUDE.md` (technical rules that still apply)

## Ground rules
- This is a visual redesign. Do not change notification scheduling, the pure `buildSchedule`, offline behaviour, data models beyond settings, app IDs, or any religious text in `assets/data/athkar.json`.
- Keep existing uncommitted changes. Work on branch `feat/redesign-2a`, one commit per phase, and no Claude/Codex attribution in commits (repo rule).
- The user has authorised replacing the old visual rules in `CLAUDE.md`: three palettes, a dark-only reader, and `gold` naming.
- Colours only via `context.tokens` (MishkatTokens). No raw hex in widgets.
- Every icon comes from `assets/icons/*.svg` via `MishkatIcon`. Delete the inline path strings in `app_icons.dart`.
- `flutter analyze` must be clean and `flutter test` green at the end of every phase.

## Phase 1 — Foundation
- Copy `design-handoff/icons/svg/*` → `assets/icons/`. Copy `design-handoff/brand/svg/*` → `assets/branding/svg/` and `brand/png/*` → `assets/branding/png/`.
- Add the fonts (already downloaded into `assets/fonts/`) and assets to `pubspec.yaml` using `config/pubspec-additions.yaml`.
- Add `lib/core/theme/mishkat_tokens.dart` and `lib/core/widgets/mishkat_icon.dart` from the handoff. Point `buildAppTheme` at `buildMishkatTheme`. Keep the `context.tokens` extension name, re-typed to MishkatTokens.
- Remove `AppPalette`, `palettes.dart` and the palette field from `AppSettings`. In `settings_store.dart`, stop reading `palette` and delete that key once on load. Language, appearance, text size, Quranic font and onboarding state must survive. Add a unit test for this migration.
- Replace `ThikrTextSize.sizeFor` (it shrinks long athkar) with the fixed `ThikrSize` enum (24/29/35). Long text scrolls.
- Rewrite `test/theme_test.dart`: light/dark resolve, contrast ≥4.5:1 for ink, inkMuted, accentText and onPrimary on their backgrounds (write a small WCAG helper), and `glow` never used as text.

## Phase 2 — Brand surfaces
- Run the launcher-icon generator (iOS + legacy mipmaps only) and the splash generator with `config/*.yaml`. Then copy `design-handoff/android/app/src/main/res/` over `android/app/src/main/res/`. Delete any `drawable-*dpi/ic_launcher_foreground.png`, because density PNGs would override the vector adaptive icon. Verify the icon on a circular-mask launcher.
- Notifications: `AndroidInitializationSettings('@drawable/ic_stat_mishkat')` and `color: Color(0xFF4A2A4D)` in `AndroidNotificationDetails`. Do not attempt custom notification layouts.
- `BrandMark` renders `assets/branding/svg/symbol-color.svg` (or `-dark`), using `symbol-small-color.svg` under 32 px.
- Share card: match board 3.5 (dark aubergine plus a light stone variant). Long athkar render at 1080×1350 instead of shrinking.

## Phase 3 — Screens (match the board number for number)
Onboarding 1.1–1.4 · Home 2.1–2.3 (day band, "now" module with one primary button, library list) · Tasbih 2.4 · Reader 3.1–3.3 (the reader follows appearance: light or dark, not always dark) · Completion 3.4 · Reminders 4.1–4.2 · Time sheet 4.3 · OEM sheet 4.4 · Favourites 5.1–5.2 · Progress 5.3 · Settings 5.4 (remove the colour-theme picker) · Error 5.5.
Fix these known bugs on the way:
- Home "تعديل" has an empty `onTap`. The day band opens Reminders; "ابدأ" opens the due routine.
- The streak chip shows "· يوم" at zero. Use «ابدأ تتابعك اليوم» / "Start your streak today".
- `_LoadFailure` prints a raw exception. Use the 5.5 design and send the error to Diagnostics.

## Phase 4 — Accessibility and polish
- Every icon-only button gets a `semanticLabel` and a ≥48 px hit area. The counter surface announces "remaining N of M".
- Honour `MediaQuery.disableAnimations` through `Motion.of`.
- Check 200% text scale, a 320 px-wide screen, the longest thikr, AR and EN, light and dark. Fix any overflow.
- Directional icons use `MIcon.chevronRight` etc. with `matchTextDirection`. Never hand-flip them.

## Phase 5 — Tests, docs, goldens
- Update widget tests that search for old strings or palettes.
- Regenerate goldens with `flutter test test/golden --update-goldens`. Add goldens for home dark EN, reader light AR, reader dark AR (long), and the settings sheet. Open each PNG and compare it against the board.
- Update `CLAUDE.md` and the README: one identity (2a), a reader that follows appearance, token names, and the icon rule. Update `docs/store-listing.md` to name the app مشكاة الورد / Mishkat Al-Wird and drop "three colour themes".
- Finish with a summary: files changed, before/after golden pairs, anything you couldn't match, and remaining risks.
