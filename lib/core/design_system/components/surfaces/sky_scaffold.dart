import 'package:flutter/material.dart';

import '../../tokens/sky_colors.dart';
import 'sky_background.dart';

/// Standard screen shell: [Scaffold] over [SkyBackground], so every screen
/// gets the same textured background and app bar/body spacing without
/// repeating boilerplate.
class SkyScaffold extends StatelessWidget {
  const SkyScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.bottomNavigationBar,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 24),
    this.showGrid = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final EdgeInsets padding;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sólido (no transparente): cubre también el área detrás del
      // appBar, que SkyBackground no alcanza a pintar.
      backgroundColor: context.skyColors.background,
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SkyBackground(
        showGrid: showGrid,
        child: SafeArea(
          child: Padding(padding: padding, child: body),
        ),
      ),
    );
  }
}
