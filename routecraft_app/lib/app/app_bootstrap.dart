import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/app.dart';
import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/app/router/app_router.dart';
import 'package:routecraft_app/app/splash_screen.dart';

/// Resolves the initial session (showing [SplashScreen] meanwhile) before
/// building the real app and its router — mirrors `travel_matrix`'s
/// `AppBootstrap`, adapted for RouteCraft's branded splash.
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();
    final settingsController = SettingsController();

    return FutureBuilder(
      future: authController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SplashScreen();
        }

        final appRouter = AppRouter(authController);

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsController),
            ChangeNotifierProvider.value(value: authController),
            Provider.value(value: appRouter),
          ],
          child: RouteCraftApp(router: appRouter.router),
        );
      },
    );
  }
}
