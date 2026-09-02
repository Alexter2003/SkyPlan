import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_spacing.dart';
import '../../tokens/sky_typography.dart';
import '../buttons/sky_button.dart';

/// Confirmation dialog (e.g. "¿Eliminar esta ubicación? También se
/// eliminarán sus actividades" — cascade delete, requirement 3.b).
class SkyDialog extends StatelessWidget {
  const SkyDialog({
    super.key,
    required this.title,
    this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancelar',
    this.destructive = false,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    required String confirmLabel,
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => SkyDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: context.skyShapes.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(SkySpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: typography.headline),
            if (message != null) ...[
              const SizedBox(height: SkySpacing.xs),
              Text(
                message!,
                style: typography.body.copyWith(color: colors.subtle),
              ),
            ],
            const SizedBox(height: SkySpacing.xl),
            Row(
              children: [
                Expanded(
                  child: SkyButton(
                    label: cancelLabel,
                    variant: SkyButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: SkySpacing.sm),
                Expanded(
                  child: SkyButton(
                    label: confirmLabel,
                    variant: destructive
                        ? SkyButtonVariant.danger
                        : SkyButtonVariant.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
