import 'dart:typed_data';
import 'package:flutter/services.dart';

class YOLODetection {
  final double x1, y1, x2, y2, score;
  final int cls;

  YOLODetection({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.score,
    required this.cls,
  });
}

class OnnxYoloService {
  static const _channel = MethodChannel("onnx_yolo");

  static Future<void> loadModel() async {
    await _channel.invokeMethod("loadOnnx");
  }

  static Future<List<YOLODetection>> runOnnx(Float32List input) async {
    final raw = await _channel.invokeMethod<List<dynamic>>(
      "runOnnx",
      {"input": input.toList()},
    );

    if (raw == null) return [];

    return raw.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return YOLODetection(
        x1: (m["x1"] as num).toDouble(),
        y1: (m["y1"] as num).toDouble(),
        x2: (m["x2"] as num).toDouble(),
        y2: (m["y2"] as num).toDouble(),
        score: (m["score"] as num).toDouble(),
        cls: (m["cls"] as num).toInt(),
      );
    }).toList();
  }
}
