# Privacy Policy — مِشْكَاةُ الوِرْدِ / Mishkat Al-Wird

_Last updated: 25 September 2026_

Published at https://mishkatalwird.com/en/privacy (Arabic: `/privacy`) from
`share_site/public/`. Change both together.

Mishkat Al-Wird is an athkar app with timed reminders. It is designed to work entirely
on your device.

## What the app does not do

- **No account.** There is no sign-up, no sign-in, and no user profile.
- **No servers.** The app has no backend. Your athkar, favourites, streaks and
  reminder settings are stored only on your device and are deleted when you
  uninstall the app.
- **No advertising, and no data sold or shared with third parties.**

## Saved reading

Unfinished reading sessions are also saved on your device: the selected texts,
their repetition counts, and your current position. This allows interrupted
reading to resume without an account or network connection. Completing a
session removes its saved checkpoint; starting again replaces it.

## Location

If you turn on prayer-time reminders, the app may ask for your approximate
location.

- It is used **only** on your device, to calculate prayer times.
- It is **never transmitted anywhere.** The calculation is astronomical and runs
  offline.
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
location, or any identifier that could single you out.

## Children

The app collects no personal data and is suitable for all ages.

## Changes

If this policy changes, the new version is published with a new date.

## Contact

Questions about this policy: morm9n@gmail.com
