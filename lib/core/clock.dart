import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time, as a provider.
///
/// Everything that reads the wall clock goes through this so it can be pinned
/// in tests — the reminder countdown, the Hijri header, and (from M3) the
/// scheduler, whose correctness is entirely about what time it thinks it is.
typedef Clock = DateTime Function();

final clockProvider = Provider<Clock>((ref) => DateTime.now);
