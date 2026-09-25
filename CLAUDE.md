# Mishkat Al-Wird (مِشْكَاةُ الوِرْدِ) — Athkar app

Arabic/English athkar app whose headline feature is **reminders that actually
arrive**: أذكار الصباح، المساء، النوم، الاستيقاظ. An optional Apple/Google
account syncs progress, favourites and settings, and users can send feedback
that the owner answers from an in-app inbox.

Design source of truth: Claude Design project `733cc592-656e-4253-808b-b813f6dca024`.
The approved visual design is **2a "Dusk Grid"**: `Mishkat 2a Screens.dc.html`
is the screen board (25 screens and states, AR/EN, light/dark) and its handoff
— tokens, icons, brand kit, reference PNGs — is committed in
`assets/mishkat-2a-handoff/`. Read the board before changing a screen.
Accounts, feedback, the owner inbox and the Settings page are on the extension
board **AF** (`Mishkat AF Accounts Feedback.dc.html`, in the handoff's
`design/`), same tokens and components; its flow PNGs are too large for the
design API, so review against the board HTML.
`AthkarPhone.dc.html` is the earlier prototype: still the reference for the
state machine and content, but its three themes and dark-only reader are
superseded. `ios-frame.jsx` / `android-frame.jsx` are canvas device bezels,
**not** app design; do not port them.

## Working conventions

- **One branch per feature**, off `main`, merged by PR. Branch names: `feat/…`,
  `chore/…`, `fix/…`.
- **No Claude attribution in git history** — no `Co-Authored-By` trailer and no
  "Generated with Claude Code" footer on commits or PR bodies.
- `flutter analyze` clean and `flutter test` green before every PR.

## Non-negotiable technical decisions

**Reminders are local notifications, never FCM.** FCM needs internet, gives no
delivery-time guarantee, and cannot fire at a device-local wall-clock time.
Feedback replies do not change this: they show as an in-app dot, refreshed on
launch, resume and pull-to-refresh, never as a push. Firebase is Hosting for
the share-link site, Auth + Firestore + App Check for the optional account and
feedback, and (not yet wired) Crashlytics + Analytics — see `docs/firebase.md`.

**The account is optional and never gates anything.** There is no login screen
and nothing waits on Firebase: `startCloud()` (`lib/services/cloud_bootstrap.dart`)
returns no overrides when Firebase cannot start, and every account and feedback
surface then hides (`cloudAvailableProvider`). All of it sits behind seams —
`AuthService`, `SyncRemote`, `FeedbackRepository` — whose defaults do nothing,
so widget tests use the fakes in `test/support/cloud_fakes.dart` and never
touch Firebase. An anonymous Firebase user exists only to receive feedback
replies; everywhere in the UI it counts as signed out.

