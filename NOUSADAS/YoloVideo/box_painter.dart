import 'package:flutter/material.dart';
import '../onnx_yolo_service.dart';

class YoloBoxPainter extends CustomPainter {
  final List<YOLODetection> dets;

  YoloBoxPainter(this.dets);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var d in dets) {
      final rect = Rect.fromLTRB(d.x1, d.y1, d.x2, d.y2);
      canvas.drawRect(rect, paint);

      final text = "${d.cls} ${(d.score * 100).toStringAsFixed(1)}%";
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(canvas, Offset(d.x1, d.y1 - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
