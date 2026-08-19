import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/global_controllers/settings_controller.dart';
import 'package:travel_matrix/features/account/presentation/controllers/account_controller.dart';
import 'package:travel_matrix/features/account/presentation/view_models/agent_profile_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class AccountPage extends StatelessWidget {
  final AccountController? controller;

  const AccountPage({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final providedController = controller;
    return providedController != null
        ? ChangeNotifierProvider.value(
            value: providedController,
            child: const _AccountView(),
          )
        : ChangeNotifierProvider(
            create: (_) => AccountController(),
            child: const _AccountView(),
          );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AccountController>().state;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.agentSettings)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.hasError
              ? Center(
                  child: Text(
                    l10n.failedToLoadProfile,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : _AccountContent(profile: state.profile!, l10n: l10n),
    );
  }
}

class _AccountContent extends StatelessWidget {
  final AgentProfileViewModel profile;
  final AppLocalizations l10n;

  const _AccountContent({
    required this.profile,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileHeaderCard(profile: profile),
                const SizedBox(height: 20),
                _ProfileDetailsCard(profile: profile, l10n: l10n),
                const SizedBox(height: 20),
                _PreferencesCard(l10n: l10n),
                const SizedBox(height: 24),
                _LogoutButton(l10n: l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _CardShell({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final AgentProfileViewModel profile;

  const _ProfileHeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CardShell(
      child: Row(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              profile.initials,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(profile.email),
                const SizedBox(height: 4),
                Text(
                  profile.cnpj,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailsCard extends StatelessWidget {
  final AgentProfileViewModel profile;
  final AppLocalizations l10n;

  const _ProfileDetailsCard({required this.profile, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileSection,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _ProfileField(label: l10n.loginEmailLabel, value: profile.email),
          _ProfileField(label: l10n.cpfLabel, value: profile.cpf),
          _ProfileField(label: l10n.cnpjLabel, value: profile.cnpj),
          _ProfileField(label: l10n.phoneLabel, value: profile.phoneNumber),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditProfileDialog(context, l10n, profile),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editAgentData),
              ),
              OutlinedButton.icon(
                onPressed: () => _showChangePasswordDialog(context, l10n),
                icon: const Icon(Icons.lock_reset),
                label: Text(l10n.changePassword),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    AppLocalizations l10n,
    AgentProfileViewModel profile,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.editAgentData),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: profile.name,
                  decoration: InputDecoration(labelText: l10n.clientNameColumn),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: profile.email,
                  decoration: InputDecoration(labelText: l10n.loginEmailLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: profile.phoneNumber,
                  decoration: InputDecoration(labelText: l10n.phoneLabel),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.changePassword),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.currentPassword),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.newPassword),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.updateButton),
            ),
          ],
        );
      },
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _PreferencesCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsController = context.watch<SettingsController>();

    return _CardShell(
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

class _LogoutButton extends StatelessWidget {
  final AppLocalizations l10n;

  const _LogoutButton({required this.l10n});

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

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
