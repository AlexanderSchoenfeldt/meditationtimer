import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressRingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color track;
  final Color arc;
  final double stroke;

  ProgressRingPainter({
    required this.progress,
    required this.track,
    required this.arc,
    this.stroke = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arcPaint = Paint()
      ..color = arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter old) =>
      old.progress != progress || old.track != track || old.arc != arc;
}
