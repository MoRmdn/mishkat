# Mishkat expanded v1 — revised implementation plan

Reviewed: 23 September 2026. Status: planning specification, not implemented.

## 1. Confirmed scope

The user's numbering refers to the simplified explanation, not the original attachment:

| User's item | v1 decision |
| --- | --- |
| 1. Verified content | Include short/complete routines and human approval |
| 2. Smarter reminders | Include five optional post-prayer reminders, snooze and test reminder |
| 3. Progress | Include five separate prayer occurrences and manual completion |
| 4. Audio | **Defer entirely to a later release** |
| 5. Widgets | Include Android and iOS widgets with platform-appropriate interaction |
| 6. Privacy | Include crash reporting and optional usage analytics with accurate disclosure |

Branding, accessibility, migration, signing and release verification support these features. Arabic remains the default; English is supported. Keep `com.mormdn.mishkat` and iOS 15 minimum. No advertisements, mandatory accounts, FCM, cloud sync, Quran reader, Qibla, custom routines or extra languages.

Remove audio packages, playback UI, recording procurement, background audio capabilities and audio approval gates from v1. Stable content IDs allow future audio integration without building unused playback infrastructure now.

## 2. Verified baseline and gaps

Repository inspected at `1726288`; working tree was clean before this planning work. The original claim about uncommitted Firebase/Xcode changes is no longer current. Preserve existing configuration and review it; no new checkpoint branch is needed solely to save already committed work.

Checks run on 23 September:

- `flutter analyze`: passed, no issues.
- `flutter test --reporter compact`: **172 passed, 12 failed**; golden comparison failures were generated for all 12 screen fixtures. Drift multiple-database warnings also occurred.
- Golden failure images are available locally under `test/golden/failures/`. The rendering differences have not been diagnosed or accepted; do not regenerate all goldens merely to make the suite pass.

| Evidence in current code | Gap to close |
| --- | --- |
| `app_database.dart`: schema 1, unique `(day, category)` | Cannot represent five post-prayer completions per day |
| `progress_repository.dart`: after-prayer weekly target already 35 | Current storage permits at most seven such rows per week |
| `recordCompletion`: read, then insert-or-ignore, then return true | Concurrent callers can both report a new completion although only one row is inserted |
| `notification_service.dart`: empty background callback; foreground handler ignores action ID | Snooze is not implemented; Start and Snooze need distinct routing |
| `NotificationService.apply`: `cancelAll()` before scheduling | Rescheduling can delete snoozes and create an empty schedule if interrupted |
| `reminder_sync_scope.dart`: several asynchronous sync triggers | Older work can overwrite newer settings unless synchronization is serialized |
| `DailyPrayerTimes`: Fajr, Asr, Maghrib only | Dhuhr and Isha still need calculation and model support |
| Home edit and completion share handlers are empty | Visible controls currently do nothing |
| `assets/data/athkar.json` explicitly labels itself placeholder | Content approval is a release dependency, not an engineering certification |
| Firebase core/config files exist; `main.dart` does not initialize Firebase; diagnostics is no-op | Configuration is not equivalent to working Crashlytics/Analytics |
| Android release build uses debug signing | Production signing is a release blocker |
| `docs/privacy-policy.md` claims no identifying information and equates opens with delivery | Privacy wording and measurement logic need correction |

The test harness closes databases after `pump`, but some tests create additional/unpumped harnesses. Audit ownership and teardown of every instance rather than suppressing Drift warnings.

## 3. Shared domain contracts — implement before reminders/widgets

### Content and sessions

- `RoutineLength { short, complete }`; `ReviewStatus { draft, approved }`.
- Keep stable thikr IDs and explicit aliases/tombstones for replacements. Text edits must not silently reassign IDs or erase favorites.
- Separate the reviewed text from category membership/order/repetition metadata where a text occurs in multiple routines. Validate membership and repetitions as part of content review.
- `RoutineSession` freezes instance ID, content version, selected length, ordered item IDs and remaining repetitions when opened. Persist it for process-death recovery. Changing Settings affects the next session, not the one currently being counted.
- Short/complete never contributes to completion uniqueness: finishing both versions cannot create two daily credits. Store length and content version as historical metadata.

