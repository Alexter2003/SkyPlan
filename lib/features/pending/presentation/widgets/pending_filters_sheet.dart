import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../activities/presentation/widgets/activity_state_badge.dart';
import '../../../locations/domain/entities/visit.dart';
import '../../domain/entities/upcoming_filters.dart';

/// Rangos de probabilidad predefinidos, alineados con el semáforo.
enum ProbabilityRange {
  any('Cualquiera', null, null),
  high('Alta (70+)', 70, 100),
  medium('Media (40–69)', 40, 69),
  low('Baja (<40)', 0, 39);

  const ProbabilityRange(this.label, this.min, this.max);

  final String label;
  final int? min;
  final int? max;

  static ProbabilityRange of(UpcomingFilters f) {
    for (final range in values) {
      if (range.min == f.probabilityMin && range.max == f.probabilityMax) {
        return range;
      }
    }
    return any;
  }
}

/// Opciones de proximidad de fecha: hoy hasta hoy + N días.
const proximityOptions = <(String, int?)>[
  ('Todas', null),
  ('7 días', 7),
  ('30 días', 30),
];

/// Hoja de filtros: proximidad, ubicación, probabilidad, estado y orden.
/// Devuelve los filtros elegidos o `null` si se cierra sin aplicar.
Future<UpcomingFilters?> showPendingFiltersSheet(
  BuildContext context, {
  required UpcomingFilters current,
  required List<Visit> visits,
}) {
  return SkyBottomSheet.show<UpcomingFilters>(
    context,
    title: 'Filtros',
    builder: (_) => _FiltersForm(current: current, visits: visits),
  );
}

class _FiltersForm extends StatefulWidget {
  const _FiltersForm({required this.current, required this.visits});

  final UpcomingFilters current;
  final List<Visit> visits;

  @override
  State<_FiltersForm> createState() => _FiltersFormState();
}

class _FiltersFormState extends State<_FiltersForm> {
  late UpcomingFilters _filters = widget.current;

  @override
  Widget build(BuildContext context) {
    final typography = context.skyTypography;
    final colors = context.skyColors;
    final range = ProbabilityRange.of(_filters);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Proximidad de fecha', style: typography.label),
          const SizedBox(height: SkySpacing.xs),
          Wrap(
            spacing: SkySpacing.xs,
            runSpacing: SkySpacing.xs,
            children: [
              for (final (label, days) in proximityOptions)
                SkyChip(
                  label: label,
                  selected: _filters.days == days,
                  onSelected: (_) =>
                      setState(() => _filters = _filters.copyWith(days: days)),
                ),
            ],
          ),
          if (widget.visits.isNotEmpty) ...[
            const SizedBox(height: SkySpacing.md),
            SkyDropdown<int?>(
              label: 'Ubicación',
              value: _filters.visitId,
              items: [null, ...widget.visits.map((v) => v.id)],
              itemLabel: (id) => id == null
                  ? 'Todas las ubicaciones'
                  : widget.visits.firstWhere((v) => v.id == id).name,
              onChanged: (id) =>
                  setState(() => _filters = _filters.copyWith(visitId: id)),
            ),
          ],
          const SizedBox(height: SkySpacing.md),
          Text('Probabilidad de realización', style: typography.label),
          const SizedBox(height: SkySpacing.xs),
          Wrap(
            spacing: SkySpacing.xs,
            runSpacing: SkySpacing.xs,
            children: [
              for (final option in ProbabilityRange.values)
                SkyChip(
                  label: option.label,
                  selected: range == option,
                  onSelected: (_) => setState(
                    () => _filters = _filters.copyWith(
                      probabilityMin: option.min,
                      probabilityMax: option.max,
                    ),
                  ),
                ),
            ],
          ),
          if (range != ProbabilityRange.any)
            Padding(
              padding: const EdgeInsets.only(top: SkySpacing.xxs),
              child: Text(
                'Las actividades sin pronóstico no se muestran con este '
                'filtro.',
                style: typography.caption.copyWith(color: colors.subtle),
              ),
            ),
          const SizedBox(height: SkySpacing.md),
          Text('Estado', style: typography.label),
          const SizedBox(height: SkySpacing.xs),
          Wrap(
            spacing: SkySpacing.xs,
            runSpacing: SkySpacing.xs,
            children: [
              SkyChip(
                label: 'Todos',
                selected: _filters.state == null,
                onSelected: (_) =>
                    setState(() => _filters = _filters.copyWith(state: null)),
              ),
              for (final state in ActivityState.values)
                SkyChip(
                  label: ActivityStateBadge.labelOf(state),
                  selected: _filters.state == state,
                  onSelected: (_) => setState(
                    () => _filters = _filters.copyWith(state: state),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SkySpacing.md),
          Text('Ordenar por', style: typography.label),
          const SizedBox(height: SkySpacing.xs),
          SkySegmentedControl<UpcomingSort>(
            value: _filters.sortBy,
            options: UpcomingSort.values,
            optionLabel: (s) =>
                s == UpcomingSort.date ? 'Fecha' : 'Probabilidad',
            onChanged: (s) =>
                setState(() => _filters = _filters.copyWith(sortBy: s)),
          ),
          const SizedBox(height: SkySpacing.lg),
          SkyButton(
            label: 'Aplicar filtros',
            expand: true,
            onPressed: () => Navigator.of(context).pop(_filters),
          ),
          const SizedBox(height: SkySpacing.xs),
          SkyButton(
            label: 'Limpiar filtros',
            variant: SkyButtonVariant.ghost,
            expand: true,
            onPressed: () => Navigator.of(context).pop(_filters.cleared()),
          ),
        ],
      ),
    );
  }
}
