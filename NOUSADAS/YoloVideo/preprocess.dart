import 'dart:typed_data';
import 'package:camera/camera.dart';

/// Ajusta esta variable cuando uses cámara frontal o trasera
bool useFrontCamera = true;


Float32List preprocessYuv(CameraImage image) {
  const int inputSize = 640;

  final int width = image.width;
  final int height = image.height;

  Uint8List rgb = _yuv420ToRgb(image, width, height);

  Uint8List rotated = _rotate90(rgb, width, height);

  final int newW = height;
  final int newH = width;

  if (useFrontCamera) {
    rotated = _flipHorizontal(rotated, newW, newH);
  }

  Uint8List resized = _resizeRgb(rotated, newW, newH, inputSize);

  Float32List tensor = Float32List(3 * inputSize * inputSize);
  int idx = 0;

  for (int c = 0; c < 3; c++) {
    for (int i = c; i < resized.length; i += 3) {
      tensor[idx++] = resized[i] / 255.0;
    }
  }

  return tensor;
}


Uint8List _yuv420ToRgb(CameraImage image, int width, int height) {
  final yPlane = image.planes[0].bytes;
  final uPlane = image.planes[1].bytes;
  final vPlane = image.planes[2].bytes;

  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;

  Uint8List out = Uint8List(width * height * 3);

  int index = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yp = y * width + x;

      final int uvp = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;

      final int Y = yPlane[yp];
      final int U = uPlane[uvp];
      final int V = vPlane[uvp];

      double r = Y + 1.370705 * (V - 128);
      double g = Y - 0.337633 * (U - 128) - 0.698001 * (V - 128);
      double b = Y + 1.732446 * (U - 128);

      out[index++] = r.clamp(0, 255).toInt();
      out[index++] = g.clamp(0, 255).toInt();
      out[index++] = b.clamp(0, 255).toInt();
    }
  }

  return out;
}

Uint8List _rotate90(Uint8List rgb, int w, int h) {
  Uint8List out = Uint8List(w * h * 3);

  int index = 0;
  for (int x = 0; x < w; x++) {
    for (int y = h - 1; y >= 0; y--) {
      int src = (y * w + x) * 3;
      out[index++] = rgb[src];
      out[index++] = rgb[src + 1];
      out[index++] = rgb[src + 2];
    }
  }

  return out;
}

Uint8List _flipHorizontal(Uint8List rgb, int w, int h) {
  Uint8List out = Uint8List(w * h * 3);

  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      int src = (y * w + x) * 3;
      int dst = (y * w + (w - 1 - x)) * 3;

      out[dst] = rgb[src];
      out[dst + 1] = rgb[src + 1];
      out[dst + 2] = rgb[src + 2];
    }
  }

  return out;
}

Uint8List _resizeRgb(Uint8List rgb, int w, int h, int newSize) {
  Uint8List out = Uint8List(newSize * newSize * 3);

  double xRatio = w / newSize;
  double yRatio = h / newSize;

  int index = 0;

  for (int y = 0; y < newSize; y++) {
    for (int x = 0; x < newSize; x++) {
      int px = (x * xRatio).floor();
      int py = (y * yRatio).floor();

      int src = (py * w + px) * 3;

      out[index++] = rgb[src];
      out[index++] = rgb[src + 1];
      out[index++] = rgb[src + 2];
    }
  }

  return out;
}
