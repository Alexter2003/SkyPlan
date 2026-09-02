import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_motion.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_typography.dart';

/// Two/three-way exclusive selector — used for activity type
/// (Exterior/Interior, requirement 4.b) and similar toggles.
class SkySegmentedControl<T> extends StatelessWidget {
  const SkySegmentedControl({
    super.key,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.ink, width: shapes.borderThin),
        borderRadius: shapes.radiusMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: _Segment(
                label: optionLabel(option),
                selected: option == value,
                onTap: () => onChanged(option),
                colors: colors,
                typography: typography,
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.typography,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final SkyColors colors;
  final SkyTypography typography;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SkyMotion.fast,
        curve: SkyMotion.standard,
        color: selected ? colors.ink : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: typography.bodyStrong.copyWith(
            fontSize: 13,
            color: selected ? colors.background : colors.ink,
          ),
        ),
      ),
    );
  }
}
