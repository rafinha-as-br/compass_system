import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class LogoutButton extends StatelessWidget {
  final AppLocalizations l10n;

  const LogoutButton({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      icon: const Icon(Icons.logout),
      label: Text(l10n.logOutOfMatrix),
      onPressed: () => context.read<AuthController>().logout(),
    );
  }
}
