import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../onnx_yolo_service.dart';

class YoloImageProcessor {
  static const int inputSize = 640;

  /// Procesa una foto desde un path y regresa detecciones YOLO
  static Future<List<YOLODetection>> processImage(String path) async {
    // Leer archivo
    final bytes = await File(path).readAsBytes();

    // Decodificar JPG/PNG
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return [];

    // Rotar si está vertical
    if (image.width < image.height) {
      image = img.copyRotate(
        image,
        angle: 90, // <-- obligatorio en v4.x
      );
    }

    // Redimensionar a 640x640
    final resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.nearest,
    );

    // Convertir a tensor YOLO CHW
    Float32List tensor = _imageToTensor(resized);

    // Ejecutar YOLO ONNX
    return await OnnxYoloService.runOnnx(tensor);
  }

  /// Convierte img.Image → Float32List [1,3,640,640]
  static Float32List _imageToTensor(img.Image image) {
    Float32List tensor = Float32List(3 * inputSize * inputSize);
    int index = 0;

    for (int c = 0; c < 3; c++) {
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = image.getPixel(x, y);

          final value = (c == 0)
              ? pixel.r // rojo
              : (c == 1)
                  ? pixel.g // verde
                  : pixel.b; // azul

          tensor[index++] = value / 255.0;
        }
      }
    }

    return tensor;
  }
}
