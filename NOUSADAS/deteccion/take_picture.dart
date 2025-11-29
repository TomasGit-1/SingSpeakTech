import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../onnx_yolo_service.dart';
import 'result_preview_screen.dart';


class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key});

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);

    // final frontCamera = cameras.firstWhere(
    //   (cam) => cam.lensDirection == CameraLensDirection.front,
    // );

    // _controller = CameraController(frontCamera, ResolutionPreset.medium);

    await _controller!.initialize();
    if (!mounted) return;

    setState(() => _init = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_init) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Tomar foto")),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Capturar"),
            onPressed: () async {
              final file = await _controller!.takePicture();
              await OnnxYoloService.loadModel();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultPreviewScreen(imagePath: file.path),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

