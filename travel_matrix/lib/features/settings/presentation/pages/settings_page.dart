import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/settings_controller.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appearanceSection,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          RadioGroup(
                              onChanged: (ThemeMode? value) {
                                if (value != null) {
                                  settingsController.setThemeMode(value);
                                }
                              },
                              groupValue: settingsController.themeMode,
                              child: Column(
                                children: [
                                  RadioListTile<ThemeMode>(
                                    title: Text(l10n.themeLight),
                                    value: ThemeMode.light,
                                  ),
                                  RadioListTile<ThemeMode>(
                                    title: Text(l10n.themeDark),
                                    value: ThemeMode.dark,
                                  ),
                                  RadioListTile<ThemeMode>(
                                    title: Text(l10n.themeSystem),
                                    value: ThemeMode.system,
                                  ),
                                ],
                              )
                          ),


                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.languageSection,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RadioGroup(
                              onChanged: (String? value) {
                                if (value != null) {
                                  settingsController.setLocale(Locale(value));
                                }
                              },
                              groupValue: settingsController.locale.languageCode,
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    title: const Text('Português (Brasil)'),
                                    value: 'pt',

                                  ),
                                  RadioListTile<String>(
                                    title: const Text('English'),
                                    value: 'en',
                                  ),
                                ],
                              )
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
