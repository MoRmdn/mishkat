import 'package:flutter/foundation.dart';

/// The app's store listings, for «قيّم التطبيق» and updates.
///
/// The App Store ID is the listing's Apple ID in App Store Connect; the same
/// ID is on the share site (`share_site/public`).
const kAppStoreId = '6815677954';

/// Also the Android application id.
const kPlayPackage = 'com.mormdn.mishkat';

/// The page to rate the app on this platform. iOS opens straight to the
/// review sheet; Play has no such link, so it opens the listing.
Uri rateAppUri(TargetPlatform platform) => switch (platform) {
  TargetPlatform.iOS || TargetPlatform.macOS => Uri.parse(
    'https://apps.apple.com/app/id$kAppStoreId?action=write-review',
  ),
  _ => Uri.parse('https://play.google.com/store/apps/details?id=$kPlayPackage'),
};

/// The listing an update is installed from.
Uri storePageUri(TargetPlatform platform) => switch (platform) {
  TargetPlatform.iOS || TargetPlatform.macOS => Uri.parse(
    'https://apps.apple.com/app/id$kAppStoreId',
  ),
  _ => Uri.parse('https://play.google.com/store/apps/details?id=$kPlayPackage'),
};
