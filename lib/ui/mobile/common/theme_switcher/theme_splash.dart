import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class ThemeSplash extends CustomPainter {
  const ThemeSplash({required this.sizeRate, required this.offset});

  final double sizeRate;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(sizeRate / 8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
      ..strokeWidth = 80;

    paintBlurredCircle(
      canvas: canvas,
      paint: paint,
      size: size,
    );
  }

  void paintBlurredCircle({
    required Canvas canvas,
    required Paint paint,
    required Size size,
  }) {
    canvas.save();

    final circle = Path()
      ..addOval(
        Rect.fromCircle(
          center: offset,
          radius: lerpDouble(0.0, _calcMaxRadius(size, offset) + 40, sizeRate)!,
        ),
      );

    canvas.drawPath(circle, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  static double _calcMaxRadius(Size size, Offset center) {
    final w = max(center.dx, size.width - center.dx);
    final h = max(center.dy, size.height - center.dy);
    return sqrt(w * w + h * h);
  }
}
