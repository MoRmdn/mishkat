import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat/services/review/review_policy.dart';

void main() {
  final now = DateTime(2026, 9, 7, 7);

  test('a streak shorter than a week never asks', () {
    expect(shouldAskForReview(streak: 6, lastAsked: null, now: now), isFalse);
  });

  test('a week-long streak asks, the first time', () {
    expect(shouldAskForReview(streak: 7, lastAsked: null, now: now), isTrue);
  });

  test('asks again only after 120 days', () {
    bool askedDaysAgo(int days) => shouldAskForReview(
      streak: 30,
      lastAsked: now.subtract(Duration(days: days)),
      now: now,
    );
    expect(askedDaysAgo(119), isFalse);
    expect(askedDaysAgo(120), isTrue);
  });
}
