import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_shapes.dart';
import '../../tokens/sky_spacing.dart';
import '../../tokens/sky_typography.dart';

/// Themed modal bottom sheet — used for filters (proximidad de fecha,
/// ubicación, probabilidad de realización — requirement 5.b) and quick
/// actions (reagendar, marcar como finalizada).
abstract final class SkyBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget Function(BuildContext) builder,
  }) {
    final colors = context.skyColors;
    final typography = context.skyTypography;
    final shapes = context.skyShapes;

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(shapes.lg),
          topRight: Radius.circular(shapes.lg),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SkySpacing.lg,
            SkySpacing.sm,
            SkySpacing.lg,
            SkySpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: SkySpacing.md),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(title, style: typography.headline),
              const SizedBox(height: SkySpacing.md),
              builder(sheetContext),
            ],
          ),
        ),
      ),
    );
  }
}
