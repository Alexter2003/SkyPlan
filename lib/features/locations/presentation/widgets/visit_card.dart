import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/visit.dart';
import 'coordinates_label.dart';
import 'date_format.dart';
import 'weather_condition_mapper.dart';

enum VisitAction { edit, complete, cancel, delete }

/// Tarjeta de una ubicación en el listado.
class VisitCard extends StatelessWidget {
  const VisitCard({
    super.key,
    required this.visit,
    required this.busy,
    required this.onAction,
    this.today,
  });

  final Visit visit;
  final bool busy;
  final ValueChanged<VisitAction> onAction;

  /// Fecha de referencia para habilitar "finalizar" (inyectable en tests).
  final DateTime? today;

  List<VisitAction> get _availableActions {
    final reference = today ?? DateTime.now();
    return [
      if (visit.isEditable) VisitAction.edit,
      if (visit.canComplete(reference)) VisitAction.complete,
      if (visit.canCancel) VisitAction.cancel,
      VisitAction.delete,
    ];
  }

  Future<void> _openMenu(BuildContext context) async {
    final action = await SkyBottomSheet.show<VisitAction>(
      context,
      title: visit.name,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final action in _availableActions) ...[
            SkyButton(
              label: _labelOf(action),
              variant: action == VisitAction.delete
                  ? SkyButtonVariant.danger
                  : SkyButtonVariant.secondary,
              leading: SkyIcon(_iconOf(action), size: 20),
              expand: true,
              onPressed: () => Navigator.of(sheetContext).pop(action),
            ),
            const SizedBox(height: SkySpacing.xs),
          ],
        ],
      ),
    );
    if (action != null) onAction(action);
  }

  static String _labelOf(VisitAction action) => switch (action) {
    VisitAction.edit => 'Editar',
    VisitAction.complete => 'Marcar como finalizada',
    VisitAction.cancel => 'Cancelar visita',
    VisitAction.delete => 'Eliminar',
  };

  static SkyIconType _iconOf(VisitAction action) => switch (action) {
    VisitAction.edit => SkyIconType.edit,
    VisitAction.complete => SkyIconType.check,
    VisitAction.cancel => SkyIconType.close,
    VisitAction.delete => SkyIconType.trash,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return SkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: SkySpacing.xs),
                  child: Text(visit.name, style: typography.title),
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                )
              else
                SkyIconButton(
                  icon: SkyIconType.moreVertical,
                  tooltip: 'Opciones',
                  onPressed: () => _openMenu(context),
                ),
            ],
          ),
          if (visit.status != VisitStatus.planned) ...[
            SkyBadge(
              label: visit.status == VisitStatus.completed
                  ? 'Finalizada'
                  : 'Cancelada',
              background: visit.status == VisitStatus.completed
                  ? colors.statusApt.background
                  : colors.statusPostpone.background,
              foreground: visit.status == VisitStatus.completed
                  ? colors.statusApt.foreground
                  : colors.statusPostpone.foreground,
            ),
            const SizedBox(height: SkySpacing.xs),
          ],
          Row(
            children: [
              SkyIcon(SkyIconType.calendar, size: 18, color: colors.subtle),
              const SizedBox(width: SkySpacing.xs),
              Text(formatDate(visit.date), style: typography.body),
            ],
          ),
          const SizedBox(height: SkySpacing.xxs),
          Row(
            children: [
              SkyIcon(SkyIconType.location, size: 18, color: colors.subtle),
              const SizedBox(width: SkySpacing.xs),
              CoordinatesLabel(
                point: visit.point,
                style: typography.caption.copyWith(color: colors.subtle),
              ),
            ],
          ),
          const SizedBox(height: SkySpacing.xs),
          const SkyDivider(),
          const SizedBox(height: SkySpacing.xs),
          _WeatherSection(visit: visit),
        ],
      ),
    );
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({required this.visit});

  final Visit visit;

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final weather = visit.weather;

    if (weather == null) {
      return Row(
        children: [
          const SkyBadge(label: 'Clima pendiente'),
          const SizedBox(width: SkySpacing.xs),
          Expanded(
            child: Text(
              'Se cargará cuando falten 10 días o menos',
              style: typography.caption.copyWith(color: colors.subtle),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        SkyWeatherChip(
          temperatureCelsius: weather.temperature.round(),
          condition: conditionFor(weather),
        ),
        const SizedBox(width: SkySpacing.sm),
        Expanded(
          child: Text(
            'Humedad ${weather.humidity.round()}% · '
            'Lluvia ${weather.precipitation.toStringAsFixed(1)} mm',
            style: typography.caption.copyWith(color: colors.subtle),
          ),
        ),
      ],
    );
  }
}
