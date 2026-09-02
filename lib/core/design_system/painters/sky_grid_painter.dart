import 'package:flutter/material.dart';

/// Paints the subtle 24px retícula used behind screen backgrounds in the
/// approved design canvas (Dirección A · Bauhaus, Paleta 2 Cian neblina).
///
/// Cheap to repaint: two `drawLine` loops, no image decoding, so it's safe
/// to keep behind scrolling content.
class SkyGridPainter extends CustomPainter {
  const SkyGridPainter({required this.lineColor, this.cellSize = 24});

  final Color lineColor;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SkyGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.cellSize != cellSize;
  }
}
