import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

/// Branded loading screen shown by [AppBootstrap] while [AuthController]
/// resolves the initial session. It carries its own [MaterialApp] because it
/// renders before the app's real router (and its `MaterialApp.router`) exist.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _SplashBody(),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: TravelAppColors.primaryDark,
                child: Image.asset('assets/images/logo.png', width: 400),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.appTitle,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
