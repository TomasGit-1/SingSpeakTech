import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/yolo_service.dart';

class CameraPhotoYoloView extends StatefulWidget {
  const CameraPhotoYoloView({super.key});

  @override
  State<CameraPhotoYoloView> createState() => _CameraPhotoYoloViewState();
}

class _CameraPhotoYoloViewState extends State<CameraPhotoYoloView> {
  CameraController? cam;
  bool loading = false;
  String result = "";
  XFile? lastPhoto;
  late YoloService yolo;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    yolo = YoloService();
    await yolo.loadModel();

    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    cam = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cam!.initialize();

    setState(() {});
  }

  Future<void> takePhoto() async {
    if (cam == null || !cam!.value.isInitialized) return;

    setState(() {
      loading = true;
      result = "Procesando...";
    });

    final XFile file = await cam!.takePicture();
    lastPhoto = file;

    final text = await yolo.detectFromImageFile(file.path);

    setState(() {
      loading = false;
      result = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cam == null || !cam!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("YOLO Foto — LSM")),
      body: Stack(
        children: [
          // Vista de cámara
          CameraPreview(cam!),

          // UI Overlay
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // RESULTADO
                if (!loading)
                  Text(
                    result,
                    style: const TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),

                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),

                const SizedBox(height: 20),

                // BOTÓN PARA TOMAR FOTO
                GestureDetector(
                  onTap: takePhoto,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // MINI PREVIEW DE LA FOTO
          if (lastPhoto != null)
            Positioned(
              top: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(lastPhoto!.path),
                  width: 100,
                  height: 130,
                  fit: BoxFit.cover,
                ),
              ),
            )
        ],
      ),
    );
  }
}
