import '../../core/format/numerals.dart';

/// A release number, `major.minor.patch`, compared numerically.
///
/// Read from the store build (`1.3.0+34`), the About line (`1.2.0 (34)`) and
/// Remote Config (`1.3.0`): the build number and anything after the three
/// parts is ignored, since the gate is about releases, not builds.
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  static final _pattern = RegExp(r'^\s*v?(\d+)\.(\d+)(?:\.(\d+))?');

  /// Null for anything that is not a version, so a mistyped Remote Config
  /// value switches the gate off instead of crashing or blocking.
  static AppVersion? tryParse(String? raw) {
    if (raw == null) return null;
    final m = _pattern.firstMatch(raw);
    if (m == null) return null;
    return AppVersion(
      int.parse(m[1]!),
      int.parse(m[2]!),
      int.parse(m[3] ?? '0'),
    );
  }

  static AppVersion parse(String raw) =>
      tryParse(raw) ?? (throw FormatException('Not a version', raw));

  /// `0.0.0` is Remote Config's "not set".
  bool get isZero => major == 0 && minor == 0 && patch == 0;

  @override
  int compareTo(AppVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    return patch.compareTo(other.patch);
  }

  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion &&
      other.major == major &&
      other.minor == minor &&
      other.patch == patch;

  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';

  /// `١٫٣٫٠` in Arabic, as on the board; `1.3.0` in English.
  String display(String languageCode) =>
      languageCode == 'ar' ? toArabicIndic('$major٫$minor٫$patch') : toString();
}
