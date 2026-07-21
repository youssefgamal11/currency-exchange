import 'package:flutter/material.dart';

/// A tiny 2px-stroke line chart used decoratively wherever a rate trend
/// needs a glance-sized visual (rate chips, preview rows).
class MiniSparkline extends StatelessWidget {
  const MiniSparkline({
    super.key,
    required this.points,
    required this.color,
    required this.width,
    required this.height,
  });

  final List<double> points;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _SparklinePainter(points: points, color: color)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter({required this.points, required this.color});

  final List<double> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final stepX = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = stepX * i;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
