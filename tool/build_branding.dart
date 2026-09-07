// Builds every branding asset from the design project's own mark files.
//
//   dart run tool/build_branding.dart
//
// Why this exists: the design project's composed app-icon exports
// (mishkat-icon-teal-1024.png and -512) exceed the 256 KiB per-file limit of
// the tooling used to read that project, and come back with a truncated zlib
// stream. The *transparent marks* do fit, so the icon is recomposed here from
// the designer's actual 1024px geometry rather than redrawn.
//
// Nothing here is drawn by hand. Shapes come from the mark PNGs; the colours
// and proportions were measured from the authentic 192px icon, which does fit.
//
// If you export the real `icon-teal-1024.png` from Claude Design and drop it
// into assets/branding/, it is used verbatim and the reconstruction is skipped.

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

const String kBranding = 'assets/branding';
const String kAndroidRes = 'android/app/src/main/res';

/// Sampled from `icon-teal-192.png`, not chosen.
const int kBgTopLeft = 0xFF1B6A57;
const int kBgBottomRight = 0xFF0E2C25;

/// Solved from the sampled composite: white over the gradient at these alphas
/// reproduces the niche (#37685C) and base bar (#99ACA7) exactly.
const double kNicheAlpha = 0.12;
const double kBaseAlpha = 0.57;

/// The flame in the icon is the dark-build gold token, a shade lighter than
/// the flame in the standalone mark.
const int kFlame = 0xFFDBBC74;
const int kFlameCore = 0xFFF1E0B7;

/// Region colours as they appear in the source marks.
const int kMarkNiche = 0xFF123A31; // mark-color: niche and base
const int kMarkFlame = 0xFFCBA75C; // mark-color: flame
const int kMarkCore = 0xFFE8D3A7; // mark-color: flame core

/// Mark placement inside the icon canvas, measured from the 192px reference.
const double kMarkTop = 0.266;
const double kMarkHeight = 0.474;

/// The base bar is the bottom slice of the mark, and is lighter than the niche.
const double kBaseBandStart = 0.912;

void main() async {
  final color = _read('$kBranding/mark-color-1024.png');
  final white = _read('$kBranding/mark-white-1024.png');

  final supplied = File('$kBranding/icon-teal-1024.png');
  if (supplied.existsSync()) {
    stdout.writeln('Using the supplied icon-teal-1024.png verbatim.');
    File(
      '$kBranding/app-icon.png',
    ).writeAsBytesSync(supplied.readAsBytesSync());
  } else {
    final icon = _composeIcon(color, white);
    File('$kBranding/app-icon.png').writeAsBytesSync(encodePng(icon));
    stdout.writeln('Composed app-icon.png (1024, opaque).');
  }

  // Splash and Android adaptive foreground: the mark on transparency, so the
  // platform draws the brand colour behind it.
  final markOnly = _tintedMark(color, white, forDarkGround: true);
  File('$kBranding/splash-mark.png').writeAsBytesSync(encodePng(markOnly));
  File(
    '$kBranding/adaptive-foreground.png',
  ).writeAsBytesSync(encodePng(_adaptiveForeground(markOnly)));
  stdout.writeln('Wrote splash-mark.png and adaptive-foreground.png.');

  _writeNotificationIcons(color, white);
  stdout.writeln('Wrote notification icons at five densities.');
}

Image _read(String path) {
  final image = decodePng(File(path).readAsBytesSync());
  if (image == null) throw StateError('could not decode $path');
  return image.convert(numChannels: 4);
}

bool _near(Pixel p, int argb, {int tolerance = 26}) {
  final r = (argb >> 16) & 0xFF, g = (argb >> 8) & 0xFF, b = argb & 0xFF;
  return (p.r - r).abs() <= tolerance &&
      (p.g - g).abs() <= tolerance &&
      (p.b - b).abs() <= tolerance;
}

/// The four regions of the mark, keyed by comparing the two source files:
/// the niche and base are white in mark-white but teal in mark-color, while
/// the flame is gold in both.
({bool niche, bool flame, bool core}) _classify(Pixel c, Pixel w) {
  if (c.a < 128) return (niche: false, flame: false, core: false);
  if (_near(c, kMarkCore, tolerance: 18)) {
    return (niche: false, flame: false, core: true);
  }
  if (_near(c, kMarkFlame, tolerance: 30)) {
    return (niche: false, flame: true, core: false);
  }
  // Anything else solid is the niche/base body — confirmed white in mark-white.
  final bodyIsWhite = w.a > 128 && w.r > 200 && w.g > 200 && w.b > 200;
  return (
    niche: bodyIsWhite || _near(c, kMarkNiche),
    flame: false,
    core: false,
  );
}

int _blend(int base, int overlay, double alpha) {
  int ch(int shift) {
    final b = (base >> shift) & 0xFF;
    final o = (overlay >> shift) & 0xFF;
    return (b + (o - b) * alpha).round().clamp(0, 255);
  }

  return 0xFF000000 | (ch(16) << 16) | (ch(8) << 8) | ch(0);
}

