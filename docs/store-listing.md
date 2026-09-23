# Store listing

Draft copy for the App Store and Google Play. Arabic is the primary language.

## Name

- Arabic: **مشكاة**
- English: **Mishkat — Athkar**

## Subtitle / short description

- Arabic: أذكار الصباح والمساء بتذكيرات تصل في وقتها
- English: Morning and evening athkar, with reminders that actually arrive

## Description (English)

Mishkat is an athkar app built around one thing: reminders that arrive when
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
- Three colour themes, each in light and dark
- Full Arabic and English, with Arabic-Indic numerals throughout
- Completely offline. No account, no tracking, no ads

## Description (Arabic)

مشكاة تطبيق أذكار همّه الأول أن يصل التذكير في وقته.

التذكيرات تُجدول على جهازك مباشرة، فتعمل دون إنترنت ودون حساب. اختر أوقاتاً
ثابتة، أو اربطها بمواقيت الصلاة — قبل الفجر لأذكار الاستيقاظ، وبعده لأذكار
الصباح، وبعد العصر لأذكار المساء.

- أذكار الصباح والمساء والنوم والاستيقاظ وبعد الصلاة والمتفرقة
- عدّاد باللمس في أي مكان من الشاشة
- سبحة حرة
- تتابع يومي وتقدّم أسبوعي
- حفظ أي ذكر ومشاركته كصورة مع تخريجه
- ثلاثة ألوان للتطبيق، لكل منها وضع فاتح وغامق
- عربي وإنجليزي بالكامل
- يعمل دون إنترنت. بلا حساب، بلا تتبّع، بلا إعلانات

## Permissions to declare

| Permission | Why | Optional |
|---|---|---|
| Notifications | Delivering the reminders | Yes — app works, reminders do not |
| Exact alarms (Android 12+) | Reminders arriving at the stated minute | Yes — falls back to inexact |
| Battery optimisation exemption | Some vendors cancel scheduled alarms | Yes |
| Approximate location | Prayer-time calculation, on-device only | Yes — city list is offered instead |

Google Play requires a Data Safety declaration. The honest answer is: **no data
collected or shared** unless analytics is enabled in the shipped build, in which
case declare app interactions and crash logs, not linked to identity.

## Before first submission

- [ ] Replace `assets/data/athkar.json` with a human-verified corpus — see the
      warning in that file and in the README.
- [ ] Replace `assets/branding/app-icon.png` with the designer's 1024px export.
- [ ] Configure a release signing key; the release build currently signs with
      the debug key (`android/app/build.gradle.kts`).
- [ ] Set up Firebase if diagnostics are wanted — see `docs/firebase.md`.
- [ ] Add `ar.lproj/InfoPlist.strings` in Xcode for the Arabic home-screen name.
- [ ] Verify reminder delivery on physical hardware — see the README.
