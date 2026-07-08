import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class PrivateShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PrivateShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthController>();
    final userName = auth.userName ?? l10n.travelAgentRole;
    final userEmail = auth.userEmail ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          Container(
            width: 250,
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/logo_small.png',
                          width: 50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.digitalConcierge,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _NavItem(
                        icon: Icons.dashboard,
                        label: l10n.dashboardNav,
                        isSelected: currentIndex == 0,
                        onTap: () => navigationShell.goBranch(0),
                      ),
                      const SizedBox(height: 8),
                      _NavItem(
                        icon: Icons.calendar_month,
                        label: l10n.bookingNav,
                        isSelected: currentIndex == 1,
                        onTap: () => navigationShell.goBranch(1),
                      ),
                      const SizedBox(height: 8),
                      _NavItem(
                        icon: Icons.people,
                        label: l10n.usersTitle,
                        isSelected: currentIndex == 2,
                        onTap: () => navigationShell.goBranch(2),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      _NavItem(
                        icon: Icons.manage_accounts,
                        label: 'Account', // Ideally from l10n.profileSection, but let's use 'Account' or l10n.profileSection
                        isSelected: currentIndex == 3,
                        onTap: () => navigationShell.goBranch(3),
                      ),
                      const SizedBox(height: 8),
                      _NavItem(
                        icon: Icons.settings,
                        label: l10n.settingsNav,
                        isSelected: currentIndex == 4,
                        onTap: () => navigationShell.goBranch(4),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _SimpleLink(
                        icon: Icons.help_outline,
                        label: l10n.supportNav,
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      _SimpleLink(
                        icon: Icons.logout,
                        label: l10n.logoutNav,
                        onTap: () => context.read<AuthController>().logout(),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                theme.colorScheme.primary.withValues(alpha: 0.12),
                            child: Text(
                              _initials(userName),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userEmail.isEmpty
                                      ? l10n.travelAgentRole
                                      : userEmail,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: theme.dividerColor),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final foreground = isSelected
        ? selectedColor
        : theme.colorScheme.onSurface.withValues(alpha: 0.78);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border(
                  left: BorderSide(
                    color: theme.colorScheme.secondary,
                    width: 4,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: foreground, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SimpleLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurface.withValues(alpha: 0.64);

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
