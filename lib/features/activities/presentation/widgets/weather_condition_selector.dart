import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/services/condition_rules.dart';
import 'weather_condition_labels.dart';

/// Selección múltiple de condiciones con exclusión mutua: al elegir una,
/// se deshabilitan las que el catálogo marca como contradictorias
/// (`conflictsWith`). La validación final siempre la hace el backend.
class WeatherConditionSelector extends StatelessWidget {
  const WeatherConditionSelector({
    super.key,
    required this.catalog,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  final List<WeatherCondition> catalog;
  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;
  final String? errorText;

  void _toggle(int id) {
    final next = {...selected};
    if (!next.remove(id)) next.add(id);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final blocked = blockedConditionIds(selected, catalog);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: SkySpacing.xs,
          runSpacing: SkySpacing.xs,
          children: [
            for (final condition in catalog)
              SkyChip(
                key: ValueKey('condition-${condition.name}'),
                label: conditionLabel(condition.name),
                selected: selected.contains(condition.id),
                enabled: !blocked.contains(condition.id),
                onSelected: (_) => _toggle(condition.id),
                leading: switch (conditionIcon(condition.name)) {
                  final icon? => SkyIcon(
                    icon,
                    size: 16,
                    color: selected.contains(condition.id)
                        ? colors.onAccent
                        : colors.ink,
                  ),
                  null => null,
                },
              ),
          ],
        ),
        if (blocked.isNotEmpty) ...[
          const SizedBox(height: SkySpacing.xs),
          Text(
            'Las opciones atenuadas contradicen lo que ya elegiste.',
            style: typography.caption.copyWith(color: colors.subtle),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: SkySpacing.xs),
          Text(
            errorText!,
            style: typography.caption.copyWith(color: colors.primaryRed),
          ),
        ],
      ],
    );
  }
}
