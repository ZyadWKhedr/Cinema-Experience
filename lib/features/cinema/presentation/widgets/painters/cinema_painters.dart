import 'dart:math' as math;
import 'package:flutter/material.dart';

class CountdownPainter extends CustomPainter {
  final double sweep;

  const CountdownPainter(this.sweep);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) * 0.85;

    final line = Paint()
      ..color = Colors.white.withValues(alpha:0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), line);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), line);
    canvas.drawCircle(Offset(cx, cy), r, line);
    canvas.drawCircle(Offset(cx, cy), r * 0.9, line..strokeWidth = 3.0);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweep * math.pi * 2,
      true,
      Paint()..color = Colors.white.withValues(alpha:0.15),
    );
  }

  @override
  bool shouldRepaint(covariant CountdownPainter oldDelegate) =>
      oldDelegate.sweep != sweep;
}