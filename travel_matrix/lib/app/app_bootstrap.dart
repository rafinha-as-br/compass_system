import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'global_controllers/settings_controller.dart';
import 'travel_matrix_app.dart';

/// Initialization point for global providers
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsController()),
        ],
      child: TravelMatrixApp(),
    );
  }
}
