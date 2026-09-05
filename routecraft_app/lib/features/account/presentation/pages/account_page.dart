import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Account & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'John Doe', // Mocked user info
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'john@example.com',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 48),
          const Text('Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Divider(),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: settingsController.themeMode == ThemeMode.dark,
            onChanged: (bool val) {
              settingsController.toggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('Language (${settingsController.locale.languageCode.toUpperCase()})'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              settingsController.toggleLanguage();
            },
          ),
          const SizedBox(height: 32),
          AppButton(
            variant: AppButtonVariant.danger,
            icon: const Icon(Icons.logout),
            // AppRouter's redirect leaves the private area once
            // AuthController.logout() notifies isAuthenticated == false.
            onPressed: () => context.read<AuthController>().logout(),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
