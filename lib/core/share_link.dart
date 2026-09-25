import '../data/models/thikr.dart';

/// The domain that shared thikr links live on.
///
/// Every link ever shared names this host, so it can never change without
/// breaking them. It must match `applinks:` in `ios/Runner/Runner.entitlements`,
/// the App Links intent filter in `AndroidManifest.xml`, and the Firebase
/// Hosting site that serves `share_site/public`.
const kShareLinkHost = 'mishkatalwird.com';

const _thikrPath = 't';

/// `https://mishkatalwird.com/t/mo1` — opens [thikr] in the app when it is
/// installed, and the store when it is not.
///
/// A thikr id, once shared, is public: renaming one in `athkar.json` strands
/// every link that named it.
Uri thikrLink(Thikr thikr) => Uri(
  scheme: 'https',
  host: kShareLinkHost,
  pathSegments: [_thikrPath, thikr.id],
);

/// The thikr id a share link names, or null for anything that is not one.
///
/// A trailing slash is tolerated; any other path, host or scheme is not.
String? thikrIdFromLink(Uri uri) {
  if (uri.scheme != 'https' || uri.host.toLowerCase() != kShareLinkHost) {
    return null;
  }
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  if (segments.length != 2 || segments.first != _thikrPath) return null;
  return segments.last;
}

/// The policy pages on the share site, linked from Settings.
enum LegalPage {
  privacy('privacy'),
  terms('terms');

  const LegalPage(this.path);
  final String path;
}

/// `https://mishkatalwird.com/privacy`, or `/en/privacy` for English.
///
/// Served from `share_site/public/`; the stores link to the same URLs.
Uri legalPage(LegalPage page, String languageCode) => Uri(
  scheme: 'https',
  host: kShareLinkHost,
  pathSegments: [if (languageCode != 'ar') 'en', page.path],
);
