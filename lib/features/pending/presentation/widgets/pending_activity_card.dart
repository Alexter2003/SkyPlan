import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../activities/domain/entities/activity.dart';
import '../../../activities/domain/services/activity_operations.dart';
import '../../../activities/presentation/widgets/activity_state_badge.dart';
import '../../../activities/presentation/widgets/probability_indicator.dart';
import '../../../activities/presentation/widgets/weather_condition_labels.dart';
import '../../../locations/presentation/widgets/date_format.dart';
import '../../domain/entities/upcoming_activity.dart';
import 'forecast_summary.dart';

/// Tarjeta de una actividad próxima: checkbox, ubicación, clima, estado y
/// probabilidad, con el menú de acciones válidas para su estado.
class PendingActivityCard extends StatelessWidget {
  const PendingActivityCard({
    super.key,
    required this.item,
    required this.busy,
    required this.onToggleComplete,
    required this.onOperation,
  });

  final UpcomingActivity item;
  final bool busy;
  final VoidCallback onToggleComplete;
  final ValueChanged<ActivityOperation> onOperation;

  static const _menuOperations = [
    ActivityOperation.cancel,
    ActivityOperation.reactivate,
    ActivityOperation.reschedule,
  ];

  static String operationLabel(ActivityOperation op) => switch (op) {
    ActivityOperation.cancel => 'Cancelar',
    ActivityOperation.reactivate => 'Reactivar',
    ActivityOperation.reschedule => 'Reagendar',
    ActivityOperation.complete => 'Completar',
    ActivityOperation.uncomplete => 'Desmarcar',
  };

  static SkyIconType operationIcon(ActivityOperation op) => switch (op) {
    ActivityOperation.cancel => SkyIconType.close,
    ActivityOperation.reactivate => SkyIconType.refresh,
    ActivityOperation.reschedule => SkyIconType.calendar,
    ActivityOperation.complete ||
    ActivityOperation.uncomplete => SkyIconType.check,
  };

  Future<void> _openMenu(BuildContext context) async {
    final activity = item.activity;
    final allowed = availableOperations(activity.state);
    final operations = _menuOperations.where(allowed.contains).toList();
    if (operations.isEmpty) return;

    final chosen = await SkyBottomSheet.show<ActivityOperation>(
      context,
      title: activity.name,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final op in operations) ...[
            SkyButton(
              label: operationLabel(op),
              variant: op == ActivityOperation.cancel
                  ? SkyButtonVariant.danger
                  : SkyButtonVariant.secondary,
              leading: SkyIcon(operationIcon(op), size: 20),
              expand: true,
              onPressed: () => Navigator.of(sheetContext).pop(op),
            ),
            const SizedBox(height: SkySpacing.xs),
          ],
        ],
      ),
    );
    if (chosen != null) onOperation(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final activity = item.activity;
    final done = activity.state == ActivityState.completed;
    final inactive = activity.isCancelled;
    final showProbability = !done;

    return SkyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (canToggleComplete(activity.state))
                busy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : SkyCheckbox(
                        key: const ValueKey('complete-checkbox'),
                        value: done,
                        onChanged: (_) => onToggleComplete(),
                      ),
              if (canToggleComplete(activity.state))
                const SizedBox(width: SkySpacing.xs),
              Expanded(
                child: Text(
                  activity.name,
                  style: typography.title.copyWith(
                    decoration: done || inactive
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: done || inactive ? colors.subtle : colors.ink,
                  ),
                ),
              ),
              if (!canToggleComplete(activity.state) && busy)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              else if (!busy)
                SkyIconButton(
                  icon: SkyIconType.moreVertical,
                  tooltip: 'Opciones',
                  onPressed: () => _openMenu(context),
                ),
            ],
          ),
          const SizedBox(height: SkySpacing.xxs),
          Row(
            children: [
              SkyIcon(SkyIconType.location, size: 16, color: colors.subtle),
              const SizedBox(width: SkySpacing.xs),
              Expanded(
                child: Text(
                  item.visit.name,
                  style: typography.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: SkySpacing.xxs),
          Row(
            children: [
              SkyIcon(SkyIconType.calendar, size: 16, color: colors.subtle),
              const SizedBox(width: SkySpacing.xs),
              Expanded(
                child: Text(
                  '${formatDate(activity.date)} · '
                  '${activity.startTime.format()} – ${activity.endTime.format()}',
                  style: typography.caption.copyWith(color: colors.subtle),
                ),
              ),
            ],
          ),
          const SizedBox(height: SkySpacing.xs),
          Wrap(
            spacing: SkySpacing.xs,
            runSpacing: SkySpacing.xs,
            children: [
              ActivityStateBadge(state: activity.state),
              SkyBadge(
                label: typeLabel(activity.type),
                background: activity.isOutdoor
                    ? colors.primaryBlue
                    : colors.primaryYellow,
                foreground: activity.isOutdoor ? colors.onAccent : colors.ink,
              ),
            ],
          ),
          if (activity.isCancelled && activity.cancelReason != null) ...[
            const SizedBox(height: SkySpacing.xs),
            Text(
              activity.cancelReason!,
              key: const ValueKey('cancel-reason'),
              style: typography.caption.copyWith(color: colors.subtle),
            ),
          ],
          const SizedBox(height: SkySpacing.xs),
          ForecastSummary(forecast: item.forecast),
          if (showProbability) ...[
            const SizedBox(height: SkySpacing.xs),
            ProbabilityIndicator(activity: activity),
          ],
        ],
      ),
    );
  }
}
