import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_spacing.dart';

/// The thick-bordered, rounded card every list item / detail block sits in
/// (activity cards, location cards, weather summaries).
class SkyCard extends StatelessWidget {
  const SkyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SkySpacing.md),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final shapes = context.skyShapes;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: shapes.radiusLg,
        border: Border.all(color: colors.ink, width: shapes.borderThick),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: shapes.radiusLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}
