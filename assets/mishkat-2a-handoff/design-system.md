# Mishkat Al-Wird — design system (2a "Dusk Grid")

Calm, structured and warm. It uses 1c's dusk palette and lamp, organised on 1b's modular grid. There is one brand identity, with light, dark and system appearance.

## Colour (semantic)

| Token | Light | Dark | Use |
|---|---|---|---|
| bg | #EFEBE7 | #1B1320 | Screen |
| surface | #F9F7F4 | #261B2C | Cards, lists, reader page, sheets |
| surfaceRaised | #FFFFFF | #2E2234 | Selected segment, text on busy bg |
| line / lineSoft | #DDD5CE / #E7E0DA | #3A2C40 / #332539 | Dividers, outlines |
| ink | #2A1B2C | #F1E9EE | Primary text (≈13:1 / ≈14:1) |
| inkMuted | #6E5F6B | #BBA9B6 | Secondary text (≈5.0 / ≈8.6) |
| inkFaint | #7E6F7B | #9C8A98 | Inactive nav icons — not body text |
| primary | #4A2A4D | #261B2C (+ glowLine border) | The "now" module, primary buttons, done states |
| onPrimary / onPrimaryMuted | #FFFFFF / #E3D2DC | #F1E9EE / #BBA9B6 | Text on primary |
| cta / onCta | #E5B3B9 / #2A1B2C | #E5B3B9 / #1B1320 | The single start button inside the now module; primary buttons in dark |
| glow | #C9939A | #E5B3B9 | **Fill only on light**: current-routine bar, counted bead, lamp |
| glowSoft | #F2E1DF | #3A2C40 | Icon chips, active nav pill, empty-state halos |
| accentText | #8E4E5A | #E5B3B9 | Coloured text: links, "الآن" label on light (≈5.2) |
| warn* | amber ramp | amber ramp | Exact-alarm and notifications-off banners |
| error* | #A13A3A | #F0A3A3 | Load failure |

Old → new token map for the migration: `accent`→`primary`, `accentInk`→`primary`, `gold`→`glow` (fill) or `accentText` (text), `onGold`→`onCta`, `s2`→`surface`, `s3`→`lineSoft`, `border`→`line`, `muted`→`inkMuted`, `faint`/`navOff`→`inkFaint`, `card1/card2/cardInk/cardSub/cardChip`→`primary/onPrimary/onPrimaryMuted/cta`. The `rd*` reader ramp is deleted, because the reader uses the normal tokens.

## Type

- **UI:** Alexandria 300/400/500. Display 30/500, Title 20/500, Headline 17/500, Body 14.5/400, Body-light 14.5/300 (never below 14px), Label 12.5/500, Caption 12/300, Counter 60/300.
- **Athkar:** Scheherazade New at fixed sizes 24/29/35 with 2.0 line height. Amiri Quran sits behind the "الخط القرآني" toggle. Long athkar **scroll inside the reader page, with a soft fade and a «مرّر للمتابعة» cue**. They never shrink.
- Arabic-Indic digits and ص/م in Arabic; Latin digits and AM/PM in English. Always `white-space: nowrap` on times (Flutter: `softWrap: false` or `maxLines: 1` inside flexible rows).

## Space, shape, size

Space: 4/8/12/16/20/24/32/40, with a screen inline padding of 20. Radius: 10/14/18/24/pill, with the icon tile at 26% of its size. Touch targets are at least 48px, buttons 52px tall and pill-shaped, list rows 58–62px. The system is flat: no shadows except on bottom sheets.

## Components

- **Day band:** 4 equal columns, each with a 4px bar, a label and a time. Bar states: done = primary, now = glow, later = line. Tapping it opens Reminders.
- **Now module:** a primary-filled card (dark: surface + glowLine border) with the "الآن" label, routine name (Display), a meta line, and one full-width CTA. It is the only coloured block on Home.
- **Library list:** rows with a 34px round glowSoft icon chip, label and count.
- **Nav bar:** 4 items. The active one gets a 56×30 glowSoft pill behind the icon. Labels are always shown.
- **Segmented control:** a lineSoft track with a surfaceRaised thumb, pill-shaped and 40px tall.
- **Switch:** 46×28, on = primary, off = trackOff.
- **Time chip:** a 38px pill on bg with a 500-weight time.
- **Banner:** a warn or error ramp at 18px radius, with a glyph, title, one-line body and one action.
- **Bottom sheet:** 28px top radius, grab handle, surface background, scrim at 60%.
- **Reader counter:** Counter numeral with bead dots when the count ≤ 11, otherwise the numeral plus "من N". Round 52px prev/next buttons. The whole page is the tap target.

## Motion

120 / 200 / 320ms on cubic(0.2,0,0,1). Tap pulse: 140ms scale to 0.97 on the counter. After the last count, auto-advance waits 480ms. With reduced motion, all durations are 0, there is no pulse, and progress jumps instantly.

## Icons

`icons/svg`: 24 grid, 1.5 stroke, round caps and joins, `currentColor`. Directional icons (chevrons, arrows, reset, external) mirror automatically under RTL via `matchTextDirection`. Routine glyphs avoid mosque, crescent and lantern imagery.

## Brand

Symbol: a rounded wall tile holding an arched niche band, with a round lamp resting inside. Below 32px use `symbol-small-color.svg`, where the band closes into a solid doorway. On Android the notification icon is a one-colour niche with the lamp knocked out (`ic_stat_mishkat`). Wordmark: «مشكاة» in Alexandria 500 leads, with «الورد» in 300 at about half the size. In English: "Mishkat" 500 + "Al-Wird" 300. Tagline: نور الذكر اليومي · The Light of Daily Remembrance.

## Accessibility checklist

Contrast is at least 4.5:1 for all text and 3:1 for icons and bars. Every icon-only control has a semantic label. The counter announces remaining counts. Layouts hold at 200% text and 320px width. RTL and LTR are both verified. Arabic diacritics must not clip, so thikr line height stays at 2.0 or more.
