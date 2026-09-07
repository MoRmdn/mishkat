# مشكاة · Mishkat

An Arabic/English athkar app for iOS and Android, built in Flutter.

Its headline feature is **reminders that actually arrive** — أذكار الصباح،
المساء، النوم، الاستيقاظ — and most of the engineering effort goes there rather
than into the reading UI.

## What it does

- **Athkar reader.** The whole screen is the counter: tap anywhere to count
  down. A ring tracks the current thikr and a bar tracks the session. Reaching
  zero advances after a beat so the completion is visible.
- **Timed reminders**, in two modes. Fixed clock times by default, or anchored
  to prayer times (Fajr −15 for waking, Fajr +30 for the morning, Asr +45 for
  the evening; bedtime stays a fixed hour).
- **Three colour themes** — stone teal, indigo, olive — each in light and dark,
  plus a reader palette that stays dark-toned in every build for night use.
- **Fully bilingual.** Arabic is RTL with Arabic-Indic numerals and ص/م;
  English is LTR with Latin numerals and AM/PM. The Arabic text of a thikr is
  never replaced by a translation — in English the meaning sits underneath it.
- **Favourites, streaks and progress.** A streak counts consecutive days and
  is not broken until a day is missed entirely — it does not read as lost every
  morning before you have opened the app.
- **Share a thikr as an image**, rendered at 1080×1080 with its تخريج always
  travelling with the text.
- **Completely offline.** No account, no sign-in, nothing sent anywhere.

## Two decisions worth knowing up front

**Reminders are local notifications, never Firebase Cloud Messaging.** FCM
needs a network, gives no delivery-time guarantee, and cannot fire at a
device-local wall-clock time. The OS schedules these itself, so they arrive on
a plane. Firebase's only role in this app is crash reporting and analytics.

**The schedule is visible state.** The app prints what the operating system
actually holds — "repeats daily, no need to open the app", or the date coverage
runs out and how many notifications are pending against iOS's cap of 64.
Reminder systems fail silently; this one is built to be checkable.

## Getting started

Requires Flutter 3.44+ and Dart 3.12+.

```bash
flutter pub get
flutter run -d <device>
```

Content, strings and themes need no code generation beyond localizations:

```bash
flutter gen-l10n     # after editing lib/core/l10n/*.arb
```

## Project layout

```
lib/core/       theme tokens, ar/en localizations, formatting, shared widgets
lib/data/       models, local storage, the athkar repository
lib/services/   notification scheduling, permissions
lib/features/   onboarding · home · reader · reminders · settings · shell
assets/data/    athkar.json — the corpus
assets/fonts/   IBM Plex Sans Arabic (UI) and Amiri Quran (thikr text)
```

The one architectural rule that matters: `lib/services/reminder_scheduler.dart`
computes *what the schedule should be* as pure Dart, and
`notification_service.dart` only applies that to the OS. Scheduling bugs do not
surface until someone misses a reminder, so that half is testable without a
device.

## Testing

```bash
flutter analyze
flutter test
flutter test test/golden --update-goldens   # after an intended visual change
```

Golden files under `test/golden/images/` cover home, the reader, the reminders
tab, onboarding and the settings sheet across theme builds and both languages.
They render with the real bundled fonts, so Arabic shaping is genuinely
exercised rather than approximated in a fallback face.

**Notification delivery must be verified on physical hardware.** Emulators do
not reproduce Doze or the aggressive background-app killing that Xiaomi, Huawei
and Oppo devices do, and those are the single biggest cause of a reminder never
arriving. The minimum passes are: fires with the app killed, survives a reboot,
survives 24 hours idle, and degrades correctly when exact alarms are denied.

## Content accuracy

`assets/data/athkar.json` is **placeholder content**, transcribed from the
design prototype. The text and its تخريج must be reviewed and corrected by a
qualified person before release. No test can catch an error here, and a
mistaken attribution is the most damaging defect this app could ship. A guard
test fails if the placeholder marker is removed, so replacing the corpus is a
deliberate act rather than a quiet one.

## Status

| Milestone | Scope | State |
|---|---|---|
| M1 | Design tokens, fonts, ar/en i18n, settings, app shell | ✅ |
| M2 | Athkar content, home screen, counting reader, tasbih | ✅ |
| M3 | Scheduler, notification service, permission ladder, onboarding | ✅ |
| M4 | Reminders tab, slot time sheet, OEM guidance | ✅ |
| M5 | Prayer times (`adhan`), calculation method, rolling window | ✅ |
| M6 | Favourites, streaks and progress, share-as-image | ✅ |
| M7 | Icons, splash, diagnostics seam, store preparation | ✅ |

Prayer times are computed on-device and offline. If location is declined the
app uses a city chosen from a list; if there is no position at all it falls
back to the fixed clock times and says so rather than scheduling nothing.

## Before shipping

Four things stand between this and a store submission, all documented in
`docs/store-listing.md`:

1. **Replace the athkar corpus** with a human-verified dataset (see above).
2. **Configure Firebase** if diagnostics are wanted — `docs/firebase.md`. The
   app is fully functional without it; the default implementation is a no-op.
3. **Set a release signing key.** The release build currently signs with the
   debug key.
4. **Verify reminder delivery on physical hardware.**

`docs/privacy-policy.md` is drafted and reflects what the app actually does.

## Licences

Fonts are bundled under the SIL Open Font License: **IBM Plex Sans Arabic** and
**Amiri Quran**.
