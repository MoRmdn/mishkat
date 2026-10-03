import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

/// Shows the platform's own rating sheet (App Store / Play in-app review).
///
/// The OS decides whether it actually appears and never says, so there is no
/// result and no fallback: opening a store page the user did not ask for is
/// worse than showing nothing. «قيّم التطبيق» in Settings opens the store
/// itself (`rateAppUri`).
abstract class AppReviewer {
  Future<void> requestReview();
}

class InAppReviewer implements AppReviewer {
  @override
  Future<void> requestReview() async {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) await review.requestReview();
    } catch (e) {
      debugPrint('review request failed: $e');
    }
  }
}

final appReviewerProvider = Provider<AppReviewer>((ref) => InAppReviewer());
