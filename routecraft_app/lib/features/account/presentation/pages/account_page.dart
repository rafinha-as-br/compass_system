import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:routecraft_app/app/controllers/settings_controller.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/account/presentation/controllers/account_controller.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key, this.controller});

  /// Injectable for widget tests with a fixed state, without depending on
  /// the real network/singleton wiring. In production, the call site
  /// (`AccountPage()`) is unaffected — the default wiring is used.
  final AccountController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? AccountController(),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<AccountController>().state;
    final settingsController = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _ClientHeader(name: state.clientName, email: state.clientEmail),
                if (state.agentName != null) ...[
                  const SizedBox(height: 24),
                  _AgentBlock(name: state.agentName!),
                ],
                const SizedBox(height: 32),
                _MenuItem(
                  icon: Icons.badge_outlined,
                  label: l10n.accountPersonalDataMenu,
                  onTap: () => context.push(AppRoutes.accountPersonalData),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: l10n.accountNotificationsMenu,
                  badgeCount: state.unreadNotificationsCount,
                  onTap: () => _openNotifications(context),
                ),
                _MenuItem(icon: Icons.help_outline, label: l10n.accountHelpMenu),
                const SizedBox(height: 16),
                const Divider(),
                SwitchListTile(
                  title: Text(l10n.accountDarkModeLabel),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: settingsController.themeMode == ThemeMode.dark,
                  onChanged: (_) => settingsController.toggleTheme(),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: Text(l10n.accountLanguageLabel(settingsController.locale.languageCode.toUpperCase())),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: settingsController.toggleLanguage,
                ),
                const SizedBox(height: 32),
                AppButton(
                  variant: AppButtonVariant.danger,
                  icon: const Icon(Icons.logout),
                  // AppRouter's redirect leaves the private area once
                  // AuthController.logout() notifies isAuthenticated == false,
                  // which also blocks the back button from returning to it.
                  onPressed: () => context.read<AuthController>().logout(),
                  child: Text(l10n.logoutButton),
                ),
              ],
            ),
    );
  }
}

/// Awaits the push before refreshing — the shell keeps [AccountController]
/// alive across navigation, so marking notifications as read would otherwise
/// never clear the unread badge back on Conta.
Future<void> _openNotifications(BuildContext context) async {
  await context.push(AppRoutes.accountNotifications);
  if (context.mounted) {
    context.read<AccountController>().refresh();
  }
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader({required this.name, required this.email});

  final String? name;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: theme.colorScheme.primary,
          child: Text(
            _initials(name ?? ''),
            style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimary),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name ?? '',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          email ?? '',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}

class _AgentBlock extends StatelessWidget {
  const _AgentBlock({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountAgentBlockLabel,
              style:
                  theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.secondary,
                  child: Text(_initials(name), style: TextStyle(color: theme.colorScheme.onSecondary)),
                ),
                const SizedBox(width: 12),
                Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, this.onTap, this.badgeCount});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Shown as a small trailing badge when greater than zero.
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final count = badgeCount;

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count != null && count > 0) ...[
            _UnreadBadge(count: count),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap ?? () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoonMessage))),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: theme.colorScheme.error, borderRadius: BorderRadius.circular(12)),
      child: Text(
        '$count',
        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onError, fontWeight: FontWeight.bold),
      ),
    );
  }
}

String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}
