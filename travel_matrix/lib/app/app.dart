import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/controllers/settings_controller.dart';
import 'package:travel_matrix/app/gates/gate_splash.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

/// Root widget for the Travel Matrix application.
///
/// Configures theme, localization, and global providers.
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
            locale: settingsController.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const GateSplash(),
          );
        },
      ),
    );
  }
}
