import 'package:flutter/animation.dart';

/// SkyPlan's motion tokens: durations and curves shared by every animated
/// component and page transition.
abstract final class SkyMotion {
  /// Micro-interactions: press states, chip selection.
  static const Duration fast = Duration(milliseconds: 150);

  /// Default transition: theme toggle, expand/collapse, dialogs.
  static const Duration base = Duration(milliseconds: 250);

  /// Page transitions, larger layout changes.
  static const Duration slow = Duration(milliseconds: 350);

  /// Default easing — matches the canvas's `ease` reveal for color/theme
  /// transitions.
  static const Curve standard = Curves.easeOutCubic;

  /// Emphasized easing for page-level transitions.
  static const Curve emphasized = Curves.easeInOutCubic;
}
