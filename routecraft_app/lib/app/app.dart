import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/app/gates/gate_splash.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

class RouteCraftApp extends StatelessWidget {
  const RouteCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          return MaterialApp(
            title: 'RouteCraft',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsController.themeMode,
            home: const GateSplash(),
          );
        },
      ),
    );
  }
}