/// Full-bleed square icon: gradient ground, translucent niche, opaque flame.
///
/// No alpha anywhere — App Store submission rejects an icon with transparency —
/// and no rounded corners, because both platforms mask them themselves.
Image _composeIcon(Image color, Image white) {
  const size = 1024;
  final out = Image(width: size, height: size, numChannels: 4);

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      // Diagonal gradient, matching the reference's top-left to bottom-right.
      final t = ((x + y) / (2 * (size - 1))).clamp(0.0, 1.0);
      final argb = _blend(kBgTopLeft, kBgBottomRight, t);
      out.setPixelRgba(
        x,
        y,
        (argb >> 16) & 0xFF,
        (argb >> 8) & 0xFF,
        argb & 0xFF,
        255,
      );
    }
  }

  final box = _markBounds(color);
  final targetHeight = (size * kMarkHeight).round();
  final scale = targetHeight / box.height;
  final targetWidth = (box.width * scale).round();
  final originX = ((size - targetWidth) / 2).round();
  final originY = (size * kMarkTop).round();

  for (var y = 0; y < targetHeight; y++) {
    final sourceY = box.top + (y / scale).floor();
    if (sourceY >= color.height) continue;
    // Below this line the mark is the base bar, which is lighter.
    final isBase = y / targetHeight >= kBaseBandStart;

    for (var x = 0; x < targetWidth; x++) {
      final sourceX = box.left + (x / scale).floor();
      if (sourceX >= color.width) continue;

      final c = color.getPixel(sourceX, sourceY);
      final w = white.getPixel(sourceX, sourceY);
      final region = _classify(c, w);
      if (!region.niche && !region.flame && !region.core) continue;

      final px = originX + x, py = originY + y;
      if (px < 0 || py < 0 || px >= size || py >= size) continue;

      final under = out.getPixel(px, py);
      final base =
          0xFF000000 |
          (under.r.toInt() << 16) |
          (under.g.toInt() << 8) |
          under.b.toInt();

      final int argb;
      if (region.core) {
        argb = kFlameCore;
      } else if (region.flame) {
        argb = kFlame;
      } else {
        argb = _blend(base, 0xFFFFFFFF, isBase ? kBaseAlpha : kNicheAlpha);
      }
      out.setPixelRgba(
        px,
        py,
        (argb >> 16) & 0xFF,
        (argb >> 8) & 0xFF,
        argb & 0xFF,
        255,
      );
    }
  }

  return out;
}

/// The mark alone on transparency, for surfaces that supply their own ground.
Image _tintedMark(Image color, Image white, {required bool forDarkGround}) {
  final box = _markBounds(color);
  final out = Image(width: box.width, height: box.height, numChannels: 4);

  for (var y = 0; y < box.height; y++) {
    for (var x = 0; x < box.width; x++) {
      final c = color.getPixel(box.left + x, box.top + y);
      final w = white.getPixel(box.left + x, box.top + y);
      final region = _classify(c, w);

      if (region.core) {
        out.setPixelRgba(x, y, 0xF1, 0xE0, 0xB7, 255);
      } else if (region.flame) {
        out.setPixelRgba(x, y, 0xDB, 0xBC, 0x74, 255);
      } else if (region.niche) {
        // White on dark grounds, the palette's ink on light ones.
        if (forDarkGround) {
          out.setPixelRgba(x, y, 0xFF, 0xFF, 0xFF, 255);
        } else {
          out.setPixelRgba(x, y, 0x12, 0x3A, 0x31, 255);
        }
      } else {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
  return out;
}

/// Android adaptive icons crop hard: the mark occupies 66% of the safe zone,
/// as the design board specifies, on a transparent 432px canvas.
Image _adaptiveForeground(Image mark) {
  const size = 432;
  final out = Image(width: size, height: size, numChannels: 4);
  final target = (size * 0.66 * 0.72).round();
  final scaled = copyResize(
    mark,
    height: target,
    interpolation: Interpolation.cubic,
  );
  compositeImage(
    out,
    scaled,
    dstX: ((size - scaled.width) / 2).round(),
    dstY: ((size - scaled.height) / 2).round(),
  );
  return out;
}

/// White silhouette with the flame punched through, at every density.
///
/// Android tints notification icons to a flat colour and masks anything that
/// is not a silhouette into a featureless blob, so the flame has to read as a
/// hole rather than as a different colour.
void _writeNotificationIcons(Image color, Image white) {
  final box = _markBounds(color);
  final master = Image(width: box.width, height: box.height, numChannels: 4);

  for (var y = 0; y < box.height; y++) {
    for (var x = 0; x < box.width; x++) {
      final c = color.getPixel(box.left + x, box.top + y);
      final w = white.getPixel(box.left + x, box.top + y);
      final region = _classify(c, w);
      // Flame and core are punched out; only the body stays.
      final solid = region.niche && !region.flame && !region.core;
      out(master, x, y, solid);
    }
  }

  const densities = {
    'mdpi': 24,
    'hdpi': 36,
    'xhdpi': 48,
    'xxhdpi': 72,
    'xxxhdpi': 96,
  };
  for (final entry in densities.entries) {
    final dir = Directory('$kAndroidRes/drawable-${entry.key}');
    dir.createSync(recursive: true);
    final resized = copyResize(
      master,
      height: entry.value,
      interpolation: Interpolation.cubic,
    );
    final canvas = Image(
      width: entry.value,
      height: entry.value,
      numChannels: 4,
    );
    compositeImage(
      canvas,
      resized,
      dstX: ((entry.value - resized.width) / 2).round(),
      dstY: 0,
    );

    // Downscaling bleeds the transparent areas' black into edge pixels, which
    // leaves grey fringes. A tintable silhouette should carry shape in alpha
    // alone, so pin every channel white and keep only the alpha.
    for (final p in canvas) {
      p.setRgba(255, 255, 255, p.a);
    }

    File('${dir.path}/ic_notification.png').writeAsBytesSync(encodePng(canvas));
  }
}

void out(Image image, int x, int y, bool solid) {
  image.setPixelRgba(x, y, 255, 255, 255, solid ? 255 : 0);
}

({int left, int top, int width, int height}) _markBounds(Image image) {
  var minX = image.width, minY = image.height, maxX = -1, maxY = -1;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a > 8) {
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    }
  }
  return (
    left: minX,
    top: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
}
