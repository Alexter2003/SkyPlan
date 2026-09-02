import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_typography.dart';

/// Small filled pill for counts/labels (e.g. "3 actividades") — informational
/// only, not tappable. For an interactive pill use [SkyChip].
class SkyBadge extends StatelessWidget {
  const SkyBadge({
    super.key,
    required this.label,
    this.background,
    this.foreground,
  });

  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? colors.ink,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: foreground ?? colors.background,
        ),
      ),
    );
  }
}
