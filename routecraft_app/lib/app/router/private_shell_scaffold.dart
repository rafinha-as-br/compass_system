import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

/// Persistent bottom navigation for the authenticated area (Início/Roteiro/
/// Conta), preserving each branch's navigation stack via `IndexedStack`.
class PrivateShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PrivateShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.homeNavLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l10n.itineraryNavLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.accountNavLabel,
          ),
        ],
      ),
    );
  }
}
