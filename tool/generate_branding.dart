import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

const _background = 0xFF303841;

Future<void> main() async {
  final source = File('assets/branding/app_logo.png');
  final bytes = await source.readAsBytes();
  final logo = decodePng(bytes);
  if (logo == null) {
    stderr.writeln('Failed to decode app_logo.png');
    exit(1);
  }

  final foreground = _extractForeground(logo);
  final bounds = _contentBounds(foreground);
  final cropped = copyCrop(
    foreground,
    x: bounds.left,
    y: bounds.top,
    width: bounds.width,
    height: bounds.height,
  );

  final iconForeground = _centerOnCanvas(
    cropped,
    size: 1024,
    contentDiameter: 640,
  );
  final splashIcon = _centerOnCanvas(
    cropped,
    size: 1152,
    contentDiameter: 680,
  );
  final appIcon = _composeOnBackground(
    cropped,
    size: 1024,
    contentDiameter: 520,
    background: _background,
  );
  final android12Splash = _composeOnBackground(
    cropped,
    size: 960,
    contentDiameter: 560,
    background: _background,
  );

  await _writePng('assets/branding/icon_foreground.png', iconForeground);
  await _writePng('assets/branding/splash_icon.png', splashIcon);
  await _writePng('assets/branding/app_icon.png', appIcon);
  await _writePng('assets/branding/android12_splash.png', android12Splash);

  stdout.writeln('Generated branding assets:');
  stdout.writeln('  icon_foreground.png  1024x1024 (adaptive icon / Android 12)');
  stdout.writeln('  splash_icon.png      1152x1152 (native splash center image)');
  stdout.writeln('  app_icon.png         1024x1024 (iOS / legacy launcher icon)');
  stdout.writeln('  android12_splash.png 960x960   (Android 12 splash icon)');
}

Image _extractForeground(Image source) {
  final result = Image(width: source.width, height: source.height, numChannels: 4);

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final pixel = source.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      if (_isBackground(r, g, b)) {
        result.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        result.setPixelRgba(x, y, r, g, b, 255);
      }
    }
  }

  return result;
}

bool _isBackground(int r, int g, int b) {
  const bgR = 0x30;
  const bgG = 0x38;
  const bgB = 0x41;
  const tolerance = 24;

  return (r - bgR).abs() <= tolerance &&
      (g - bgG).abs() <= tolerance &&
      (b - bgB).abs() <= tolerance;
}

({int left, int top, int width, int height}) _contentBounds(Image image) {
  var minX = image.width;
  var minY = image.height;
  var maxX = 0;
  var maxY = 0;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a > 16) {
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

Image _centerOnCanvas(
  Image icon, {
  required int size,
  required int contentDiameter,
}) {
  final canvas = Image(width: size, height: size, numChannels: 4);
  final scale = contentDiameter / math.max(icon.width, icon.height);
  final targetWidth = (icon.width * scale).round();
  final targetHeight = (icon.height * scale).round();
  final resized = copyResize(icon, width: targetWidth, height: targetHeight);
  compositeImage(
    canvas,
    resized,
    dstX: (size - targetWidth) ~/ 2,
    dstY: (size - targetHeight) ~/ 2,
  );
  return canvas;
}

Image _composeOnBackground(
  Image icon, {
  required int size,
  required int contentDiameter,
  required int background,
}) {
  final canvas = Image(width: size, height: size, numChannels: 4);
  fill(
    canvas,
    color: ColorRgb8(
      (_background >> 16) & 0xFF,
      (_background >> 8) & 0xFF,
      _background & 0xFF,
    ),
  );
  final scale = contentDiameter / math.max(icon.width, icon.height);
  final targetWidth = (icon.width * scale).round();
  final targetHeight = (icon.height * scale).round();
  final resized = copyResize(icon, width: targetWidth, height: targetHeight);
  compositeImage(
    canvas,
    resized,
    dstX: (size - targetWidth) ~/ 2,
    dstY: (size - targetHeight) ~/ 2,
  );
  return canvas;
}

Future<void> _writePng(String path, Image image) async {
  await File(path).writeAsBytes(encodePng(image));
}
