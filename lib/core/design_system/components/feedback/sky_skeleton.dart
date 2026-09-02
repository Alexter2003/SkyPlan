import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_shapes.dart';

/// Shimmering placeholder block for loading states (activity list while the
/// weather API resolves, location list while fetching, etc).
class SkySkeleton extends StatefulWidget {
  const SkySkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<SkySkeleton> createState() => _SkySkeletonState();
}

class _SkySkeletonState extends State<SkySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final shapes = context.skyShapes;

    // Opaque tones composited against the surface color, so the block reads
    // clearly against both the card surface and the page background —
    // lerping translucent tokens directly (as before) barely tinted
    // whatever sat behind it and was nearly invisible in both themes.
    final base = Color.alphaBlend(
      colors.subtle.withValues(alpha: 0.22),
      colors.surface,
    );
    final highlight = Color.alphaBlend(
      colors.subtle.withValues(alpha: 0.4),
      colors.surface,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(base, highlight, _controller.value),
            borderRadius: widget.borderRadius ?? shapes.radiusXs,
            border: Border.all(color: colors.border),
          ),
        );
      },
    );
  }
}
