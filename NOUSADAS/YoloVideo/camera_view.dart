import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../onnx_yolo_service.dart';
import 'preprocess.dart';
import 'box_painter.dart';

class CameraYoloView extends StatefulWidget {
  const CameraYoloView({super.key});

  @override
  State<CameraYoloView> createState() => _CameraYoloViewState();
}

class _CameraYoloViewState extends State<CameraYoloView> {
  CameraController? _cam;
  bool busy = false;
  List<YOLODetection> dets = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await OnnxYoloService.loadModel();

    final cameras = await availableCameras();

    // _cam = CameraController(cameras[0], ResolutionPreset.medium);
  
    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
    );

    _cam = CameraController(frontCamera, ResolutionPreset.medium);
    await _cam!.initialize();

    _cam!.startImageStream((img) => process(img));

    setState(() {});
  }

  Future<void> process(CameraImage image) async {
    if (busy) return;
    busy = true;

    final tensor = preprocessYuv(image);
    dets = await OnnxYoloService.runOnnx(tensor);

    setState(() {});
    busy = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_cam == null || !_cam!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Camera"),
      ),
      body: Stack(
        children: [
          CameraPreview(_cam!),
          CustomPaint(
            painter: YoloBoxPainter(dets),
          ),
        ],
      ),
    );
  }
}
