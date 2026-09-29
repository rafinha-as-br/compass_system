import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/global_controllers/notifications_badge_controller.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.compassSystemBrand,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const _NotificationsBellButton(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    children: [
                      _NavItem(
                        icon: Icons.dashboard,
                        label: l10n.dashboardNav,
                        isSelected: currentIndex == 0,
                        onTap: () => navigationShell.goBranch(0),
                      ),
                      const SizedBox(height: 4),
                      _NavItem(
                        icon: Icons.calendar_month,
                        label: l10n.bookingNav,
                        isSelected: currentIndex == 1,
                        onTap: () => navigationShell.goBranch(1),
                      ),
                      const SizedBox(height: 4),
                      _NavItem(
                        icon: Icons.people,
                        label: l10n.usersTitle,
                        isSelected: currentIndex == 2,
                        onTap: () => navigationShell.goBranch(2),
                      ),
                    ],
                  ),
                ),
                _AccountFooter(
                  userName: userName,
                  userEmail: userEmail,
                  onGoToAccount: () => navigationShell.goBranch(3),
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

/// Rodapé da sidebar — a linha de conta é o gatilho de um `MenuAnchor` (menu
/// nativo do Material): fecha sozinho ao selecionar um item, ao clicar fora
/// ou com Esc, e sobe automaticamente quando não cabe abaixo do gatilho
/// (CPS-112) — nenhuma dessas regras precisou ser escrita à mão.
/// `consumeOutsideTap: true` (CPS-112, correção pós-QA): sem isso, o tap que
/// fecha o menu também vaza para o resto da árvore, e repetir abrir/fechar
/// no mesmo local acumula listeners de "outside tap" que passam a bloquear
/// o fechamento por clique fora em pontos específicos da tela.
class _AccountFooter extends StatelessWidget {
  const _AccountFooter({
    required this.userName,
    required this.userEmail,
    required this.onGoToAccount,
  });

  final String userName;
  final String userEmail;
  final VoidCallback onGoToAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: MenuAnchor(
        consumeOutsideTap: true,
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
          elevation: const WidgetStatePropertyAll(8),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(226, 0)),
          maximumSize: const WidgetStatePropertyAll(Size(226, double.infinity)),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
        ),
        menuChildren: [
          MenuItemButton(
            autofocus: true,
            leadingIcon: Icon(Icons.person_outline, color: theme.colorScheme.onSurface),
            onPressed: onGoToAccount,
            child: Text(l10n.myAccountNav),
          ),
          MenuItemButton(
            leadingIcon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurface),
            onPressed: onGoToAccount,
            child: Text(l10n.settingsNav),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          MenuItemButton(
            leadingIcon: Icon(Icons.help_outline, color: theme.colorScheme.onSurface),
            onPressed: () {},
            child: Text(l10n.supportNav),
          ),
          MenuItemButton(
            leadingIcon: Icon(Icons.logout, color: theme.colorScheme.error),
            style: MenuItemButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => context.read<AuthController>().logout(),
            child: Text(l10n.logoutNav),
          ),
        ],
        builder: (context, controller, child) {
          return InkWell(
            onTap: () => controller.isOpen ? controller.close() : controller.open(),
            borderRadius: BorderRadius.circular(8),
            hoverColor: theme.colorScheme.primary.withValues(alpha: 0.04),
            highlightColor: theme.colorScheme.primary.withValues(alpha: 0.09),
            splashColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: TravelAppColors.primaryLight,
                    child: Text(
                      _initials(userName),
                      style: const TextStyle(
                        color: TravelAppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
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
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userEmail.isEmpty ? l10n.travelAgentRole : userEmail,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    controller.isOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    size: 16,
                    color: controller.isOpen
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          );
        },
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

/// Sidebar header's notification entry point (CPS-149) — a bell with an
/// unread-count badge, approved by Rafinha over a 4th nav item or a second
/// purpose on the account footer (see the CPS-149 design package README).
class _NotificationsBellButton extends StatelessWidget {
  const _NotificationsBellButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = context.watch<NotificationsBadgeController>().unreadCount;
    final l10n = AppLocalizations.of(context)!;

    // `IconButton` already provides the required 48x48 tap target
    // (flutter-development-standards §13) around the design's compact 32x32
    // visual, plus the tooltip's own Semantics — `Badge.count` follows
    // colorScheme.error/onError instead of a hardcoded color, so it holds up
    // under a custom or dark theme too.
    return Badge.count(
      count: unreadCount,
      isLabelVisible: unreadCount > 0,
      child: IconButton(
        tooltip: l10n.notificationsBellTooltip,
        onPressed: () => context.push(AppRoutes.notifications),
        icon: const Icon(Icons.notifications_outlined, size: 18),
        style: IconButton.styleFrom(
          minimumSize: const Size(32, 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}
