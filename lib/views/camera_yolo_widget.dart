import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/yolo_service.dart';

class CameraYoloWidget extends StatefulWidget {
  const CameraYoloWidget({super.key});

  @override
  State<CameraYoloWidget> createState() => _CameraYoloWidgetState();
}

class _CameraYoloWidgetState extends State<CameraYoloWidget> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  late YoloService _yolo;
  List<Map<String, dynamic>> _detections = [];

  @override
  void initState() {
    super.initState();
    _initCameraAndModel();
  }

  Future<void> _initCameraAndModel() async {
    // Inicializar YOLO
    _yolo = YoloService();
    await _yolo.loadModel();

    // Inicializar Cámara
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    // Activar stream
    _cameraController!.startImageStream((image) {
      if (!_isDetecting) {
        _isDetecting = true;
        _processCameraFrame(image).then((_) {
          _isDetecting = false;
        });
      }
    });

    setState(() {});
  }

  /// Procesa los frames y ejecuta YOLO
  Future<void> _processCameraFrame(CameraImage image) async {
    try {
      // Tomamos solo el plano Y para simplificar (luminancia)
      final Uint8List bytes = image.planes[0].bytes;

      final results = await _yolo.runYoloOnCameraImage(image);


      setState(() {
        _detections = results;
      });
    } catch (e) {
      print("Error YOLO: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        // Vista de la cámara
        CameraPreview(_cameraController!),

        // Detecciones
        Positioned.fill(
          child: CustomPaint(
            painter: _YoloPainter(
              detections: _detections,
              previewSize: _cameraController!.value.previewSize!,
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================================
/// PINTOR PARA CAJAS DE DETECCIÓN
/// ===============================================
class _YoloPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;
  final Size previewSize;

  _YoloPainter({required this.detections, required this.previewSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (var det in detections) {
      final rect = Rect.fromLTWH(
        det["x"],
        det["y"],
        det["w"],
        det["h"],
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _YoloPainter oldDelegate) => true;
}
