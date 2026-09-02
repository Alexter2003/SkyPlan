import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import '../../tokens/sky_typography.dart';

/// Shows a themed snackbar. Uses the `SnackBarTheme` registered by
/// [SkyTheme] for color/shape, so this is just a convenience constructor —
/// call it instead of building a raw [SnackBar].
abstract final class SkySnackbar {
  static void show(
    BuildContext context,
    String message, {
    SkySnackbarTone tone = SkySnackbarTone.neutral,
  }) {
    final colors = context.skyColors;
    final typography = context.skyTypography;

    final background = switch (tone) {
      SkySnackbarTone.neutral => colors.ink,
      SkySnackbarTone.success => colors.statusApt.background,
      SkySnackbarTone.error => colors.statusPostpone.background,
    };
    final foreground = switch (tone) {
      SkySnackbarTone.neutral => colors.background,
      SkySnackbarTone.success => colors.statusApt.foreground,
      SkySnackbarTone.error => colors.statusPostpone.foreground,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: background,
        content: Text(
          message,
          style: typography.body.copyWith(color: foreground),
        ),
      ),
    );
  }
}

enum SkySnackbarTone { neutral, success, error }
