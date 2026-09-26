# Resuming interrupted reading

Opening a routine resumes its unfinished checkpoint. Completed routines open
fresh. Checkpoints do not expire at midnight; completion retains the app's
existing rule of crediting the local date when reading finishes. Opening the
app itself still shows Home; selecting the routine resumes reading.

Each full routine and each favourite selection has a separate key. Snapshots
include the ordered texts, meanings, references, repetition targets, remaining
counts, current position, and whether an automatic advance was pending. Content
updates therefore do not replace an active session. “Start again” asks for
confirmation and resets the routine using the current library.

SQLite schema 2 adds a checkpoint table without changing favourites or
completion records. Every reading mutation queues a snapshot write immediately,
in order. A process interruption restores the last committed snapshot. Closing
the reader with either its close button or system Back cancels the timer while
preserving the checkpoint. If the process stops during the delay after a final
count, reopening resumes that advance rather than leaving the reader at zero.

Completion and checkpoint deletion share one database transaction. A favourite
selection still cannot receive credit for completing an entire routine. Failed
writes appear in the reader with a Retry control. Invalid or unsupported
checkpoints are retained until the user explicitly chooses to start again;
they never trigger a database reset.

Validation: 49 focused controller, persistence, progress and reader UI tests
pass. Coverage includes closing/reopening a disk database, schema-1 migration,
favourite isolation, content changes, explicit restart, corrupt snapshots,
final-count interruption, system Back and recreating the app's UI. The UI
resume case also runs at 320×640 with 200% text and bundled fonts.

These tests do not certify physical-device process-kill timing. An action whose
SQLite write has not yet committed may not survive immediate process death.
Existing Home-based UI/golden tests have the previously observed Home header
overflow; the reader tests use a separate navigation host. Golden images were
not regenerated for the added restart control.
