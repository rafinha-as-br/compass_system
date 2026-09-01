import 'dart:async';

import 'package:flutter/material.dart';
import 'package:routecraft_app/app/gates/gate_auth.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

class GateSplash extends StatefulWidget {
  const GateSplash({super.key});

  @override
  State<GateSplash> createState() => _GateSplashState();
}

class _GateSplashState extends State<GateSplash> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    // Artificial delay for splash screen.
    _navigationTimer = Timer(const Duration(seconds: 2), _goToAuthGate);
  }

  void _goToAuthGate() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GateAuth()),
      );
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// logo
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