### Routine identity and completion

Use a shared `RoutineInstance`/`RoutineTarget` across reader, notification and widget:

```text
schemaVersion, category, serviceDate, occurrence,
timeZoneId, scheduledAtUtc?, eligibleFromUtc?, expiresAtUtc?

occurrence = daily | fajr | dhuhr | asr | maghrib | isha
completion unique key = serviceDate + category + occurrence
origin = reader | outsideApp | widget
```

`serviceDate` is the nominal local date of the routine/prayer in the scheduling context. It is not recalculated from the time a notification is tapped. Preserve it when a delay crosses midnight; store actual completion time separately in UTC. Existing recorded day keys remain unchanged after travel. Timezone and location changes affect future targets, not historical identity; crossing back into the same date must not create another credit for the same category/prayer.

Default product rules:

- Normal routines count once per local date. Tasbih remains a free counter and contributes no completed routine; misc retains its existing once-daily behavior.
- After-prayer entry opened from Home asks which prayer is being recorded. Notification/widget entry carries the prayer explicitly. Never infer it solely from the current clock.
- Reminder switches control notifications, not whether prayer completion can be recorded. Targets remain five per day even when some reminders are off; describe this clearly in progress UI.
- In-app manual completion asks for confirmation and offers correction/undo for a mistaken record. Offline/fixed-mode users can explicitly select a prayer without location access; these are user declarations, not inferred prayer times.
- A widget completion is eligible from its displayed reminder time until the next occurrence of the same routine/prayer. Stale actions must refresh/open confirmation, never silently credit today's different instance. This is an interaction policy, not a religious ruling about valid remembrance times.
- Only a session launched for a specific instance can credit it. A completed/stale deep link may open reading again, but cannot manufacture another completion.

### Storage and command handling

- Migrate schema 1 transactionally: ordinary rows become `daily`; old after-prayer rows become `unspecified` historical records, excluded from five-prayer daily/weekly totals. Preserve them in lifetime history and historical streaks with a clear legacy label.
- Use database-enforced uniqueness and an atomic insert outcome, not check-then-write. Return `created`, `alreadyCompleted`, `invalidTarget` or `failed` accurately under concurrent calls.
- Record an idempotent command ID for widget actions. Replaying an old command after undo must not recreate the completion; a new deliberate action gets a new command ID.
- A single application completion service validates targets, writes transactionally, invalidates progress, cancels matching pending one-offs/snoozes, and refreshes widget snapshots. Do not cancel a repeating daily reminder permanently after today's completion.
- SQLite transactions/uniqueness are the cross-isolate authority. Handle busy/retry/close correctly; do not assume a Dart singleton protects independent background engines. Follow the existing future-based repository/invalidation approach.
- Test migrations with real schema-1 fixtures and favorites. On migration failure retain the old data and report the problem; never reset the database automatically.

Acceptance: completing Fajr twice and Dhuhr once produces 2/5; repeating any command does not change it. Five distinct prayers on seven days produce 35/35. A concurrent reader/widget completion produces one row and one successful first-completion result.

## 4. Verified short/complete content

1. Build a draft from cited primary collections. Hisn al-Muslim may index candidate material; do not assume translations or recordings are licensed for redistribution.
2. Model references as structured references, not only an integer hadith number: support collection/edition/book/number variants and Quran surah/ayah ranges when relevant. Store grading and its attribution when applicable; do not invent hadith grading for Quran text.
3. Review Arabic text, repetitions, category, claimed virtues, English meaning, reference and short-routine membership. Tie approval to a content revision/hash; a substantive edit invalidates its previous approval.
4. Maintain a corpus manifest with schema/content version, reviewer, approval date, license/provenance and reviewed artifact hash.
5. Build the shipping corpus only from approved records. Drafts may remain in authoring material but must not enter release assets, search/favorites lookup, notification previews or share cards. A release validator checks the actual shipped corpus and all its references/translations, not unrelated drafts.
6. Every supported category must have a usable approved routine; `short` is an approved subset of `complete`, with no empty selectable routine. Label short as a convenience selection, not a claim that omitted adhkar are unnecessary.
7. Default new/skipped onboarding to short; for existing installations with no saved choice, preserve the previous complete experience and show a one-time explanation. Persist selection in Settings.
8. Reader, Home counts, share selection and notification text all resolve through one routine selector. Show source/review details in the reader. Favorites remain accessible regardless of chosen length, but withdrawn/unapproved material is not displayed as approved.
9. Replace the constant 2.5-seconds-per-repetition estimate with a conservative text-length-and-count estimate, labeled approximate and checked against real reading samples; do not imply a measured duration.

