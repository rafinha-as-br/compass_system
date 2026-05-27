import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/global_controllers/settings_controller.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.agentSettings),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const CircleAvatar(
                radius: 50,
                child: Icon(Icons.admin_panel_settings, size: 50),
              ),
              const SizedBox(height: 16),
              const Text(
                'Agent Smith', // Mocked user info
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'smith@matrix.com',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              Text(l10n.systemPreferences, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Divider(),
              SwitchListTile(
                title: Text(l10n.adminDarkMode),
                secondary: const Icon(Icons.dark_mode),
                value: settingsController.themeMode == ThemeMode.dark,
                onChanged: (bool val) {
                  settingsController.toggleTheme();
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text('${l10n.languageLabel} (${settingsController.locale.languageCode.toUpperCase()})'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  settingsController.toggleLanguage();
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: Text(l10n.logOutOfMatrix),
                onPressed: () {
                  context.read<AuthController>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

