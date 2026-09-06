# Mishkat (مشكاة) — Athkar app

Arabic/English athkar app whose headline feature is **reminders that actually
arrive**: أذكار الصباح، المساء، النوم، الاستيقاظ.

Design source of truth: Claude Design project `733cc592-656e-4253-808b-b813f6dca024`.
`AthkarPhone.dc.html` is a working prototype with a full state machine, three
themes, two languages and real content — read it before building a screen.
`ios-frame.jsx` / `android-frame.jsx` are canvas device bezels, **not** app
design; do not port them.

## Working conventions

- **One branch per feature**, off `main`, merged by PR. Branch names: `feat/…`,
  `chore/…`, `fix/…`.
- **No Claude attribution in git history** — no `Co-Authored-By` trailer and no
  "Generated with Claude Code" footer on commits or PR bodies.
- `flutter analyze` clean and `flutter test` green before every PR.

## Non-negotiable technical decisions

**Reminders are local notifications, never FCM.** FCM needs internet, gives no
delivery-time guarantee, and cannot fire at a device-local wall-clock time.
Firebase is Crashlytics + Analytics only. The app works fully offline: no Auth,
no Firestore, no login screen.

**Two scheduling strategies, and they are not interchangeable:**

| Mode | Mechanism | Cost |
|---|---|---|
| Fixed time (default) | one repeating notification per slot via `matchDateTimeComponents: DateTimeComponents.time` | ~4 pending forever, no upkeep |
| Prayer time (opt-in) | discrete instances in a rolling **14-day** window, topped up on launch/resume, notification tap, and Android boot | ≤56 pending, against iOS's cap of 64 |

**The schedule is visible state.** Home and the reminders tab print what the OS
actually holds ("مجدولة حتى…", "٥٦ من ٦٤"). Never let the window expire or the
iOS cap bite silently.

**Never request `USE_EXACT_ALARM`.** Google Play restricts it to alarm/clock/
calendar apps and this app would risk rejection. Request `SCHEDULE_EXACT_ALARM`
at runtime and degrade to `inexactAllowWhileIdle` when denied, surfacing the
persistent banner the design specifies.

**`reminder_scheduler.dart` stays pure.** It computes what the schedule *should*
be — `buildSchedule(settings, prayerTimes, now)` — and `notification_service.dart`
applies it to the OS. Scheduling bugs are invisible until a user misses a
reminder, so this half must be unit-testable without a device.

**Colours come from `AppTokens` only.** Read `context.tokens.accent`, never a
raw hex and never `kPalettes` directly. Three palettes × light/dark = six
builds, plus a reader ramp that stays dark-toned in every build.

**Content accuracy is not an engineering problem.** `assets/data/athkar.json`
is transcribed from the prototype and is **placeholder** — the board says so
itself. The تخريج must be verified by a qualified human before release. No test
catches an error here.

## Milestones

| # | Branch | Scope | State |
|---|---|---|---|
| M1 | `feat/foundation` | Tokens, fonts, ar/en i18n, settings store, app shell | ✅ done |
| M2 | `feat/athkar-reader` | Content, home screen, reader, tasbih | |
| M3 | `feat/notification-engine` | Scheduler, permissions ladder, onboarding, deep links | |
| M4 | `feat/reminders-ui` | Reminders tab, time sheet, OEM guidance | |
| M5 | `feat/prayer-times` | `adhan`, offsets, rolling window | |
| M6 | `feat/favorites-progress-share` | drift, favourites, progress, 1080² share card | |
| M7 | `feat/firebase`, `chore/release-prep` | Crashlytics, Analytics, icons, store prep | |

Prayer-mode offsets: **Fajr −15** (wake), **Fajr +30** (morning),
**Asr +45** (evening); sleep stays a fixed clock time.

## Layout

```
lib/core/       theme (palettes, AppTokens), l10n (ARB ar/en), format, widgets
lib/data/       models, local (prefs, drift), repositories
lib/services/   notification, scheduler, prayer times, permissions
lib/features/   onboarding home reader reminders favorites progress settings share shell
```

## Commands

```bash
flutter pub get
flutter gen-l10n          # after editing lib/core/l10n/*.arb
flutter analyze
flutter test
flutter run -d <device>
```

Strings live in `lib/core/l10n/app_ar.arb` (template) and `app_en.arb`. ARB keys
must not collide with `AppLocalizations` members — `of` had to become `countOf`.

## Verification that matters

Notification timing **must** be checked on physical hardware. Emulators do not
reproduce Doze or OEM battery killers, and the iOS Simulator does not model the
64-notification cap under real conditions. Minimum passes: fires with the app
killed, survives reboot, survives 24h idle, degrades correctly when exact alarms
are denied.
