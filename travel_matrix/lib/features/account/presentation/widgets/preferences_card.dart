import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/global_controllers/settings_controller.dart';
import 'package:travel_matrix/features/account/presentation/widgets/card_shell.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class PreferencesCard extends StatelessWidget {
  final AppLocalizations l10n;

  const PreferencesCard({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsController = context.watch<SettingsController>();

    return CardShell(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              l10n.systemPreferences,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.adminDarkMode),
            secondary: const Icon(Icons.dark_mode),
            value: settingsController.themeMode == ThemeMode.dark,
            onChanged: (_) => settingsController.toggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              '${l10n.languageLabel} (${settingsController.locale.languageCode.toUpperCase()})',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: settingsController.toggleLanguage,
          ),
        ],
      ),
    );
  }
}
