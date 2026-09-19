import 'package:flutter/material.dart';

import '../../painters/sky_grid_painter.dart';
import '../../tokens/sky_colors.dart';

/// Fondo base de pantalla: color [SkyColors.background] + retícula.
class SkyBackground extends StatelessWidget {
  const SkyBackground({super.key, required this.child, this.showGrid = true});

  final Widget child;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    return Container(
      // Ocupa toda la pantalla, sin importar el alto del contenido.
      width: double.infinity,
      height: double.infinity,
      color: colors.background,
      child: Stack(
        children: [
          if (showGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: SkyGridPainter(lineColor: colors.border),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
