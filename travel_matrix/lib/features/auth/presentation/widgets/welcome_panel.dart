import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';

import '../../../../l10n/app_localizations.dart';

/// Initial right side panel
class WelcomePanel extends StatelessWidget {
  const WelcomePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.loginTitle,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.loginSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => Provider.of<LoginController>(context, listen: false).showLogin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: Text(
                AppLocalizations.of(context)!.loginLabel,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
