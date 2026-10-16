import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/global_controllers/notifications_badge_controller.dart';
import 'package:travel_matrix/app/global_controllers/sidebar_controller.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/shared/widgets/responsive_layout_builder.dart';

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

    final destinations = [
      (icon: Icons.dashboard, label: l10n.dashboardNav),
      (icon: Icons.calendar_month, label: l10n.bookingNav),
      (icon: Icons.people, label: l10n.usersTitle),
      (icon: Icons.business_outlined, label: l10n.companyNav),
    ];
    final divider = theme.dividerColor;

    final sidebar = context.watch<SidebarController>();

    Widget fullSidebar() => Container(
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
                    const SizedBox(width: 4),
                    const _SidebarToggleButton(size: ScreenSize.desktop),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  children: [
                    for (var i = 0; i < destinations.length; i++) ...[
                      if (i > 0) const SizedBox(height: 4),
                      _NavItem(
                        icon: destinations[i].icon,
                        label: destinations[i].label,
                        isSelected: currentIndex == i,
                        onTap: () => navigationShell.goBranch(i),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
                ),
                child: _AccountMenu(
                  onGoToAccount: () => navigationShell.goBranch(4),
                  builder: (context, controller) => _AccountRow(
                    controller: controller,
                    userName: userName,
                    userEmail: userEmail,
                  ),
                ),
              ),
            ],
          ),
        );

    // Rail de ícones: padrão do tablet e estado "recolhida" do desktop.
    Widget rail(ScreenSize size) => Container(
          width: 72,
          color: theme.colorScheme.surface,
          child: SafeArea(
            right: false,
            child: Column(
              children: [
                const SizedBox(height: 8),
                _SidebarToggleButton(size: size),
                const SizedBox(height: 4),
                const _NotificationsBellButton(),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      for (final (i, d) in destinations.indexed)
                        _NavIconButton(
                          icon: d.icon,
                          label: d.label,
                          isSelected: currentIndex == i,
                          onTap: () => navigationShell.goBranch(i),
                        ),
                    ],
                  ),
                ),
                _AccountAvatarMenu(
                  userName: userName,
                  onGoToAccount: () => navigationShell.goBranch(4),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );

    Widget withSide(Widget side) => Row(
          children: [
            side,
            VerticalDivider(width: 1, thickness: 1, color: divider),
            Expanded(child: navigationShell),
          ],
        );

    // Menu oculto: o conteúdo ocupa tudo e um botão flutuante reabre o menu.
    Widget hidden(ScreenSize size) => Stack(
          fit: StackFit.expand,
          children: [
            navigationShell,
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: theme.colorScheme.surface,
                    elevation: 2,
                    shape: const CircleBorder(),
                    child: _SidebarToggleButton(size: size),
                  ),
                ),
              ),
            ),
          ],
        );

    // O shell é o contêiner mais externo: o orquestrador mede a largura da
    // janela. Desktop mantém a sidebar; tablet vira rail de ícones; mobile
    // vira top bar (Design Package da CPS-181). Cada layout ainda pode ser
    // recolhido ou ocultado (Design Package da CPS-200).
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ResponsiveLayoutBuilder(
        desktop: (_) => switch (sidebar.modeFor(ScreenSize.desktop)) {
          SidebarMode.expanded => withSide(fullSidebar()),
          SidebarMode.collapsed => withSide(rail(ScreenSize.desktop)),
          SidebarMode.hidden => hidden(ScreenSize.desktop),
        },
        tablet: (_) => sidebar.modeFor(ScreenSize.tablet) == SidebarMode.hidden
            ? hidden(ScreenSize.tablet)
            : withSide(rail(ScreenSize.tablet)),
        mobile: (_) => sidebar.modeFor(ScreenSize.mobile) == SidebarMode.hidden
            ? hidden(ScreenSize.mobile)
            : Column(
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
                            for (final (i, d) in destinations.indexed)
                              _NavIconButton(
                                icon: d.icon,
                                label: d.label,
                                isSelected: currentIndex == i,
                                onTap: () => navigationShell.goBranch(i),
                              ),
                            const _NotificationsBellButton(),
                            const SizedBox(width: 4),
                            _AccountAvatarMenu(
                              userName: userName,
                              onGoToAccount: () => navigationShell.goBranch(4),
                            ),
                            const _SidebarToggleButton(size: ScreenSize.mobile),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(height: 1, thickness: 1, color: divider),
                  Expanded(child: navigationShell),
                ],
              ),
      ),
    );
  }
}

