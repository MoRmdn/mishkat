import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a web page over the app: SFSafariViewController on iOS, a Custom Tab
/// on Android. Offline, the browser shows its own error; nothing in the app
/// depends on the page loading.
typedef ExternalLinkLauncher = Future<void> Function(Uri uri);

final externalLinkLauncherProvider = Provider<ExternalLinkLauncher>(
  (ref) =>
      (uri) => launchUrl(uri, mode: LaunchMode.inAppBrowserView),
);
