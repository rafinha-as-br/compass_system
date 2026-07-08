import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/router/app_router.dart';
import 'global_controllers/settings_controller.dart';
import 'travel_matrix_app.dart';

/// Initialization point for global providers
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController();

    return FutureBuilder(
      future: authController.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final appRouter = AppRouter(authController);

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsController()),
            ChangeNotifierProvider.value(value: authController),
            Provider.value(value: appRouter),
          ],
          child: TravelMatrixApp(router: appRouter.router),
        );
      },
    );
  }
}
