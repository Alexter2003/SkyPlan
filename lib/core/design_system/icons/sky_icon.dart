import 'dart:math' as math;

import 'package:flutter/material.dart';

/// SkyPlan's own stroke-based icon set — 24px grid, 2px stroke, rounded
/// caps/joins, one consistent style. Never mix in `Icons.*` (Material) or
/// emoji for these concepts; add a new [SkyIconType] instead.
enum SkyIconType {
  sun,
  cloud,
  rain,
  location,
  calendar,
  clock,
  check,
  chevronRight,
  search,
  close,
  filter,
  warning,
  menu,
  logout,
  eye,
  eyeOff,
  mail,
  user,
  lock,
  arrowLeft,
  refresh,
  shieldCheck,
}

/// Renders one [SkyIconType] as a [CustomPaint]. Color defaults to the
/// nearest `IconTheme` (so it inherits from buttons/list tiles), or pass
/// [color] explicitly.
class SkyIcon extends StatelessWidget {
  const SkyIcon(this.type, {super.key, this.size, this.color});

  final SkyIconType type;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size ?? 24;
    final resolvedColor = color ?? iconTheme.color ?? const Color(0xFF132226);
    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: CustomPaint(
        painter: _SkyIconPainter(type: type, color: resolvedColor),
      ),
    );
  }
}

class _SkyIconPainter extends CustomPainter {
  const _SkyIconPainter({required this.type, required this.color});

  final SkyIconType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 24;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    Offset p(double x, double y) => Offset(x * s, y * s);

