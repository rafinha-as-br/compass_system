import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/controllers/settings_controller.dart';
import 'package:travel_matrix/core/services/auth_service.dart';
import 'package:travel_matrix/app/gates/gate_auth.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Settings'),
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
              const Text('System Preferences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const Divider(),
              SwitchListTile(
                title: const Text('Admin Dark Mode'),
                secondary: const Icon(Icons.dark_mode),
                value: settingsController.themeMode == ThemeMode.dark,
                onChanged: (bool val) {
                  settingsController.toggleTheme();
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language (EN)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language toggle clicked')),
                  );
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
                label: const Text('Log Out of Matrix'),
                onPressed: () async {
                  await AuthService.instance.clearToken();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const GateAuth()),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
