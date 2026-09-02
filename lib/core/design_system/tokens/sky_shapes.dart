import 'package:flutter/material.dart';

/// SkyPlan's corner-radius and border-weight scale.
///
/// "Redondeado, lo mínimo elegante": small, consistent radii — never the
/// sharp Bauhaus corner, never a fully pill-shaped card. Pills are reserved
/// for chips/badges/status pieces (see [pill]).
@immutable
class SkyShapes extends ThemeExtension<SkyShapes> {
  const SkyShapes({
    this.xs = 6,
    this.sm = 8,
    this.md = 12,
    this.lg = 18,
    this.pill = 999,
    this.borderThin = 2,
    this.borderThick = 3,
  });

  /// Swatches, small icon containers.
  final double xs;

  /// Logo mark corner, tags.
  final double sm;

  /// Buttons, inputs, segmented control.
  final double md;

  /// Cards, dialogs, sheets.
  final double lg;

  /// Chips, badges, status pills.
  final double pill;

  /// Hairline component border (dividers, unfocused inputs).
  final double borderThin;

  /// Thick Bauhaus border (cards, focused inputs, segmented control).
  final double borderThick;

  BorderRadius get radiusXs => BorderRadius.circular(xs);
  BorderRadius get radiusSm => BorderRadius.circular(sm);
  BorderRadius get radiusMd => BorderRadius.circular(md);
  BorderRadius get radiusLg => BorderRadius.circular(lg);
  BorderRadius get radiusPill => BorderRadius.circular(pill);

  static const standard = SkyShapes();

  @override
  SkyShapes copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? pill,
    double? borderThin,
    double? borderThick,
  }) {
    return SkyShapes(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      pill: pill ?? this.pill,
      borderThin: borderThin ?? this.borderThin,
      borderThick: borderThick ?? this.borderThick,
    );
  }

  @override
  SkyShapes lerp(ThemeExtension<SkyShapes>? other, double t) {
    if (other is! SkyShapes) return this;
    return SkyShapes(
      xs: lerpDouble(xs, other.xs, t),
      sm: lerpDouble(sm, other.sm, t),
      md: lerpDouble(md, other.md, t),
      lg: lerpDouble(lg, other.lg, t),
      pill: lerpDouble(pill, other.pill, t),
      borderThin: lerpDouble(borderThin, other.borderThin, t),
      borderThick: lerpDouble(borderThick, other.borderThick, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

extension SkyShapesContext on BuildContext {
  SkyShapes get skyShapes => Theme.of(this).extension<SkyShapes>()!;
}
