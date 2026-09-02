import 'package:flutter/material.dart';

import '../tokens/sky_colors.dart';
import '../tokens/sky_shapes.dart';
import '../tokens/sky_typography.dart';

/// Builds the app's light and dark [ThemeData], wiring [SkyColors],
/// [SkyTypography] and [SkyShapes] as [ThemeExtension]s and aligning the
/// stock Material component themes (buttons, inputs) to the same tokens so
/// any raw Material widget used outside the kit still looks on-brand.
abstract final class SkyTheme {
  static ThemeData get light => _build(
    colors: SkyColors.light,
    typography: SkyTypography.light,
    brightness: Brightness.light,
  );

  static ThemeData get dark => _build(
    colors: SkyColors.dark,
    typography: SkyTypography.dark,
    brightness: Brightness.dark,
  );

  static ThemeData _build({
    required SkyColors colors,
    required SkyTypography typography,
    required Brightness brightness,
  }) {
    const shapes = SkyShapes.standard;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primaryBlue,
      brightness: brightness,
      primary: colors.primaryBlue,
      surface: colors.surface,
      error: colors.statusPostpone.background,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      fontFamily: typography.body.fontFamily,
      fontFamilyFallback: typography.body.fontFamilyFallback,
      extensions: [colors, typography, shapes],
      textTheme: TextTheme(
        headlineSmall: typography.headline,
        titleLarge: typography.title,
        bodyMedium: typography.body,
        labelLarge: typography.bodyStrong,
        labelSmall: typography.label,
        bodySmall: typography.caption,
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primaryRed,
          foregroundColor: colors.onAccent,
          shape: RoundedRectangleBorder(borderRadius: shapes.radiusMd),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: typography.bodyStrong,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: shapes.radiusMd,
          borderSide: BorderSide(color: colors.ink, width: shapes.borderThin),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: shapes.radiusMd,
          borderSide: BorderSide(color: colors.ink, width: shapes.borderThin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: shapes.radiusMd,
          borderSide: BorderSide(
            color: colors.primaryBlue,
            width: shapes.borderThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: shapes.radiusMd,
          borderSide: BorderSide(
            color: colors.statusPostpone.background,
            width: shapes.borderThin,
          ),
        ),
        labelStyle: typography.label,
        hintStyle: typography.body.copyWith(color: colors.subtle),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        side: BorderSide(color: colors.ink, width: shapes.borderThin),
        shape: RoundedRectangleBorder(borderRadius: shapes.radiusPill),
        labelStyle: typography.caption.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: shapes.radiusLg,
          side: BorderSide(color: colors.ink, width: shapes.borderThick),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: shapes.radiusLg),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.ink,
        contentTextStyle: typography.body.copyWith(color: colors.background),
        shape: RoundedRectangleBorder(borderRadius: shapes.radiusMd),
      ),
    );
  }
}
