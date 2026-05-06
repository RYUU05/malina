import 'package:flutter/material.dart';

class MalinaPainter extends CustomPainter {
  final Color color;

  MalinaPainter({this.color = const Color(0xFFFFB6C1)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width * 0.44;
    final ry = size.height * 0.44;

    // Shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + 6),
        width: rx * 2,
        height: ry * 2,
      ),
      shadowPaint,
    );

    // Main blob — slightly organic shape using path
    final path = Path();

    // Top
    path.moveTo(cx, cy - ry);
    // Top-right bump
    path.quadraticBezierTo(
      cx + rx * 0.7,
      cy - ry * 0.9,
      cx + rx,
      cy - ry * 0.2,
    );
    // Right bump
    path.quadraticBezierTo(
      cx + rx * 1.05,
      cy + ry * 0.3,
      cx + rx * 0.6,
      cy + ry * 0.7,
    );
    // Bottom-right
    path.quadraticBezierTo(cx + rx * 0.3, cy + ry * 1.05, cx, cy + ry);
    // Bottom-left
    path.quadraticBezierTo(
      cx - rx * 0.3,
      cy + ry * 1.05,
      cx - rx * 0.6,
      cy + ry * 0.7,
    );
    // Left bump
    path.quadraticBezierTo(
      cx - rx * 1.05,
      cy + ry * 0.3,
      cx - rx,
      cy - ry * 0.2,
    );
    // Top-left bump
    path.quadraticBezierTo(cx - rx * 0.7, cy - ry * 0.9, cx, cy - ry);

    path.close();

    canvas.drawPath(path, paint);

    // Small decorative circles (berry-like dots)
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final dots = [
      Offset(cx - rx * 0.3, cy - ry * 0.4),
      Offset(cx + rx * 0.25, cy - ry * 0.5),
      Offset(cx - rx * 0.1, cy - ry * 0.15),
      Offset(cx + rx * 0.4, cy - ry * 0.1),
      Offset(cx - rx * 0.45, cy + ry * 0.15),
      Offset(cx + rx * 0.15, cy + ry * 0.3),
      Offset(cx - rx * 0.2, cy + ry * 0.55),
      Offset(cx + rx * 0.35, cy + ry * 0.5),
      Offset(cx, cy + ry * 0.75),
    ];

    for (final dot in dots) {
      canvas.drawCircle(dot, 6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MalinaPainter oldDelegate) =>
      color != oldDelegate.color;
}
