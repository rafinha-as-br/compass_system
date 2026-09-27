import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/app.dart';
import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/app/global_controllers/travel_sync_status_controller.dart';
import 'package:routecraft_app/app/router/app_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/app/splash_screen.dart';
import 'package:routecraft_app/core/services/push_service.dart';

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

        // A notification tap that launched the app cold can't navigate from
        // inside PushService — AppRouter doesn't exist yet at that point — so
        // it's consumed here instead, once the router is actually built
        // (CPS-148).
        final pendingTravelId = PushService.consumePendingLaunchTravelId();
        if (pendingTravelId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            appRouter.router.go('${AppRoutes.homeFollowTravel}?${AppRoutes.travelIdQuery(pendingTravelId)}');
          });
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: settingsController),
            ChangeNotifierProvider.value(value: authController),
            ChangeNotifierProvider(create: (_) => TravelSyncStatusController()),
            Provider.value(value: appRouter),
          ],
          child: RouteCraftApp(router: appRouter.router),
        );
      },
    );
  }
}
