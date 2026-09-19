import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/design_system/gallery/kit_gallery_screen.dart';
import 'core/design_system/theme/sky_theme.dart';
import 'core/design_system/theme/sky_theme_context.dart';
import 'core/di/app_providers.dart';
import 'core/routing/app_routes.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

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

    return AppProviders(
      child: MaterialApp(
        title: 'SkyPlan',
        debugShowCheckedModeBanner: false,
        themeMode: themeController.mode,
        theme: SkyTheme.light,
        darkTheme: SkyTheme.dark,
        home: const AuthGate(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
        routes: kDebugMode
            ? {'/kit': (_) => const KitGalleryScreen()}
            : const {},
      ),
    );
  }
}
