import 'package:flutter/material.dart';

/// Status a weather-conditioned activity can be in, per requirement 5.e:
/// "Indicador de probabilidad de realización... según el tipo de actividad
/// y el clima a presentarse."
enum SkyStatus { apt, caution, postpone }

/// One status color pair: a background and the text/icon color that reads
/// on top of it.
@immutable
class SkyStatusColor {
  const SkyStatusColor({required this.background, required this.foreground});

  final Color background;
  final Color foreground;
}

/// SkyPlan's color tokens — Paleta 2 "Cian neblina" (Bauhaus direction).
///
/// This is the ONLY place brand/status colors are defined. Widgets must read
/// colors from [SkyColors] (via `Theme.of(context).extension<SkyColors>()`
/// or the `context.skyColors` shortcut) instead of hard-coding a [Color] —
/// see the `flutter-design-system` skill for the rule and the reasoning.
@immutable
class SkyColors extends ThemeExtension<SkyColors> {
  const SkyColors({
    required this.background,
    required this.surface,
    required this.ink,
    required this.subtle,
    required this.border,
    required this.primaryRed,
    required this.primaryBlue,
    required this.primaryYellow,
    required this.onAccent,
    required this.statusApt,
    required this.statusCaution,
    required this.statusPostpone,
  });

  /// Page/scaffold background.
  final Color background;

  /// Card/input/elevated surface background.
  final Color surface;

  /// Primary text, icons, and the thick Bauhaus borders.
  final Color ink;

  /// Secondary text — labels, captions, placeholders.
  final Color subtle;

  /// Hairline dividers (lighter than [ink], which is reserved for the
  /// thick 2–3px component borders).
  final Color border;

  /// Brand red — danger actions, "posponer" status.
  final Color primaryRed;

  /// Brand blue — informational accents (e.g. weather chip).
  final Color primaryBlue;

  /// Brand yellow — highlight accents, sun motif. Rarely used as a fill
  /// behind text because contrast is poor; pair with [ink] for text.
  final Color primaryYellow;

  /// Text/icon color to use on top of a primary-colored fill.
  final Color onAccent;

  final SkyStatusColor statusApt;
  final SkyStatusColor statusCaution;
  final SkyStatusColor statusPostpone;

  /// Looks up the color pair for a [SkyStatus].
  SkyStatusColor statusColor(SkyStatus status) => switch (status) {
    SkyStatus.apt => statusApt,
    SkyStatus.caution => statusCaution,
    SkyStatus.postpone => statusPostpone,
  };

  static const light = SkyColors(
    background: Color(0xFFDCEAF0),
    surface: Color(0xFFF1F8FA),
    ink: Color(0xFF132226),
    subtle: Color(0xFF5C767C),
    border: Color(0x1A132226),
    primaryRed: Color(0xFFD6402A),
    primaryBlue: Color(0xFF1B4E9B),
    primaryYellow: Color(0xFFF2B705),
    onAccent: Color(0xFFF1F8FA),
    statusApt: SkyStatusColor(
      background: Color(0xFF1E7A46),
      foreground: Color(0xFFF1F8FA),
    ),
    statusCaution: SkyStatusColor(
      background: Color(0xFFB98900),
      foreground: Color(0xFF132226),
    ),
    statusPostpone: SkyStatusColor(
      background: Color(0xFFD6402A),
      foreground: Color(0xFFF1F8FA),
    ),
  );

  static const dark = SkyColors(
    background: Color(0xFF0E1A1D),
    surface: Color(0xFF152528),
    ink: Color(0xFFE7F3F5),
    subtle: Color(0xFF9CBAC0),
    border: Color(0x1FE7F3F5),
    primaryRed: Color(0xFFE85B42),
    primaryBlue: Color(0xFF5B8FD9),
    primaryYellow: Color(0xFFF2B705),
    onAccent: Color(0xFF0E1A1D),
    statusApt: SkyStatusColor(
      background: Color(0xFF3FA86B),
      foreground: Color(0xFF0E1A12),
    ),
    statusCaution: SkyStatusColor(
      background: Color(0xFFE0AC33),
      foreground: Color(0xFF1D1400),
    ),
    statusPostpone: SkyStatusColor(
      background: Color(0xFFE85B42),
      foreground: Color(0xFF1D0B06),
    ),
  );

  @override
  SkyColors copyWith({
    Color? background,
    Color? surface,
    Color? ink,
    Color? subtle,
    Color? border,
    Color? primaryRed,
    Color? primaryBlue,
    Color? primaryYellow,
    Color? onAccent,
    SkyStatusColor? statusApt,
    SkyStatusColor? statusCaution,
    SkyStatusColor? statusPostpone,
  }) {
    return SkyColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      ink: ink ?? this.ink,
      subtle: subtle ?? this.subtle,
      border: border ?? this.border,
      primaryRed: primaryRed ?? this.primaryRed,
      primaryBlue: primaryBlue ?? this.primaryBlue,
      primaryYellow: primaryYellow ?? this.primaryYellow,
      onAccent: onAccent ?? this.onAccent,
      statusApt: statusApt ?? this.statusApt,
      statusCaution: statusCaution ?? this.statusCaution,
      statusPostpone: statusPostpone ?? this.statusPostpone,
    );
  }

  @override
  SkyColors lerp(ThemeExtension<SkyColors>? other, double t) {
    if (other is! SkyColors) return this;
    return SkyColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      primaryRed: Color.lerp(primaryRed, other.primaryRed, t)!,
      primaryBlue: Color.lerp(primaryBlue, other.primaryBlue, t)!,
      primaryYellow: Color.lerp(primaryYellow, other.primaryYellow, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      statusApt: SkyStatusColor(
        background: Color.lerp(
          statusApt.background,
          other.statusApt.background,
          t,
        )!,
        foreground: Color.lerp(
          statusApt.foreground,
          other.statusApt.foreground,
          t,
        )!,
      ),
      statusCaution: SkyStatusColor(
        background: Color.lerp(
          statusCaution.background,
          other.statusCaution.background,
          t,
        )!,
        foreground: Color.lerp(
          statusCaution.foreground,
          other.statusCaution.foreground,
          t,
        )!,
      ),
      statusPostpone: SkyStatusColor(
        background: Color.lerp(
          statusPostpone.background,
          other.statusPostpone.background,
          t,
        )!,
        foreground: Color.lerp(
          statusPostpone.foreground,
          other.statusPostpone.foreground,
          t,
        )!,
      ),
    );
  }
}

/// Shortcut so widgets can write `context.skyColors.ink` instead of the full
/// `Theme.of(context).extension<SkyColors>()!` lookup.
extension SkyColorsContext on BuildContext {
  SkyColors get skyColors => Theme.of(this).extension<SkyColors>()!;
}
