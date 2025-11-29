import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class YoloService {
  late Interpreter interpreter;
  late int inputWidth;
  late int inputHeight;

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset(
      'assets/models/best_float16.tflite',
      options: InterpreterOptions()..threads = 4,
    );

    var inputShape = interpreter.getInputTensor(0).shape;
    inputHeight = inputShape[1];
    inputWidth = inputShape[2];

    print("YOLO cargado — Input: $inputWidth x $inputHeight");
  }

  /// -----------------------------------------------------------
  /// 1. CONVERTIR CÁMARA YUV420 → RGB (STREAM)
  /// -----------------------------------------------------------
  img.Image convertYUV420(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final imgRGB = img.Image(width: width, height: height);

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    for (int y = 0; y < height; y++) {
      final int uvRow = uvRowStride * (y >> 1);

      for (int x = 0; x < width; x++) {
        final int uvPixel = uvRow + (x >> 1) * uvPixelStride;

        final yp = image.planes[0].bytes[y * image.planes[0].bytesPerRow + x];
        final up = image.planes[1].bytes[uvPixel];
        final vp = image.planes[2].bytes[uvPixel];

        int r = (yp + 1.402 * (vp - 128)).round().clamp(0, 255);
        int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).round().clamp(0, 255);
        int b = (yp + 1.772 * (up - 128)).round().clamp(0, 255);

        imgRGB.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return imgRGB;
  }

  /// -----------------------------------------------------------
  /// 2. YOLO PARA STREAM DE CÁMARA (NO FOTO)
  /// -----------------------------------------------------------
  Future<List<Map<String, dynamic>>> runYoloOnCameraImage(
      CameraImage image) async {

    final rgbImage = convertYUV420(image);

    final resized =
        img.copyResize(rgbImage, width: inputWidth, height: inputHeight);

    final Float32List input = Float32List(inputWidth * inputHeight * 3);
    int i = 0;

    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final p = resized.getPixel(x, y);

        input[i++] = p.r / 255.0;
        input[i++] = p.g / 255.0;
        input[i++] = p.b / 255.0;
      }
    }

    final outputTensor = interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;

    int totalSize = 1;
    for (final d in outputShape) {
      totalSize *= d;
    }

    final output =
        List<double>.filled(totalSize, 0.0).reshape(outputShape);

    interpreter.run(
      input.reshape([1, inputHeight, inputWidth, 3]),
      output,
    );

    return parseDetections(output[0], image.width, image.height);
  }

  /// -----------------------------------------------------------
  /// 3. YOLO SOBRE FOTO (LO QUE PEDISTE)
  ///    Devuelve SOLO el TEXTO: "a", "b", "rr", "x", etc.
  /// -----------------------------------------------------------
  Future<String> detectFromImageFile(String path) async {
    final bytes = await File(path).readAsBytes();
    final rgb = img.decodeImage(bytes);

    if (rgb == null) return "No se pudo leer la imagen";

    final resized = img.copyResize(rgb, width: inputWidth, height: inputHeight);

    final Float32List input = Float32List(inputWidth * inputHeight * 3);
    int i = 0;

    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final p = resized.getPixel(x, y);
        input[i++] = p.r / 255.0;
        input[i++] = p.g / 255.0;
        input[i++] = p.b / 255.0;
      }
    }

    final outTensor = interpreter.getOutputTensor(0);
    final shape = outTensor.shape; // [1, 31, 2100]
    final total = shape.reduce((a, b) => a * b);

    final output = List<double>.filled(total, 0.0).reshape(shape);

    interpreter.run(
      input.reshape([1, inputHeight, inputWidth, 3]),
      output,
    );

    return _parseLetter(output[0]);
  }

  /// -----------------------------------------------------------
  /// 4. PARSE DE CLASES → SOLO "a", "b", "rr", "z"
  /// -----------------------------------------------------------
  String _parseLetter(List<List<double>> preds) {
    final numChannels = preds.length; // 31
    final numBoxes = preds[0].length; // 2100
    final numClasses = numChannels - 4; // 27

    double bestScore = 0.0;
    int bestClass = -1;

    for (int box = 0; box < numBoxes; box++) {
      for (int c = 0; c < numClasses; c++) {
        final score = preds[4 + c][box];

        if (score > bestScore) {
          bestScore = score;
          bestClass = c;
        }
      }
    }

    if (bestScore < 0.5 || bestClass == -1) {
      return "No se detectó nada";
    }

    const letters = [
      'a','b','c','d','e','f','g','h','i','j','k','l','m',
      'n','o','p','q','r','rr','s','t','u','v','w','x','y','z'
    ];

    if (bestClass >= letters.length) {
      return "Clase desconocida";
    }

    return letters[bestClass];
  }

  /// -----------------------------------------------------------
  /// 5. PARSE DETALLES PARA DETECCIÓN (CAJAS)
  /// -----------------------------------------------------------
  List<Map<String, dynamic>> parseDetections(
      List<List<double>> preds, int origW, int origH) {
    List<Map<String, dynamic>> results = [];

    final int numChannels = preds.length; // 31
    final int numBoxes = preds[0].length; // 2100
    final int numClasses = numChannels - 4;

    const double confThreshold = 0.5;

    for (int i = 0; i < numBoxes; i++) {
      final double cx = preds[0][i];
      final double cy = preds[1][i];
      final double w = preds[2][i];
      final double h = preds[3][i];

      double maxScore = 0.0;
      int maxClass = -1;

      for (int c = 0; c < numClasses; c++) {
        final score = preds[4 + c][i];
        if (score > maxScore) {
          maxScore = score;
          maxClass = c;
        }
      }

      if (maxScore < confThreshold) continue;

      final double boxW = w * origW;
      final double boxH = h * origH;
      final double left = (cx - w / 2) * origW;
      final double top = (cy - h / 2) * origH;

      results.add({
        "x": left,
        "y": top,
        "w": boxW,
        "h": boxH,
        "confidence": maxScore,
        "classIndex": maxClass,
      });
    }

    return results;
  }
}