/// Controle único que cicla o estado do menu lateral no breakpoint [size]
/// (`cps.candidate.sidebar-collapse-toggle`, CPS-200). Reaproveitado na sidebar,
/// no rail, na top bar e no botão flutuante do menu oculto.
class _SidebarToggleButton extends StatelessWidget {
  const _SidebarToggleButton({required this.size});

  final ScreenSize size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<SidebarController>();
    final mode = controller.modeFor(size);

    final tooltip = switch ((mode, SidebarController.next(size, mode))) {
      (SidebarMode.hidden, _) => l10n.sidebarShowTooltip,
      (_, SidebarMode.collapsed) => l10n.sidebarCollapseTooltip,
      _ => l10n.sidebarHideTooltip,
    };
    final icon = switch (mode) {
      SidebarMode.hidden => Icons.chevron_right,
      _ when size == ScreenSize.mobile => Icons.keyboard_arrow_up,
      _ => Icons.chevron_left,
    };

    return IconButton(
      tooltip: tooltip,
      onPressed: () => controller.cycle(size),
      icon: Icon(icon, color: Theme.of(context).colorScheme.primary),
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

/// Menu de conta — o gatilho (linha na sidebar, avatar no rail/top bar) abre
/// um `MenuAnchor` (menu nativo do Material): fecha sozinho ao selecionar um item, ao clicar fora
/// ou com Esc, e sobe automaticamente quando não cabe abaixo do gatilho
/// (CPS-112) — nenhuma dessas regras precisou ser escrita à mão.
/// `consumeOutsideTap: true` (CPS-112, correção pós-QA): sem isso, o tap que
/// fecha o menu também vaza para o resto da árvore, e repetir abrir/fechar
/// no mesmo local acumula listeners de "outside tap" que passam a bloquear
/// o fechamento por clique fora em pontos específicos da tela.
class _AccountMenu extends StatelessWidget {
  const _AccountMenu({required this.onGoToAccount, required this.builder});

  final VoidCallback onGoToAccount;
  final Widget Function(BuildContext context, MenuController controller) builder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return MenuAnchor(
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
      builder: (context, controller, child) => builder(context, controller),
    );
  }
}

/// Linha de conta da sidebar (desktop): avatar, nome, e-mail e seta.
class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.controller,
    required this.userName,
    required this.userEmail,
  });

  final MenuController controller;
  final String userName;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
            _Avatar(userName: userName),
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
  }
}

/// Menu de conta compacto (rail e top bar): só o avatar como gatilho.
class _AccountAvatarMenu extends StatelessWidget {
  const _AccountAvatarMenu({required this.userName, required this.onGoToAccount});

  final String userName;
  final VoidCallback onGoToAccount;

  @override
  Widget build(BuildContext context) => _AccountMenu(
        onGoToAccount: onGoToAccount,
        builder: (context, controller) => _AccountAvatarButton(controller: controller, userName: userName),
      );
}

/// Gatilho de conta compacto (rail e top bar): só o avatar, com tooltip.
class _AccountAvatarButton extends StatelessWidget {
  const _AccountAvatarButton({required this.controller, required this.userName});

  final MenuController controller;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: userName,
      onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      icon: _Avatar(userName: userName),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
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
    );
  }
}

String _initials(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

/// Item de navegação só com ícone (rail no tablet, top bar no mobile). O
/// `IconButton` já dá o alvo de toque de 48x48 e o rótulo semântico via tooltip.
class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: label,
      onPressed: onTap,
      isSelected: isSelected,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: isSelected ? scheme.primary : scheme.onSurface.withValues(alpha: 0.78),
        backgroundColor: isSelected ? scheme.primary.withValues(alpha: 0.08) : null,
      ),
    );
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
