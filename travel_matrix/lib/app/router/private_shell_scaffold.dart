import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class PrivateShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PrivateShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: TravelAppColors.background,
      body: Row(
        children: [
          // Sidebar Wrapper
          Container(
            width: 250,
            color: TravelAppColors.surface,
            child: Column(
              children: [
                // Header / Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: TravelAppColors.primary.withAlpha(240),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/images/logo_small.png', width: 50),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Travel Matrix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: TravelAppColors.primary)),
                          Text('THE DIGITAL CONCIERGE', style: TextStyle(fontSize: 8, color: TravelAppColors.textSecondary, letterSpacing: 1.2)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Navigation Links
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      _buildNavItem(
                        icon: Icons.dashboard,
                        label: 'Dashboard',
                        isSelected: currentIndex == 0,
                        onTap: () => navigationShell.goBranch(0),
                      ),
                      const SizedBox(height: 8),
                      // Booking NavItem directly mapping to Travels (index 1)
                      _buildNavItem(
                        icon: Icons.calendar_month,
                        label: 'Booking',
                        isSelected: currentIndex == 1,
                        onTap: () => navigationShell.goBranch(1),
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        icon: Icons.people,
                        label: 'Users',
                        isSelected: currentIndex == 2,
                        onTap: () => navigationShell.goBranch(2),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: TravelAppColors.divider),
                      const SizedBox(height: 24),
                      _buildNavItem(
                        icon: Icons.settings,
                        label: 'Settings',
                        isSelected: currentIndex == 3,
                        onTap: () => navigationShell.goBranch(3),
                      ),
                    ],
                  ),
                ),

                // Footer Links & User Profile
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildSimpleLink(Icons.help_outline, 'Support', () {}),
                      const SizedBox(height: 16),
                      _buildSimpleLink(Icons.logout, 'Logout', () {
                        context.read<AuthController>().logout();
                      }),
                      const SizedBox(height: 24),
                      const Divider(color: TravelAppColors.divider),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: TravelAppColors.primaryLight,
                            child: Icon(Icons.person, color: TravelAppColors.surface),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Agent Alex', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: TravelAppColors.primary)),
                              Text('Premium Tier', style: TextStyle(fontSize: 12, color: TravelAppColors.textSecondary)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(width: 1, color: TravelAppColors.divider),
          // Main Content
          Expanded(
            child: navigationShell,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isSelected, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TravelAppColors.background : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? const Border(left: BorderSide(color: TravelAppColors.accentGold, width: 4)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? TravelAppColors.primary : TravelAppColors.textSecondary, size: 22),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: isSelected ? TravelAppColors.primary : TravelAppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleLink(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: TravelAppColors.textSecondary, size: 20),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(color: TravelAppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
