import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/controllers/settings_controller.dart';
import 'package:travel_matrix/app/gates/gate_splash.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class TravelMatrixApp extends StatelessWidget {
  const TravelMatrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settingsController, _) {
          return MaterialApp(
            title: 'Travel Matrix',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsController.themeMode,
            home: const GateSplash(),
          );
        },
      ),
    );
  }
}
