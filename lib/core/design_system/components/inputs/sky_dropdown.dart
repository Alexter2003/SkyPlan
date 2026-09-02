import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_typography.dart';

/// Labeled dropdown select, styled to match [SkyTextField]'s border/radius
/// tokens (Flutter's [DropdownButtonFormField] doesn't fully honor
/// `InputDecorationTheme`'s border side color on some platforms, so the
/// border is drawn explicitly here).
class SkyDropdown<T> extends StatelessWidget {
  const SkyDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.label,
    this.errorText,
  });

  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;
  final String? label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: typography.label),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: shapes.radiusMd,
            border: Border.all(
              color: errorText != null
                  ? colors.statusPostpone.background
                  : colors.ink,
              width: shapes.borderThin,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              style: typography.body.copyWith(color: colors.ink),
              dropdownColor: colors.surface,
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(itemLabel(item)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: typography.caption.copyWith(
              color: colors.statusPostpone.background,
            ),
          ),
        ],
      ],
    );
  }
}
