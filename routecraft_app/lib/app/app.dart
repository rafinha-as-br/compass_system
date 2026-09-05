import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

/// Root widget for the RouteCraft application.
///
/// Configures theme, localization, and the router. Built by [AppBootstrap]
/// once the initial session is resolved.
class RouteCraftApp extends StatelessWidget {
  final GoRouter router;

  const RouteCraftApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settingsController, _) {
        return MaterialApp.router(
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
          routerConfig: router,
        );
      },
    );
  }
}
