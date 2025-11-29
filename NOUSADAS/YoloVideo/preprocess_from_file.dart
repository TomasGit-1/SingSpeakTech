import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../onnx_yolo_service.dart';

Future<List<YOLODetection>> processImageFile(String path) async {
  // Leer bytes del archivo
  final bytes = await File(path).readAsBytes();

  // Decodificar la imagen
  img.Image? im = img.decodeImage(bytes);
  if (im == null) return [];

  const int inputSize = 640;

  // 🔁 Rotar si está en vertical (ancho < alto)
  if (im.width < im.height) {
    im = img.copyRotate(im, angle: 90);
  }

  // 🧩 Redimensionar a 640x640
  final resized = img.copyResize(
    im,
    width: inputSize,
    height: inputSize,
  );

  // 🧠 Convertir a tensor CHW [1,3,640,640]
  final tensor = Float32List(3 * inputSize * inputSize);
  int index = 0;

  for (int c = 0; c < 3; c++) {
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        // Pixel de image v4 → objeto Pixel con r,g,b,a
        final pixel = resized.getPixel(x, y);

        final num channelValue = (c == 0)
            ? pixel.r // rojo
            : (c == 1)
                ? pixel.g // verde
                : pixel.b; // azul

        tensor[index++] = channelValue / 255.0;
      }
    }
  }

  // Ejecutar YOLO ONNX con tu servicio
  return await OnnxYoloService.runOnnx(tensor);
}
