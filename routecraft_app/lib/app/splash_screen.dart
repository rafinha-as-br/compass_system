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
    final l10n = AppLocalizations.of(context)!;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: TravelAppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('✦', style: TextStyle(fontSize: 48, color: onPrimary)),
            const SizedBox(height: 16),
            Text(
              l10n.appTitle,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: onPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.appBrandSubtitle,
              style: TextStyle(fontSize: 14, color: onPrimary.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 48),
            Text(
              l10n.splashCheckingSession,
              style: TextStyle(fontSize: 14, color: onPrimary.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(color: onPrimary),
          ],
        ),
      ),
    );
  }
}
