import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/app/gates/gate_splash.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

/// Root widget for the RouteCraft application.
///
/// Configures theme, localization, and global providers.
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
