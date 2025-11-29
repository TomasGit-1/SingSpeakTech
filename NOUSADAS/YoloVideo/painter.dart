import 'package:flutter/material.dart';

class BoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;

  BoxPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: Colors.greenAccent,
      fontSize: 14,
    );

    for (var det in detections) {
      final rect = Rect.fromLTWH(
        det['x1'],
        det['y1'],
        det['x2'] - det['x1'],
        det['y2'] - det['y1'],
      );

      canvas.drawRect(rect, paint);

      final textSpan = TextSpan(
        text: "cls ${det['cls']}  ${det['conf'].toStringAsFixed(2)}",
        style: textStyle,
      );

      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      painter.layout();
      painter.paint(canvas, Offset(det['x1'], det['y1'] - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