    switch (type) {
      case SkyIconType.sun:
        canvas.drawCircle(p(12, 12), 5 * s, stroke);
        for (final angle in [0, 45, 90, 135, 180, 225, 270, 315]) {
          final rad = angle * math.pi / 180;
          final inner =
              p(12, 12) + Offset(9 * s * _cos(rad), 9 * s * _sin(rad));
          final outer =
              p(12, 12) + Offset(11 * s * _cos(rad), 11 * s * _sin(rad));
          canvas.drawLine(inner, outer, stroke);
        }
      case SkyIconType.cloud:
        final path = Path()
          ..moveTo(6 * s, 17 * s)
          ..cubicTo(3.5 * s, 17 * s, 2 * s, 15 * s, 2 * s, 13 * s)
          ..cubicTo(2 * s, 11 * s, 3.5 * s, 9.5 * s, 5.5 * s, 9.3 * s)
          ..cubicTo(6.2 * s, 6.8 * s, 8.5 * s, 5 * s, 11.5 * s, 5 * s)
          ..cubicTo(15 * s, 5 * s, 17.8 * s, 7.8 * s, 18 * s, 11 * s)
          ..cubicTo(20.2 * s, 11.3 * s, 22 * s, 13 * s, 22 * s, 15.2 * s)
          ..cubicTo(22 * s, 17.3 * s, 20.2 * s, 19 * s, 18 * s, 19 * s)
          ..lineTo(6 * s, 19 * s)
          ..close();
        canvas.drawPath(path, stroke);
      case SkyIconType.rain:
        _paintPainterFor(SkyIconType.cloud).paint(canvas, size);
        for (final x in [8.0, 12.0, 16.0]) {
          canvas.drawLine(p(x, 20), p(x - 1.5, 23), stroke);
        }
      case SkyIconType.location:
        final path = Path()
          ..moveTo(12, 22 * s)
          ..cubicTo(12, 22 * s, 5 * s, 14.5 * s, 5 * s, 9.5 * s)
          ..cubicTo(5 * s, 5.9 * s, 8.1 * s, 3 * s, 12, 3 * s)
          ..cubicTo(15.9 * s, 3 * s, 19 * s, 5.9 * s, 19 * s, 9.5 * s)
          ..cubicTo(19 * s, 14.5 * s, 12, 22 * s, 12, 22 * s)
          ..close();
        canvas.drawPath(path, stroke);
        canvas.drawCircle(p(12, 9.5), 2.4 * s, stroke);
      case SkyIconType.calendar:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(3 * s, 5 * s, 18 * s, 16 * s),
            Radius.circular(2.5 * s),
          ),
          stroke,
        );
        canvas.drawLine(p(3, 10), p(21, 10), stroke);
        canvas.drawLine(p(8, 3), p(8, 7), stroke);
        canvas.drawLine(p(16, 3), p(16, 7), stroke);
      case SkyIconType.clock:
        canvas.drawCircle(p(12, 12), 9 * s, stroke);
        canvas.drawLine(p(12, 12), p(12, 7), stroke);
        canvas.drawLine(p(12, 12), p(15.5, 14), stroke);
      case SkyIconType.check:
        final path = Path()
          ..moveTo(4 * s, 12.5 * s)
          ..lineTo(9.5 * s, 18 * s)
          ..lineTo(20 * s, 6 * s);
        canvas.drawPath(path, stroke);
      case SkyIconType.chevronRight:
        final path = Path()
          ..moveTo(9 * s, 5 * s)
          ..lineTo(16 * s, 12 * s)
          ..lineTo(9 * s, 19 * s);
        canvas.drawPath(path, stroke);
      case SkyIconType.search:
        canvas.drawCircle(p(11, 11), 7 * s, stroke);
        canvas.drawLine(p(16.2, 16.2), p(21, 21), stroke);
      case SkyIconType.close:
        canvas.drawLine(p(5, 5), p(19, 19), stroke);
        canvas.drawLine(p(19, 5), p(5, 19), stroke);
      case SkyIconType.filter:
        final path = Path()
          ..moveTo(3 * s, 5 * s)
          ..lineTo(21 * s, 5 * s)
          ..lineTo(14 * s, 13 * s)
          ..lineTo(14 * s, 20 * s)
          ..lineTo(10 * s, 18 * s)
          ..lineTo(10 * s, 13 * s)
          ..close();
        canvas.drawPath(path, stroke);
      case SkyIconType.warning:
        final path = Path()
          ..moveTo(12 * s, 3 * s)
          ..lineTo(22 * s, 20 * s)
          ..lineTo(2 * s, 20 * s)
          ..close();
        canvas.drawPath(path, stroke);
        canvas.drawLine(p(12, 10), p(12, 14.5), stroke);
        canvas.drawCircle(p(12, 17.2), 0.9 * s, fill);
      case SkyIconType.menu:
        canvas.drawLine(p(4, 7), p(20, 7), stroke);
        canvas.drawLine(p(4, 12), p(20, 12), stroke);
        canvas.drawLine(p(4, 17), p(20, 17), stroke);
      case SkyIconType.logout:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(4 * s, 4 * s, 10 * s, 16 * s),
            Radius.circular(2 * s),
          ),
          stroke,
        );
        canvas.drawLine(p(11, 12), p(21, 12), stroke);
        canvas.drawLine(p(17, 8), p(21, 12), stroke);
        canvas.drawLine(p(17, 16), p(21, 12), stroke);
      case SkyIconType.eye:
        final path = Path()
          ..moveTo(2 * s, 12 * s)
          ..cubicTo(4.5 * s, 6.5 * s, 8 * s, 5 * s, 12 * s, 5 * s)
          ..cubicTo(16 * s, 5 * s, 19.5 * s, 6.5 * s, 22 * s, 12 * s)
          ..cubicTo(19.5 * s, 17.5 * s, 16 * s, 19 * s, 12 * s, 19 * s)
          ..cubicTo(8 * s, 19 * s, 4.5 * s, 17.5 * s, 2 * s, 12 * s)
          ..close();
        canvas.drawPath(path, stroke);
        canvas.drawCircle(p(12, 12), 3 * s, stroke);
      case SkyIconType.eyeOff:
        _paintPainterFor(SkyIconType.eye).paint(canvas, size);
        canvas.drawLine(p(4, 4), p(20, 20), stroke);
      case SkyIconType.mail:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(2 * s, 5 * s, 20 * s, 14 * s),
            Radius.circular(2.5 * s),
          ),
          stroke,
        );
        final flap = Path()
          ..moveTo(3 * s, 6.5 * s)
          ..lineTo(12 * s, 13.5 * s)
          ..lineTo(21 * s, 6.5 * s);
        canvas.drawPath(flap, stroke);
      case SkyIconType.user:
        canvas.drawCircle(p(12, 8), 4 * s, stroke);
        final path = Path()
          ..moveTo(4 * s, 21 * s)
          ..cubicTo(4 * s, 16.5 * s, 7.5 * s, 14 * s, 12 * s, 14 * s)
          ..cubicTo(16.5 * s, 14 * s, 20 * s, 16.5 * s, 20 * s, 21 * s);
        canvas.drawPath(path, stroke);
      case SkyIconType.lock:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(5 * s, 11 * s, 14 * s, 10 * s),
            Radius.circular(2.5 * s),
          ),
          stroke,
        );
        final shackle = Path()
          ..moveTo(8 * s, 11 * s)
          ..lineTo(8 * s, 7.5 * s)
          ..cubicTo(8 * s, 5 * s, 9.8 * s, 3 * s, 12 * s, 3 * s)
          ..cubicTo(14.2 * s, 3 * s, 16 * s, 5 * s, 16 * s, 7.5 * s)
          ..lineTo(16 * s, 11 * s);
        canvas.drawPath(shackle, stroke);
        canvas.drawCircle(p(12, 16), 1.2 * s, fill);
      case SkyIconType.arrowLeft:
        canvas.drawLine(p(20, 12), p(4, 12), stroke);
        canvas.drawLine(p(4, 12), p(10, 6), stroke);
        canvas.drawLine(p(4, 12), p(10, 18), stroke);
      case SkyIconType.refresh:
        canvas.drawArc(
          Rect.fromCircle(center: p(12, 12), radius: 8 * s),
          -math.pi * 0.85,
          math.pi * 1.55,
          false,
          stroke,
        );
        canvas.drawLine(p(19.3, 5.3), p(19.3, 9.5), stroke);
        canvas.drawLine(p(19.3, 9.5), p(15.3, 9.5), stroke);
      case SkyIconType.shieldCheck:
        final path = Path()
          ..moveTo(12 * s, 2.5 * s)
          ..lineTo(20 * s, 6 * s)
          ..lineTo(20 * s, 12 * s)
          ..cubicTo(20 * s, 17 * s, 16.5 * s, 20.2 * s, 12 * s, 21.5 * s)
          ..cubicTo(7.5 * s, 20.2 * s, 4 * s, 17 * s, 4 * s, 12 * s)
          ..lineTo(4 * s, 6 * s)
          ..close();
        canvas.drawPath(path, stroke);
        final check = Path()
          ..moveTo(8.3 * s, 12.3 * s)
          ..lineTo(11 * s, 15 * s)
          ..lineTo(16 * s, 9.3 * s);
        canvas.drawPath(check, stroke);
    }
  }

  _SkyIconPainter _paintPainterFor(SkyIconType t) =>
      _SkyIconPainter(type: t, color: color);

  static double _cos(double rad) => math.cos(rad);
  static double _sin(double rad) => math.sin(rad);

  @override
  bool shouldRepaint(covariant _SkyIconPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.color != color;
  }
}