**Sync is local-first; drift and prefs stay the source of truth.** Each local
write is pushed as it happens (the hooks sit beside `invalidateProgress` in the
reader controller and in each settings controller's `_update`); the account is
pulled on sign-in, resume and «زامن الآن». What wins is decided in the pure
`lib/services/sync/merge.dart` (`test/sync_merge_test.dart`): completions are a
union on `(day, category)`, favourites are last-writer-wins with tombstones
(`Favorites.deletedAt` — never hard-delete a favourite), settings are
last-writer-wins per group on `sync.updatedAt.<group>`. Only a change to a
*synced* value stamps a group — onboarding and a fresh GPS fix must not.
Pulled settings go through `replaceFromSync`, so reminders reschedule via
`currentScheduleProvider` as usual. **Location coordinates never sync**, and
reader checkpoints stay on the device.

**The owner is `admins/{uid}`, set in the console.** The rules and
`isAdminProvider` both read it; never hard-code an email or uid. Only the owner
changes a thread's status or number. `firestore.rules` is tested in
`firestore_rules_test/` — change a write in `FirestoreSyncRemote` or
`FirestoreFeedbackRepository` and the rules suite together.

**Feedback goes through the outbox.** `FeedbackOutbox` saves the draft (with a
pre-generated document id) before touching the network and removes it only
when the server confirms, so a first message sent offline, before any
anonymous user exists, is not lost. Submission is a transaction, which fails
fast offline and is idempotent on retry.

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

**Listen to derived providers, not their inputs.** `ReminderSyncScope` watches
`currentScheduleProvider`, not `reminderSettingsProvider`: a listener on the
settings fires before dependents recompute, so reading the schedule inside it
returns the previous value and the app schedules the configuration the user
just replaced.

**Share links are Universal Links / App Links on `mishkatalwird.com`.**
A shared thikr carries `https://mishkatalwird.com/t/<id>` as text beside the
image (`lib/core/share_link.dart`). With the app installed the OS opens it and
`ShareLinkScope` pushes that one thikr; without it, `share_site/` (Firebase
Hosting) sends the phone to its store. Firebase Dynamic Links is shut down; do
not reach for it. **A thikr id, once shared, is public — never rename one in
`athkar.json`.** The host is written in the entitlements, the manifest, the
constant and the site; `test/share_link_test.dart` checks they agree.
Deploy steps and the fingerprints still owed are in `share_site/README.md`.
The same site serves the privacy policy and terms (`/privacy`, `/terms`,
`/en/…`), opened from Settings through `externalLinkLauncherProvider`. They
mirror `docs/privacy-policy.md` and `docs/terms.md`; change the page and the
doc together.

**Location is optional, never required.** `adhan` is a solar calculation, so
prayer times are computed offline; only the position lookup touches the
platform. Declining location falls back to a named city from `kPrayerCities`,
and no position at all falls back to the fixed clock times with the UI saying
so. Coarse accuracy only — prayer times shift by seconds across a city.

**Do not use drift's `watch()` streams.** Favourites and completions change
only when the user acts, so a live query buys nothing — and an open drift
subscription schedules a timer on cancellation that stalls the widget-test
binding indefinitely. Use futures and call `invalidateProgress(ref)` after a
write.

**Arabic plural agreement is not optional.** "١ ساعات" is wrong; use ICU plural
forms with a `num` for selection and a separately localized digit string for
display, as `streakDays` and `athkarCountLabel` do (`test/plurals_test.dart`).

**Diagnostics answer one question.** `Diagnostics` exists to compare reminders
*scheduled* against reminders *opened*, split by whether exact alarms were
allowed. That is how a device class that silently drops alarms is detected from
the field. Do not add events that record what a user read, when they pray,
where they are, or anything they wrote in feedback. The default implementation is a no-op; Firebase is not wired
because it needs a project only the app's owner can create.

**Branding comes from the 2a handoff's exports.** `assets/branding/png/` holds
the launcher-icon and splash generator inputs and is **not** bundled;
`assets/branding/svg/` holds the two marks `BrandMark` draws (the full symbol
and the small cut used below 32px), recoloured from tokens. Android's adaptive
and themed icon and the `ic_stat_mishkat` notification icon are vector XML in
`res/drawable/` — never let a density-qualified `ic_launcher_foreground.png`
shadow them. Native brand colours are named by role in `values/colors.xml` and
the `flutter_native_splash` block; `test/branding_test.dart` pins them to
`MishkatTokens` via `BrandColors`.

**Anything that reads the wall clock goes through `clockProvider`.** Never call
`DateTime.now()` in a widget or service. Home's "now" module and day band do
this; the scheduler depends on it, since its correctness is entirely about
what time it thinks it is — and time-dependent UI silently rots golden files.

**Home's "now" state is derived, never drawn from the board.** `resolveHomeNow`
(`lib/features/home/home_now.dart`) is pure and unit-tested: each routine owns
the window from its time to the next routine's. `slotTimeOn` mirrors
`buildSchedule`'s slot-time rule; change the two together, and
`test/home_now_test.dart` checks they agree.

**Colours come from `MishkatTokens` only.** Read `context.tokens.primary`,
never a raw hex. There is one identity with light, dark and system appearance,
and the reader follows it like every other screen. `glow` is a fill (bars,
beads, the lamp) and never text — coloured text is `accentText`; a source scan
in `test/theme_test.dart` enforces this. `primary` in dark is a surface, so
filled controls switch to `cta` there. Colours used outside the widget tree
(notification tint, launch screens) go through `BrandColors`.

**Every icon is an SVG in `assets/icons/`, drawn by `MishkatIcon(MIcon.x)`.**
Directional glyphs set `matchTextDirection`, so write them in LTR terms
(`chevronRight` is "forward") and never flip one by hand. Alexandria has no
check glyph: draw `MIcon.check`, never "✓", which renders as a box.

**Typography.** UI is Alexandria 300/400/500 (static instances of the official
variable font — `assets/fonts/README.md`); athkar are Scheherazade New at a
fixed 24/29/35 with a 2.0 line height, Amiri Quran behind the Quranic-script
setting. A long thikr scrolls inside the reader page with a fade and a cue; it
never shrinks, and a shared card grows taller (1080×1350 and beyond) instead.

**Content accuracy is not an engineering problem.** `assets/data/athkar.json`
is transcribed from the prototype and is **placeholder** — the board says so
itself. The تخريج must be verified by a qualified human before release. No test
catches an error here.

## Milestones

| # | Branch | Scope | State |
|---|---|---|---|
| M1 | `feat/foundation` | Tokens, fonts, ar/en i18n, settings store, app shell | ✅ done |
| M2 | `feat/athkar-reader` | Content, home screen, reader, tasbih | ✅ done |
| M3 | `feat/notification-engine` | Scheduler, permissions ladder, onboarding, deep links | ✅ done |
| M4 | `feat/reminders-ui` | Reminders tab, time sheet, OEM guidance | ✅ done |
| M5 | `feat/prayer-times` | `adhan`, offsets, rolling window | ✅ done |
| M6 | `feat/favorites-progress-share` | drift, favourites, progress, 1080² share card | ✅ done |
| M7 | `feat/firebase` | Icons, splash, diagnostics seam, store prep | ✅ done (Firebase config pending — see `docs/firebase.md`) |
| 2a | `feat/redesign-2a` | Dusk Grid redesign: tokens, fonts, icons, brand, every screen | ✅ done |
| SL | `feat/share-links` | Share links: app_links, entitlements, App Links, store-redirect site | 🚧 app side done; store IDs + deploy pending |
| AF | `feat/accounts-feedback` | Optional Apple/Google account and sync, feedback, owner inbox, Settings page | 🚧 code done; console setup in `docs/firebase.md` |

Prayer-mode offsets: **Fajr −15** (wake), **Fajr +30** (morning),
**Asr +45** (evening); sleep stays a fixed clock time.

## Android SDK pin

`compileSdk`/`targetSdk` are pinned to **36**, not `flutter.compileSdkVersion`
(37): API 37 is unpublished, and the preview installed locally declares a
malformed `AndroidVersion.ApiLevel` of `37.0` that Gradle cannot resolve. There
is also a `dependency_overrides` entry pinning `permission_handler_android` to
12.1.0, because 13.x demands compileSdk 37 while AGP 9 caps at 36 — the two
cannot both be satisfied. Drop both once API 37 ships.

## Layout

```
lib/core/       theme (MishkatTokens, BrandColors), l10n (ARB ar/en, labels), format, widgets
lib/data/       models, local (prefs, drift), repositories
lib/services/   notification, scheduler, prayer times, permissions,
                auth, sync (pure merge + controller), feedback (repository, outbox)
lib/features/   onboarding home reader tasbih reminders favorites progress settings share shell
                account feedback admin
firestore.rules, firestore.indexes.json, firestore_rules_test/
```

## Commands

```bash
flutter pub get
flutter gen-l10n                        # after editing lib/core/l10n/*.arb
flutter analyze
flutter test
flutter test test/golden --update-goldens   # after an intended visual change
flutter run -d <device>
cd firestore_rules_test && npm install && npm test   # rules vs the emulator; JAVA_HOME = Android Studio's jbr
```

Golden files in `test/golden/images/` are one per 2a board screen, rendered at
the board's 340×720 frame and numbered like it (`2_1_home_light_ar.png` is
board 2.1). They load the bundled fonts (`test/golden/font_loader.dart`) so
Arabic shaping is actually exercised — a golden in the fallback font proves
nothing. Review regenerated PNGs side by side with
`assets/mishkat-2a-handoff/screens/` before committing; passing tests are not
a visual review.

