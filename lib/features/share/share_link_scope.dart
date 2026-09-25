import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/share_link.dart';
import '../../data/repositories/athkar_repository.dart';
import '../../services/diagnostics.dart';
import '../reader/reader_screen.dart';

/// Links the OS hands the app: Universal Links on iOS, App Links on Android.
///
/// `app_links` replays the link that launched the app to the first listener,
/// so one stream covers both a cold start and a link tapped while running.
final incomingLinksProvider = Provider<Stream<Uri>>(
  (ref) => AppLinks().uriLinkStream,
);

/// Opens the thikr a tapped share link names.
///
/// Mounted beside `ReminderSyncScope`, after onboarding: a link never skips the
/// permission ladder, and one that launched the app mid-onboarding opens once
/// it is done. An id the bundled library does not know — a link from a newer
/// or older build — leaves the user where they are rather than on an empty
/// reader.
class ShareLinkScope extends ConsumerStatefulWidget {
  const ShareLinkScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ShareLinkScope> createState() => _ShareLinkScopeState();
}

class _ShareLinkScopeState extends ConsumerState<ShareLinkScope> {
  StreamSubscription<Uri>? _links;

  @override
  void initState() {
    super.initState();
    // After the first frame, so the reader has a navigator to push onto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _links = ref
          .read(incomingLinksProvider)
          .listen(
            _open,
            onError: (Object error, StackTrace stack) =>
                ref.read(diagnosticsProvider).recordError(error, stack),
          );
    });
  }

  @override
  void dispose() {
    _links?.cancel();
    super.dispose();
  }

  Future<void> _open(Uri uri) async {
    final id = thikrIdFromLink(uri);
    if (id == null) return;
    // A cold start can deliver the link before the corpus has loaded.
    final library = await ref.read(athkarLibraryProvider.future);
    final thikr = library.byId(id);
    if (thikr == null || !mounted) return;
    await openReader(context, ref, thikr.category, [thikr], subset: true);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