Acceptance: edited unreviewed text blocks the release validator; switching length updates all future surfaces consistently; existing favorites and active sessions survive a corpus upgrade according to the alias policy.

## 5. Reminders and reliable scheduling

### Settings and prayer calculation

- Keep the existing four slots: wake, morning, evening, sleep. Retain existing prayer anchors unless separately changed.
- Add five post-prayer slots, master off by default, individual switches prepared as on. Shared delay defaults to 5 minutes; choices are 0/5/10/15/20/30.
- Explain that this delay is measured from the calculated prayer start, not actual congregational completion; the app cannot know when the user finished praying.
- Post-prayer notifications operate only in prayer mode. Fixed mode suspends them and retains their configuration. Reading/manual prayer completion still works.
- Expand the prayer result to all five prayers and persist calculation method, Asr convention and location source. Give manual cities an IANA timezone. Resolve dates using the chosen location's timezone, then convert instants for device display.
- Device-location mode uses the device zone and last explicitly obtained coarse position; refresh while the app is active when needed. A timezone change alone does not update coordinates. Surface stale location after travel; do not promise automatic geolocation while terminated.
- With no valid prayer location/calculation, retain fixed-time fallback for ordinary reminders and suspend post-prayer reminders with an explanation. Never fabricate prayer times or silently select Makkah for another location.
- Define and test the calculation library's high-latitude handling and unavailable-time behavior. Review representative fixtures for Cairo, Makkah, London and New York, DST transitions, month boundaries and the selected method's Ramadan Isha behavior. Separate calculation adjustments, if needed, from the after-prayer reminder delay.

### Capacity and horizon

