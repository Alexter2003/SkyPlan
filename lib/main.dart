import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/design_system/gallery/kit_gallery_screen.dart';
import 'core/design_system/logo/sky_logo.dart';
import 'core/design_system/theme/sky_theme.dart';
import 'core/design_system/theme/sky_theme_context.dart';

void main() {
  runApp(
    SkyThemeScope(controller: SkyThemeController(), child: const SkyPlanApp()),
  );
}

class SkyPlanApp extends StatelessWidget {
  const SkyPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = SkyThemeScope.of(context);

    return MaterialApp(
      title: 'SkyPlan',
      debugShowCheckedModeBanner: false,
      themeMode: themeController.mode,
      theme: SkyTheme.light,
      darkTheme: SkyTheme.dark,
      home: const HomePage(),
      routes: kDebugMode ? {'/kit': (_) => const KitGalleryScreen()} : const {},
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const SkyLogo(showTagline: false, markSize: 28)),
      body: Center(
        child: kDebugMode
            ? TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/kit'),
                child: const Text('Ver UI kit (/kit)'),
              )
            : const Text('Hello SkyPlan'),
      ),
    );
  }
}
