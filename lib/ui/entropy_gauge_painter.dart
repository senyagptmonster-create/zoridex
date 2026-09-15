import 'dart:math';
import 'package:flutter/material.dart';

class EntropyGaugePainter extends CustomPainter {
  final double entropyRatio; // 0.0 to 1.0

  EntropyGaugePainter({required this.entropyRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width * 0.42;

    // Track arc
    final trackPaint = Paint()
      ..color = const Color(0xFF22303C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      trackPaint,
    );

    // Active entropy arc
    final activePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE63946), Color(0xFFFFB703), Color(0xFF2A9D8F)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final sweep = (entropyRatio.clamp(0.0, 1.0)) * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      sweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant EntropyGaugePainter oldDelegate) =>
      oldDelegate.entropyRatio != entropyRatio;
}
