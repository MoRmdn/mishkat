# Store listing

Draft copy for the App Store and Google Play. Arabic is the primary language.

## Name

- Arabic: **مِشْكَاةُ الوِرْدِ**
- English: **Mishkat Al-Wird**

The home-screen label stays short: **مِشْكَاة** / **Mishkat**.

Tagline: نور الذكر اليومي · The Light of Daily Remembrance

## Subtitle / short description

- Arabic: أذكار الصباح والمساء بتذكيرات تصل في وقتها
- English: Morning and evening athkar, with reminders that actually arrive

## Description (English)

Mishkat Al-Wird is an athkar app built around one thing: reminders that arrive when
they should.

Reminders are scheduled by your device itself, so they work with no internet
connection and no account. Choose fixed times, or anchor them to prayer times —
before Fajr for the waking athkar, after Fajr for the morning, after Asr for
the evening.

- أذكار الصباح، المساء، النوم، الاستيقاظ، بعد الصلاة، ومتفرقة
- A tap-anywhere counter, so you never hunt for a small button mid-thikr
- A free tasbih counter
- Streaks and weekly progress
- Save any thikr, and share it as an image with its reference
- Light and dark appearance, or follow your device
- Full Arabic and English, with Arabic-Indic numerals throughout
- Optional sign-in with Apple or Google keeps your streak, favourites and
  settings on every device
- Send suggestions or report a mistake in a thikr, and read the reply in the app
- Works fully offline. Account optional, no tracking, no ads

## Description (Arabic)

مِشْكَاةُ الوِرْدِ تطبيق أذكار همّه الأول أن يصل التذكير في وقته.

التذكيرات تُجدول على جهازك مباشرة، فتعمل دون إنترنت ودون حساب. اختر أوقاتاً
ثابتة، أو اربطها بمواقيت الصلاة — قبل الفجر لأذكار الاستيقاظ، وبعده لأذكار
الصباح، وبعد العصر لأذكار المساء.

- أذكار الصباح والمساء والنوم والاستيقاظ وبعد الصلاة والمتفرقة
- عدّاد باللمس في أي مكان من الشاشة
- سبحة حرة
- تتابع يومي وتقدّم أسبوعي
- حفظ أي ذكر ومشاركته كصورة مع تخريجه
- مظهر فاتح وغامق، أو حسب إعداد الجهاز
- عربي وإنجليزي بالكامل
- تسجيل دخول اختياري بحساب Apple أو Google يحفظ تتابعك ومفضلتك وإعداداتك على كل أجهزتك
- أرسل اقتراحك أو أبلغ عن خطأ في ذكر، واقرأ الرد داخل التطبيق
- يعمل دون إنترنت. الحساب اختياري، بلا تتبّع، بلا إعلانات

## Permissions to declare

| Permission | Why | Optional |
|---|---|---|
| Notifications | Delivering the reminders | Yes — app works, reminders do not |
| Exact alarms (Android 12+) | Reminders arriving at the stated minute | Yes — falls back to inexact |
| Battery optimisation exemption | Some vendors cancel scheduled alarms | Yes |
| Approximate location | Prayer-time calculation, on-device only | Yes — city list is offered instead |

Sign in with Apple and Google Sign-In need no extra runtime permission.

## Data Safety (Google Play) and App Privacy (App Store)

Nothing is collected until the user signs in or sends feedback; everything below
is optional for the user, linked to their account, encrypted in transit, and
deletable in the app (Settings → Account → Delete account). None of it is used
for advertising, tracking or sold.

| Data type (Play category) | Collected when | Purpose |
|---|---|---|
| Name, email address (Personal info) | Signing in | Account management |
| Photos and videos: no. The Google profile picture is stored as a link, not an image | — | — |
| App info and performance / device IDs (app version, OS version, device model, app language, last opened) | Signed in, once per launch | Account management, app functionality (support) |
| User IDs (Personal info) | Signing in, or sending feedback while signed out (anonymous ID) | Account management, app functionality |
| App activity: other actions (routines completed, favourites) | Signed in | App functionality (sync) |
| App info: other (settings, incl. city chosen — not coordinates) | Signed in | App functionality (sync) |
| Messages: other in-app messages (feedback text, optional contact email) | Sending feedback | Developer communications |
| Device or other IDs / diagnostics (app version, OS version, device model) | Feedback with "attach device information" on | Analytics of the reported problem |

Location is **not** collected: coordinates never leave the device, and the
account stores no time zone. If analytics
or crash reporting is enabled in the shipped build, also declare app
interactions and crash logs (see `docs/firebase.md`).

App Store: the same data under "Contact Info", "Identifiers", "User Content"
and "Usage Data", all "Linked to You", none "Used to Track You". Account
deletion is in the app, as guideline 5.1.1(v) requires, and revokes the Sign in
with Apple token.

## Before first submission

- [ ] Replace `assets/data/athkar.json` with a human-verified corpus — see the
      warning in that file and in the README.
- [ ] Check the app icon on a real device's home screen, including Android's
      round mask and themed (monochrome) icons and iOS dark and tinted icons.
- [ ] Use the 512px Play Store icon from `assets/branding/png/play-store-icon-512.png`.
- [ ] Convert the lockup SVGs' live Alexandria text to outlines before any
      print or store-graphic use (see the design handoff README).
- [ ] Configure a release signing key; the release build currently signs with
      the debug key (`android/app/build.gradle.kts`).
- [ ] Finish the Firebase console setup for accounts and feedback, and deploy
      `firestore.rules` — see `docs/firebase.md`.
- [ ] Deploy `share_site/` (`firebase deploy --only hosting`), then enter the
      policy URLs: App Store Connect → App Privacy, and Play Console → App
      content → Privacy policy.
      - Privacy: https://mishkatalwird.com/privacy (English: `/en/privacy`)
      - Terms: https://mishkatalwird.com/terms (English: `/en/terms`)
- [ ] Have the terms (`docs/terms.md`) read by someone qualified before release.
- [ ] Verify reminder delivery on physical hardware — see the README.
