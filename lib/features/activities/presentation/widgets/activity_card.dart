import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/activity.dart';
import 'weather_condition_labels.dart';

enum ActivityAction { edit, delete }

/// Tarjeta de una actividad: horario, tipo, viabilidad y condiciones.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.busy,
    required this.onAction,
  });

  final Activity activity;
  final bool busy;
  final ValueChanged<ActivityAction> onAction;

  Future<void> _openMenu(BuildContext context) async {
    final action = await SkyBottomSheet.show<ActivityAction>(
      context,
      title: activity.name,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (activity.isEditable) ...[
            SkyButton(
              label: 'Editar',
              variant: SkyButtonVariant.secondary,
              leading: const SkyIcon(SkyIconType.edit, size: 20),
              expand: true,
              onPressed: () =>
                  Navigator.of(sheetContext).pop(ActivityAction.edit),
            ),
            const SizedBox(height: SkySpacing.xs),
          ],
          SkyButton(
            label: 'Eliminar',
            variant: SkyButtonVariant.danger,
            leading: const SkyIcon(SkyIconType.trash, size: 20),
            expand: true,
            onPressed: () =>
                Navigator.of(sheetContext).pop(ActivityAction.delete),
          ),
          const SizedBox(height: SkySpacing.xs),
        ],
      ),
    );
    if (action != null) onAction(action);
  }

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
                  child: Text(activity.name, style: typography.title),
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
          Row(
            children: [
              SkyIcon(SkyIconType.clock, size: 18, color: colors.subtle),
              const SizedBox(width: SkySpacing.xs),
              Text(
                '${activity.startTime.format()} – ${activity.endTime.format()}',
                style: typography.body,
              ),
            ],
          ),
          if (activity.description.isNotEmpty) ...[
            const SizedBox(height: SkySpacing.xxs),
            Text(
              activity.description,
              style: typography.caption.copyWith(color: colors.subtle),
            ),
          ],
          const SizedBox(height: SkySpacing.xs),
          Wrap(
            spacing: SkySpacing.xs,
            runSpacing: SkySpacing.xs,
            children: [
              SkyBadge(
                label: typeLabel(activity.type),
                background: activity.isOutdoor
                    ? colors.primaryBlue
                    : colors.primaryYellow,
                foreground: activity.isOutdoor ? colors.onAccent : colors.ink,
              ),
              ..._statusBadges(colors),
            ],
          ),
          if (activity.conditions.isNotEmpty) ...[
            const SizedBox(height: SkySpacing.xs),
            Wrap(
              spacing: SkySpacing.xs,
              runSpacing: SkySpacing.xs,
              children: [
                for (final c in activity.conditions)
                  SkyChip(label: conditionLabel(c.name)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _statusBadges(SkyColors colors) {
    return [
      if (activity.state == ActivityState.completed)
        SkyBadge(
          label: 'Completada',
          background: colors.statusApt.background,
          foreground: colors.statusApt.foreground,
        ),
      if (activity.state == ActivityState.cancelled)
        SkyBadge(
          label: 'Cancelada',
          background: colors.statusPostpone.background,
          foreground: colors.statusPostpone.foreground,
        ),
      if (activity.isOutdoor && activity.isEditable)
        switch (activity.isViable) {
          true => SkyBadge(
            label: 'Viable',
            background: colors.statusApt.background,
            foreground: colors.statusApt.foreground,
          ),
          false => SkyBadge(
            label: 'No viable por el clima',
            background: colors.statusPostpone.background,
            foreground: colors.statusPostpone.foreground,
          ),
          null => SkyBadge(
            label: 'Pendiente de validar',
            background: colors.statusCaution.background,
            foreground: colors.statusCaution.foreground,
          ),
        },
    ];
  }
}
