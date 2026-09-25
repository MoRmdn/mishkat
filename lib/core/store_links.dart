import 'package:flutter/foundation.dart';

/// The app's store listings, for «قيّم التطبيق».
///
/// The App Store ID exists only once the listing is created in App Store
/// Connect; the same ID goes in `share_site/public/t/index.html`. Until then
/// release builds hide the row, and debug and profile builds open a
/// placeholder so the row can be tried.
const kAppStoreId = '';

/// Also the Android application id.
const kPlayPackage = 'com.mormdn.mishkat';

/// Whether the store links are real yet.
const kStoreLinksReady = kAppStoreId != '';

/// Shown in development always; in release only once the links are real.
const kShowRateApp = kStoreLinksReady || !kReleaseMode;

/// The page to rate the app on this platform. iOS opens straight to the
/// review sheet; Play has no such link, so it opens the listing.
Uri rateAppUri(TargetPlatform platform) {
  if (!kStoreLinksReady) return Uri.parse('https://mishkatalwird.com/');
  return switch (platform) {
    TargetPlatform.iOS || TargetPlatform.macOS => Uri.parse(
      'https://apps.apple.com/app/id$kAppStoreId?action=write-review',
    ),
    _ => Uri.parse(
      'https://play.google.com/store/apps/details?id=$kPlayPackage',
    ),
  };
}
