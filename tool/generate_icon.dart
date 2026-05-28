// Generates assets/icon/icon.png — a minimal serif "I" mark on warm
// off-white, matching the in-app palette. Run with:
//   dart run tool/generate_icon.dart
//
// 1024x1024 PNG. Foreground/background-only — no transparent margin.

import 'dart:io';
import 'package:image/image.dart' as img;

const _size = 1024;
final _bg = img.ColorRgb8(0xFA, 0xFA, 0xF7);
final _ink = img.ColorRgb8(0x25, 0x23, 0x20);
final _gold = img.ColorRgb8(0xC9, 0xA6, 0x6B);

void main() {
  _writeLegacyIcon();
  _writeAdaptiveForeground();
  _writeSplashWordmark();
}

void _drawSerifI(img.Image image, {required int center, required int height}) {
  // stem
  final stemHalf = 42;
  final serifHalf = 162;
  final serifThick = 52;
  final top = center - height ~/ 2;
  final bottom = center + height ~/ 2;
  img.fillRect(
    image,
    x1: _size ~/ 2 - stemHalf,
    y1: top,
    x2: _size ~/ 2 + stemHalf,
    y2: bottom,
    color: _ink,
  );
  // top serif
  img.fillRect(
    image,
    x1: _size ~/ 2 - serifHalf,
    y1: top,
    x2: _size ~/ 2 + serifHalf,
    y2: top + serifThick,
    color: _ink,
  );
  // bottom serif
  img.fillRect(
    image,
    x1: _size ~/ 2 - serifHalf,
    y1: bottom - serifThick,
    x2: _size ~/ 2 + serifHalf,
    y2: bottom,
    color: _ink,
  );
}

// Legacy square icon — used on older Android (pre-8). Ring + serif I.
void _writeLegacyIcon() {
  final image = img.Image(width: _size, height: _size);
  img.fill(image, color: _bg);
  img.fillCircle(image, x: _size ~/ 2, y: _size ~/ 2, radius: 460, color: _gold);
  img.fillCircle(image, x: _size ~/ 2, y: _size ~/ 2, radius: 455, color: _bg);
  _drawSerifI(image, center: _size ~/ 2, height: 484);
  final out = File('assets/icon/icon.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Wrote ${out.path} (${_size}x$_size legacy)');
}

// Adaptive foreground: no ring, transparent bg. The OS clips to a
// circle/squircle so we keep the mark inside the safe 66% area.
void _writeAdaptiveForeground() {
  final image = img.Image(width: _size, height: _size, numChannels: 4);
  // fully transparent fill via setPixelRgba
  for (int y = 0; y < _size; y++) {
    for (int x = 0; x < _size; x++) {
      image.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }
  _drawSerifI(image, center: _size ~/ 2, height: 380);
  final out = File('assets/icon/icon_adaptive.png');
  out.writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Wrote ${out.path} (${_size}x$_size adaptive fg)');
}

// Splash mark — same legacy treatment, used by flutter_native_splash.
void _writeSplashWordmark() {
  final image = img.Image(width: _size, height: _size);
  img.fill(image, color: _bg);
  _drawSerifI(image, center: _size ~/ 2, height: 360);
  final out = File('assets/icon/splash.png');
  out.writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Wrote ${out.path} (${_size}x$_size splash)');
}
