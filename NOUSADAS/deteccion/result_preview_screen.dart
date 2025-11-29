import 'dart:io';
import 'package:flutter/material.dart';
import '../YoloImages/image_processor.dart';

class ResultPreviewScreen extends StatefulWidget {
  final String imagePath;

  const ResultPreviewScreen({super.key, required this.imagePath});

  @override
  State<ResultPreviewScreen> createState() => _ResultPreviewScreenState();
}

class _ResultPreviewScreenState extends State<ResultPreviewScreen> {
  bool loading = true;
  String? detectedLetter;
  static const List<String> yoloLabels = [
  "A","B","C","D","E","F","G","H","I","J",
  "K","L","M","N","O","P","Q","R","RR","S",
  "T","U","V","W","X","Y","Z"
];

  @override
  void initState() {
    super.initState();
    _runYolo();
  }

  Future<void> _runYolo() async {
    final detections = await YoloImageProcessor.processImage(widget.imagePath);

    print("Detecciones: ${detections.length}");
    

    if (detections.isNotEmpty) {
      // Tomamos la mejor detección (score más alto)
      final best = detections.reduce((a, b) => a.score > b.score ? a : b);

      if (best.cls >= 0 && best.cls < yoloLabels.length) {
        detectedLetter = yoloLabels[best.cls];
      } else {
        detectedLetter = "Clase inválida";
      }
    } else {
      detectedLetter = "Sin detección";
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Resultado YOLO")),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 20),

          if (loading)
            const CircularProgressIndicator(),

          if (!loading)
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                detectedLetter ?? "No detectado",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