`test/responsive_test.dart` renders every main screen and sheet at 320×640 with
200% text in AR/EN, light/dark — an overflow fails it. `test/accessibility_test.dart`
runs Flutter's tap-target, labelled-target and text-contrast guidelines.

Widget tests using the database must await `AppHarness.settleWithDatabase`:
`pumpAndSettle` only drives the animation clock, so a FutureProvider backed by
a real query is still unresolved and the test asserts against an empty screen.

Widget tests must override `athkarLibraryProvider` with a preloaded library:
otherwise `pumpAndSettle` races the asset read and settles on an empty screen.
Tests touching the reader must set `wakelockPlusPlatformInstance` — the package
caches its platform object in a top-level variable on first read, so overriding
`WakelockPlusPlatformInterface.instance` only affects the first test that runs.

Strings live in `lib/core/l10n/app_ar.arb` (template) and `app_en.arb`. ARB keys
must not collide with `AppLocalizations` members — `of` had to become `countOf`.

## Verification that matters

Notification timing **must** be checked on physical hardware. Emulators do not
reproduce Doze or OEM battery killers, and the iOS Simulator does not model the
64-notification cap under real conditions. Minimum passes: fires with the app
killed, survives reboot, survives 24h idle, degrades correctly when exact alarms
are denied.
