/// SkyPlan's spacing scale, on a 4px grid. Plain static constants (not a
/// [ThemeExtension]) since spacing doesn't vary between light and dark.
///
/// Use these instead of raw `SizedBox`/`EdgeInsets` numbers so every screen
/// shares the same rhythm.
abstract final class SkySpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}