The notification plugin documents an iOS pending limit of 64. Use a stricter **60-total** application budget, including temporary notifications, not 60 plus snoozes. [Notification plugin documentation](https://pub.dev/packages/flutter_local_notifications)

Proposed allocation:

```text
routine requests: up to 57
simultaneous snoozes: up to 2
test reminder: up to 1
total: at most 60, including during schedule replacement
```

At maximum load: eight prayer-anchored slots × seven days + one repeating sleep request = 57. The other three positions are explicitly reserved. Repeated snoozes for the same instance replace its existing snooze; at two occupied snooze slots, reject a third with clear feedback rather than silently evicting another reminder. Repeated tests replace the one test request.

Compute actual instances chronologically, up to 14 days and the routine budget. Include only complete future day groups where possible; account explicitly for today's remaining slots, dates with unavailable calculations, and offsets crossing midnight. Report `lastScheduledAt` and `fullyCoveredThroughDate` separately so a partially covered day is not described as fully covered.

Fixed repeating reminders retain their compact representation. A successful schedule means requests were accepted by the OS, not that they will necessarily be presented to the user.

### Applying schedules

- Keep the planner pure and inject the clock. Use stable persistent IDs based on target identity, with separate namespaces for routine/snooze/test requests; do not key by moving window offset or unstable language hash values.
- Serialize and coalesce reschedules with a revision. Never let a slower old operation overwrite the current desired state.
- Persist a local request ledger and reconcile desired IDs against OS pending IDs. Read-back pending APIs may not include trigger dates, so join IDs to the ledger before reporting coverage.
- Replace only changed requests; cancel disabled/stale targets. Preserve unrelated valid snoozes and the test slot. Operations are not OS-atomic: maintain the total cap during intermediate steps, persist partial failures and retry on the next execution opportunity.
- Read back pending requests after applying. Surface partial coverage and permission problems instead of declaring full success from the planner output.
- Refresh at launch/resume, relevant settings/locale/length/location changes and successful notification/widget interactions. Android reboot restoration must be tested separately from generating new prayer-day instances.
- Android exact-alarm access can be absent or revoked; check it, rebuild at the next permitted opportunity, and fall back to inexact timing with truthful copy. Inexact delivery may be delayed substantially, not merely a couple of minutes. Keep `SCHEDULE_EXACT_ALARM`, not `USE_EXACT_ALARM`. [Android alarm guidance](https://developer.android.com/develop/background-work/services/alarms)

### Start, snooze and expiry

- Register iOS notification categories/actions and both platforms' background plugin entry points. Dispatch on action ID; Snooze schedules a one-off at action time +15 minutes without opening the reader. Start opens the exact instance after app state is ready.
- Validate versioned payloads; recognize legacy slot-only payloads for safe navigation without inventing a prayer occurrence. Malformed/unsupported payloads open a safe destination and never write progress.
- Snooze is canceled on completion or disabling its reminder. Preserve original service date; reject expired or already-completed targets.
- Test action schedules a real local reminder for approximately 10 seconds later. Explain permission/timing limitations; it creates no progress entry and cannot consume routine capacity.
- Show coverage before expiry and an explicit expired state in the app/widget. Refill on execution opportunities. Optional background refresh improves coverage but cannot be the correctness guarantee: iOS chooses when background work runs. [Apple background execution guidance](https://developer.apple.com/documentation/backgroundtasks/choosing-background-strategies-for-your-app)
- **Accepted v1 limitation:** changing prayer reminders have finite coverage if the app receives no execution opportunity. Do not claim indefinite reminders without opening the app, or automatic timezone/location recovery while terminated. If indefinite coverage becomes a requirement, revisit architecture/product scope before implementation.

Acceptance: test all 512 enable/disable combinations of nine slots, both modes, delay choices and temporary requests; total never exceeds 60. Inject interruption mid-apply, overlapping reschedules, revoked permissions and missing calculation days. Preserve valid snoozes and report actual coverage.

## 6. Widgets

Use `home_widget` with native SwiftUI/WidgetKit and Android Glance. It bridges data/actions; it does not eliminate native UI implementation. Verify a compatible version against the project's current Swift Package Manager setup, iOS 15 floor and Android toolchain before pinning it. [Package documentation](https://pub.dev/packages/home_widget)

### Feasibility gate before full widget UI

Prove on a signed release-mode device build that an iOS 17+ widget action can start the documented background worker with the app not running, reach the existing app database through the application completion service, and refresh the snapshot. The plugin documents additional setup for this cold-start path. Avoid normal startup scheduling/navigation side effects in headless execution. [Interactive widget setup](https://docs.page/abausg/home_widget/features/interactive-widgets)

The chosen design keeps the authoritative database in the application and publishes a read-only widget snapshot to shared storage. Do not casually move the entire database into App Group storage or maintain an unrelated native progress database. If the cold-start approach fails the device gate, resolve the native command/storage bridge explicitly before treating interactive completion as done.

### Contract and behavior

- App Group: `group.com.mormdn.mishkat`; extension: `com.mormdn.mishkat.MishkatWidget`. Configure entitlements/signing for both targets.
- Snapshot: schema/revision, locale/theme, generated time, valid-through time, current/next target, completion state, timeline entries and safe open link. Publish atomically; unknown schema shows an open-app fallback.
- Do not use notification permission as a prerequisite for widgets. Derive widget candidates from routine timing even if OS notifications are disabled; if timing is unknown, offer open/select rather than a guessed timed completion.
- The widget shows current/next routine, time and completion. Enable completion only after eligibility begins and before expiration; validate again at action time against the current target/revision.
- Android/iOS 17+ use the background completion service. iOS 15–16 open an in-app confirmation. Failed/background-unavailable actions must not show a durable successful state before the write succeeds.
- iOS uses precomputed timelines; Android uses event-driven Glance updates plus a periodic best-effort refresh. Android does not provide a WidgetKit-equivalent exact timeline promise; periodic updates may be every 30 minutes, or scheduled with WorkManager. Show timestamps/expired state and validate all actions. [Android Glance updates](https://developer.android.com/develop/ui/compose/glance/glance-app-widget), [Apple widget updates](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date)
- Refresh after completion/undo, timing/locale/theme/length changes, resume and supported system changes. Multiple widget instances show consistent data.
- External deep links only navigate or request confirmation. Silent completion requires a validated local action token/command; a crafted URI cannot write progress.

Acceptance: cold and warm actions, duplicate taps, two widget instances, simultaneous reader completion, locked device, midnight, stale snapshots, reboot and timezone change. Screen layouts pass Arabic/English, RTL, dark/light and enlarged-text review.

## 7. Diagnostics and privacy

Keep Crashlytics enabled by default as planned; keep Analytics off until explicit opt-in, including skipped onboarding and headless startup. Initialize Firebase only after the relevant native defaults and persisted consent behavior are established. Failure to initialize must not block the offline app.

Corrections to the original plan:

- Say "optional usage analytics" rather than "fully anonymous analytics." Firebase uses installation identifiers; Crashlytics also includes device/crash metadata. Avoid claims such as "no servers," "nothing shared with third parties" or "no identifiers" once enabled. [Firebase privacy documentation](https://firebase.google.com/support/privacy), [Analytics data collection](https://support.google.com/firebase/answer/6318039?hl=en)
- Disable Analytics collection in native configuration before SDK initialization, not only after the first Flutter screen. Persist opt-in/withdrawal, disable event producers immediately on withdrawal, and reset local Analytics state where supported. Explain that withdrawal stops future collection and is not automatic deletion of data already transmitted. [Apple Analytics configuration](https://firebase.google.com/docs/analytics/ios/configure-data-collection), [Android Analytics configuration](https://firebase.google.com/docs/analytics/android/configure-data-collection)
- Minimize the original telemetry scope: keep per-prayer completion, origin, favorites and usage history local. Limit custom telemetry to schedule application/result, pending-count range, permission state and generic reminder action. The source comment claiming scheduled-versus-opened proves delivery is incorrect: a user may receive and ignore a reminder.
- Never send coordinates, city, computed prayer/reminder times, text, target payloads or thikr IDs. SDK event/crash timestamps and automatic metadata still exist and must be disclosed; removing explicit time parameters is not a guarantee that usage time cannot be inferred.
- Disable advertising identifiers/personalization and unnecessary automatic screen reporting where supported. Audit actual SDK-collected events/breadcrumbs instead of promising that an application allowlist controls every SDK field.
- Sanitize exception text and custom logs so an error cannot leak content/location. Capture framework and asynchronous/native failures appropriately, avoiding blanket classification of handled errors as fatal. Verify release symbolication. [Crashlytics Flutter documentation](https://firebase.google.com/docs/crashlytics/flutter/customize-crash-reports)
- Update Arabic/English privacy copy, store disclosures, dependency privacy manifests, contact details, retention and backup behavior based on the shipped SDKs. Device OS backup is not the same as app cloud sync; decide/exclude sensitive local data deliberately rather than asserting uninstall always erases every copy.

Acceptance: fresh install, skip, opt-in, restart, withdrawal and background widget launch all honor Analytics choice. Device-level verification distinguishes Crashlytics traffic from Analytics; absence of a custom event alone is not proof of disabled Analytics. Production crash reports are readable without sensitive fields.

## 8. Delivery order and exit criteria

Implement one reviewable feature branch at a time from the updated base. Suggested names follow the repository's existing feature convention; no branches are created by this plan.

| Phase | Suggested branch | Work and exit criterion |
| --- | --- | --- |
| 0 | `fix/release-foundation` | Diagnose goldens, close all test DBs, pin a reproducible verification environment; correct branding, Home edit, completion sharing and accessibility. Analyze/tests pass without Drift warnings. Review existing Firebase/toolchain configuration. |
| 1 | `feat/verified-routines` | Content schema, approval manifest/validator, selector and resumable sessions. Reviewer work starts here and continues while engineering proceeds. |
| 2 | `feat/routine-instances` | Schema migration, atomic completion commands, five-prayer counts, manual confirmation/correction, date rules and target codec. Migration/concurrency fixtures pass. |
| 3 | `feat/post-prayer-reminders` | Five-prayer calculation, bounded scheduler/ledger, serialized reconciliation, working Start/Snooze/test actions, permission and horizon UI. Fault-injection and physical reminder checks pass. |
| 4 | `feat/home-widgets` | Perform cold-start feasibility gate first; then native layouts, snapshots, timelines/updates, signed entitlement verification and interactive commands. Platform matrix passes. |
| 5 | `feat/diagnostics-consent` | Crash adapter, native Analytics defaults, optional consent, privacy copy and symbolication. Consent/traffic checks pass. |
| 6 | `chore/release-qa` | Approved corpus, signed release builds, device soak testing, correct store declarations and launch checklist. No audio deliverables block release. |

Snooze is intentionally completed with the new target codec/scheduler, not implemented twice against an obsolete slot-only payload. Widget feasibility can be prototyped after phase 2; final integration depends on phase 3. Freeze telemetry contracts early, even though SDK integration is later.

## 9. Verification and release gates

### Automated

- Approved shipping corpus, stable IDs/aliases, nonempty short subsets, session persistence and revision-bound approvals.
- Migration fixtures, duplicate/racing commands, undo/replay, legacy unspecified history and seven-day statistics.
- All reminder combinations, capacity during reconciliation, snooze/test replacement, partial failures and stale async revisions.
- Prayer fixtures, DST gaps/folds, location/timezone separation, midnight-crossing delays, missing days and travel.
- Cold-start target routing, invalid/legacy payloads, stale/forged widget actions and multiple widget snapshots.
- Consent before initialization, withdrawal/restart/headless cases, error redaction and no completion telemetry.
- Arabic/English semantics, plurals, large text and intentionally reviewed screen goldens; `flutter analyze` and full tests pass.

### Physical release-mode devices

- iPhone iOS 15/16 fallback, iOS 17+ interactivity and a current supported iOS release; Pixel, Samsung and Xiaomi across supported Android permission behaviors.
- Separate ordinary backgrounding, OS process termination, user force-stop/force-quit, reboot and app upgrade. Record platform restrictions rather than treating these states as equivalent.
- Locked-device Start/Snooze; notifications denied; exact access revoked; Doze/24-hour idle; battery saver; Focus/DND and system notification settings.
- A full scheduling horizon without opening the app, then refill after resume, plus observed behavior when background refresh never executes. Test expiration explicitly, not only seven days of daily app launches.
- Widget actions and refresh after midnight, completion, undo and travel; airplane mode; screen readers; signing/entitlements and readable crash reports.

### Corrected launch process

The attachment's universal "seven days, then 10% / 50% / 100%" release process is not valid for a first public release.

- Use at least a full seven-day device soak covering the busiest schedule; cover longer 14-day configurations with additional horizon testing. This engineering target does not replace store eligibility rules.
- If the Google Play account is a personal account created after 13 November 2023, the documented requirement is at least 12 testers continuously opted in to closed testing for 14 days, followed by a production-access application. Confirm account applicability before committing a launch date. [Google Play testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
- Google Play rollout percentages are unavailable for a first release. Start with internal/closed testing, then a deliberate initial production launch to selected regions; staged percentages can be used for eligible updates. [Google Play release process](https://support.google.com/googleplay/android-developer/answer/9859348?hl=en)
- Apple phased release applies to updates, not the first version. Eligible updates follow Apple's seven-day 1%, 2%, 5%, 10%, 20%, 50%, 100% sequence. TestFlight precedes the initial launch. [Apple phased release availability](https://developer.apple.com/documentation/appstoreconnectapi/app-store-version-phased-releases), [Apple phased update schedule](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases)
- Block launch for unapproved content, migration data loss, reproducible duplicate/incorrect completion, confirmed app-caused missed reminders within supported coverage, broken consent, unsigned builds or unresolved critical crashes. An unopened reminder is not evidence of delivery failure.
- Prepare a forward-fix build procedure; stopping distribution does not repair installations already upgraded or reverse their database migrations.

External release dependencies: qualified content reviewer and signed-off corpus/license provenance; Apple/Google account access, distribution signing/App Group capabilities; real test devices and applicable testers. Audio commissioning is explicitly not a v1 dependency.

## 10. Deferred audio milestone

After v1, plan human-recorded, licensed, reviewed offline files mapped to stable IDs; short/complete playback queues; background/lock-screen controls; interruptions; and a rule that playback never changes repetition counts or completion. Approve its technical design and audio release gates in that later milestone.
