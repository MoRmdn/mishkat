/// When to ask for a store review, decided without a device.
///
/// The native sheet is never tied to a button: both stores forbid it, and
/// the OS silently shows nothing once its quota is spent. It is asked for on
/// its own, on the reader's done screen, once a streak shows the app is
/// part of someone's day. `test/review_policy_test.dart` pins the rule.
library;

/// A streak this long is a good moment to ask.
const kReviewMinStreak = 7;

/// How long before asking again. iOS caps the sheet at three a year anyway.
const kReviewInterval = Duration(days: 120);

bool shouldAskForReview({
  required int streak,
  required DateTime? lastAsked,
  required DateTime now,
}) {
  if (streak < kReviewMinStreak) return false;
  return lastAsked == null || now.difference(lastAsked) >= kReviewInterval;
}
