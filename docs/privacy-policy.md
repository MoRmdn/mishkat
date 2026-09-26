# Privacy Policy — مِشْكَاةُ الوِرْدِ / Mishkat Al-Wird

_Last updated: 25 September 2026_

Published at https://mishkatalwird.com/en/privacy (Arabic: `/privacy`) from
`share_site/public/`. Change both together.

Mishkat Al-Wird is an athkar app with timed reminders. It is designed to work entirely
on your device. An account is optional, and nothing in the app requires one.

## By default: nothing leaves your device

- **No account needed.** You can use every part of the app without signing in.
- Your athkar, favourites, streaks and reminder settings are stored on your device
  and are deleted when you uninstall the app.
- **No advertising, and no data sold or shared** with anyone for their own use.

Two things change this, and both happen only if you choose them: signing in, and
sending feedback.

## If you sign in (optional)

You can sign in with Apple or Google so that your progress, favourites and settings
follow you to other devices. The account is kept with Google Firebase
(Authentication and Cloud Firestore), which processes it on our behalf. We store:

- your account identifier, and what Apple or Google share with us when you sign in:
  your name (and first and last name), email address and whether it is verified,
  and from Google your profile picture link, account language and, for a work or
  school account, its domain. Apple lets you hide your email, and we note when you
  did;
- which sign-in methods the account uses, when it was created and when you last
  signed in;
- the app version, phone system and model, and app language you last used it with,
  and when;
- the routines you completed: which routine and on which day;
- your favourites: which athkar, and when you added or removed them;
- your settings: appearance, language, text size, the Quranic-script choice, reminder
  mode and times, and the prayer-time calculation method, Asr madhab, whether device
  location is used, and the city you chose.

We do **not** store your location coordinates, your time zone or your unfinished reading sessions;
those stay on the device. Your synced data is used only to keep your devices in step.

**Signing out** stops syncing and leaves everything on this device.
**Deleting your account** (Settings → Account → Delete account) permanently removes
the account, everything synced to it and your feedback messages. What is saved on the
device stays there.

## Feedback (optional)

You can send a suggestion, a bug report or a report of a mistake in a thikr. We store:

- what you write, and the replies we send;
- an email address, only if you give one;
- if you leave "Attach device information" on: the app version, your system version
  and device model, and the app language;
- for a thikr report, which thikr it was and which edition of the text you were reading.

If you are not signed in, sending feedback creates an anonymous identifier so our reply
can reach you in the app. Feedback is read only by the developer, is never used for
marketing, and is deleted with your account or on request by email. Replies appear in
the app only; we never send push notifications.

To protect this service from abuse, Firebase App Check confirms that requests come from
the genuine app, using Google Play Integrity or Apple App Attest.

## Saved reading

Unfinished reading sessions are also saved on your device: the selected texts,
their repetition counts, and your current position. This allows interrupted
reading to resume without a network connection. They are never synced. Completing a
session removes its saved checkpoint; starting again replaces it.

## Location

If you turn on prayer-time reminders, the app may ask for your approximate
location.

- It is used **only** on your device, to calculate prayer times.
- It is **never transmitted anywhere**, even when you are signed in. The calculation
  is astronomical and runs offline.
- Only coarse accuracy is requested — enough for a city, not for a street.
- You can refuse. The app then lets you pick a city from a list, or falls back
  to fixed clock times. Nothing stops working.

## Notifications

Reminders are scheduled by your device's own operating system. They are local
notifications: nothing is sent through a push service, and the app does not
need an internet connection for a reminder to arrive.

To deliver them the app may ask for permission to post notifications, to
schedule exact alarms, and to be exempt from battery optimisation. Each is
optional; refusing any of them degrades reminder timing but does not disable
the app.

## Shared links

When you share a thikr, the app adds a link such as
`https://mishkatalwird.com/t/mo1`, naming only which thikr it is. If the
recipient has the app, their phone opens the thikr in it directly; if not, the
website sends them to the App Store or Google Play.

The website is static. It sets no cookies and runs no analytics or tracking. It
is hosted on Firebase Hosting (Google), which, like any web host, keeps standard
request logs (IP address, browser type, the page requested) to operate and
secure the service. We do not use those logs to identify anyone.

## Diagnostics

If crash reporting and analytics are enabled in a published build, the app
collects a deliberately narrow set of events:

- that a reminder schedule was written to the operating system, with how many
  are pending and whether exact alarms were permitted;
- that a reminder was opened;
- that a reading session was completed, and which category;
- whether a permission was granted or refused;
- crash reports.

These exist to answer one question: **do reminders actually arrive on real
devices?** Some manufacturers stop background apps aggressively and silently
cancel scheduled alarms, and comparing reminders scheduled against reminders
opened is the only way to detect it.

Diagnostics do **not** include individual athkar you read, when you pray, your
location, what you write in feedback, or any identifier that could single you out.

## Children

The app needs no personal data to work and is suitable for all ages. Signing in and
sending feedback are optional.

## Changes

If this policy changes, the new version is published with a new date.

## Contact

Questions about this policy: morm9n@gmail.com
