import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/entities/activity.dart';

/// Indicador de probabilidad de realización (rubro 5.e): porcentaje, semáforo
/// de color, ícono y texto, para no depender solo del color. Sin pronóstico
/// (`probability == null`) muestra "Pendiente de validar", nunca un valor
/// inventado.
class ProbabilityIndicator extends StatelessWidget {
  const ProbabilityIndicator({super.key, required this.activity});

  final Activity activity;

  static String bandLabel(ProbabilityBand band) => switch (band) {
    ProbabilityBand.green => 'Alta',
    ProbabilityBand.yellow => 'Media',
    ProbabilityBand.red => 'Baja',
  };

  static SkyStatus statusOf(ProbabilityBand band) => switch (band) {
    ProbabilityBand.green => SkyStatus.apt,
    ProbabilityBand.yellow => SkyStatus.caution,
    ProbabilityBand.red => SkyStatus.postpone,
  };

  static SkyIconType iconOf(ProbabilityBand band) => switch (band) {
    ProbabilityBand.green => SkyIconType.check,
    ProbabilityBand.yellow => SkyIconType.warning,
    ProbabilityBand.red => SkyIconType.close,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final probability = activity.probability;
    final band = activity.probabilityBand;

    if (probability == null || band == null) {
      return _Pill(
        key: const ValueKey('probability-pending'),
        background: colors.surface,
        foreground: colors.subtle,
        borderColor: colors.border,
        icon: SkyIconType.clock,
        label: 'Pendiente de validar',
      );
    }

    final status = colors.statusColor(statusOf(band));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Pill(
          key: ValueKey('probability-${band.name}'),
          background: status.background,
          foreground: status.foreground,
          icon: iconOf(band),
          label: '$probability% · ${bandLabel(band)}',
        ),
        const SizedBox(height: SkySpacing.xxs),
        SizedBox(
          width: 140,
          child: SkyProgressBar(
            value: probability / 100,
            color: status.background,
          ),
        ),
        Text(
          'Probabilidad de realización',
          style: typography.caption.copyWith(color: colors.subtle),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.label,
    this.borderColor,
  });

  final Color background;
  final Color foreground;
  final Color? borderColor;
  final SkyIconType icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final typography = context.skyTypography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkyIcon(icon, size: 14, color: foreground),
          const SizedBox(width: SkySpacing.xxs),
          Text(
            label,
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
