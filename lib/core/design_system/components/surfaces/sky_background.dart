import 'package:flutter/material.dart';

import '../../painters/sky_grid_painter.dart';
import '../../tokens/sky_colors.dart';

/// Paints the screen's base background: solid [SkyColors.background] plus
/// the subtle 24px retícula from the design canvas. Wrap screen content
/// with this instead of setting `Scaffold.backgroundColor` directly when
/// the grid texture should show through — [SkyScaffold] already does this.
class SkyBackground extends StatelessWidget {
  const SkyBackground({super.key, required this.child, this.showGrid = true});

  final Widget child;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    return Container(
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
