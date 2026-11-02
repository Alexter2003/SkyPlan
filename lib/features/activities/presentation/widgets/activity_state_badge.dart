import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/activity.dart';

/// Insignia de estado con ícono y texto. Los cuatro estados se distinguen
/// por color, ícono y etiqueta: pendiente, completada, cancelada por el
/// usuario y cancelada por el sistema (clima).
class ActivityStateBadge extends StatelessWidget {
  const ActivityStateBadge({super.key, required this.state});

  final ActivityState state;

  static String labelOf(ActivityState state) => switch (state) {
    ActivityState.planned => 'Pendiente',
    ActivityState.completed => 'Completada',
    ActivityState.cancelled => 'Cancelada por ti',
    ActivityState.cancelledBySystem => 'Cancelada por el clima',
  };

  static SkyIconType iconOf(ActivityState state) => switch (state) {
    ActivityState.planned => SkyIconType.clock,
    ActivityState.completed => SkyIconType.check,
    ActivityState.cancelled => SkyIconType.close,
    ActivityState.cancelledBySystem => SkyIconType.rain,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final (background, foreground) = switch (state) {
      ActivityState.planned => (colors.primaryBlue, colors.onAccent),
      ActivityState.completed => (
        colors.statusApt.background,
        colors.statusApt.foreground,
      ),
      ActivityState.cancelled => (colors.border, colors.ink),
      ActivityState.cancelledBySystem => (
        colors.statusPostpone.background,
        colors.statusPostpone.foreground,
      ),
    };

    return Container(
      key: ValueKey('state-${state.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkyIcon(iconOf(state), size: 14, color: foreground),
          const SizedBox(width: SkySpacing.xxs),
          Text(
            labelOf(state),
            style: typography.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
