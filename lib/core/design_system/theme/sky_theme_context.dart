import 'package:flutter/material.dart';

/// Holds the app-wide theme mode (light/dark/system) and notifies listeners
/// on change. Deliberately plain `ChangeNotifier` — no Bloc/Riverpod/Provider
/// dependency — so it doesn't presuppose the state-management choice the
/// team still has to make for feature code (see `clean-architecture-flutter`
/// skill, "State management & DI"). Feature code that already sits on top
/// of a chosen state-management solution can still read/toggle this
/// controller through [SkyThemeScope].
class SkyThemeController extends ChangeNotifier {
  SkyThemeController({ThemeMode initial = ThemeMode.system}) : _mode = initial;

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void setMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  /// Toggles between light and dark, ignoring/leaving `system` mode.
  void toggle() {
    setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

/// Exposes a [SkyThemeController] to the widget tree via `InheritedNotifier`,
/// so any descendant can read the current mode or call [toggle]/[setMode]
/// without prop-drilling.
///
/// Wrap the app once, above `MaterialApp`:
///
/// ```dart
/// SkyThemeScope(
///   controller: SkyThemeController(),
///   child: Builder(
///     builder: (context) => MaterialApp(
///       themeMode: SkyThemeScope.of(context).mode,
///       theme: SkyTheme.light,
///       darkTheme: SkyTheme.dark,
///       home: const HomeScreen(),
///     ),
///   ),
/// )
/// ```
class SkyThemeScope extends InheritedNotifier<SkyThemeController> {
  const SkyThemeScope({
    super.key,
    required SkyThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static SkyThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SkyThemeScope>();
    assert(scope != null, 'No SkyThemeScope found in context');
    return scope!.notifier!;
  }
}
