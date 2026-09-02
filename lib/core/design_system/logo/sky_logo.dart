import 'package:flutter/material.dart';

import '../tokens/sky_colors.dart';
import '../tokens/sky_typography.dart';

/// SkyPlan's logotype mark (requirement 1.c): a rounded red square, a
/// yellow circle, and a blue triangle — the three pure Bauhaus primitives,
/// reproduced from the approved design canvas.
class SkyLogoMark extends StatelessWidget {
  const SkyLogoMark({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SkyLogoPainter(
          red: colors.primaryRed,
          yellow: colors.primaryYellow,
          blue: colors.primaryBlue,
        ),
      ),
    );
  }
}

class _SkyLogoPainter extends CustomPainter {
  const _SkyLogoPainter({
    required this.red,
    required this.yellow,
    required this.blue,
  });

  final Color red;
  final Color yellow;
  final Color blue;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final radius = s * 0.18;

    final square = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, s, s),
      Radius.circular(radius),
    );
    canvas.drawRRect(square, Paint()..color = red);

    canvas.drawCircle(
      Offset(s / 2, s * 0.41),
      s * 0.265,
      Paint()..color = yellow,
    );

    final triangle = Path()
      ..moveTo(0, s)
      ..lineTo(s / 2, s / 2)
      ..lineTo(s, s)
      ..close();
    canvas.save();
    canvas.clipRRect(square);
    canvas.drawPath(triangle, Paint()..color = blue);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SkyLogoPainter oldDelegate) {
    return oldDelegate.red != red ||
        oldDelegate.yellow != yellow ||
        oldDelegate.blue != blue;
  }
}

/// Mark + wordmark, stacked the way Login and the drawer header use it.
class SkyLogo extends StatelessWidget {
  const SkyLogo({super.key, this.markSize = 34, this.showTagline = true});

  final double markSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final typography = context.skyTypography;
    final colors = context.skyColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkyLogoMark(size: markSize),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('SkyPlan', style: typography.headline),
            if (showTagline)
              Text(
                'PLANIFICADOR',
                style: typography.label.copyWith(color: colors.subtle),
              ),
          ],
        ),
      ],
    );
  }
}
