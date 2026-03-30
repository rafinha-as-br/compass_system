import 'package:flutter/material.dart';

import 'package:travel_matrix/features/account/presentation/pages/account_page.dart';
import 'package:travel_matrix/features/itinerary_creation/presentation/pages/itinerary_creation_page.dart';
import 'package:travel_matrix/features/visualization/presentation/pages/visualization_page.dart';
import 'package:travel_matrix/features/users/presentation/pages/users_page.dart';
import 'package:travel_matrix/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),          // Tab 0
    VisualizationPage(),      // Tab 1 (Routes)
    ItineraryCreationPage(),  // Tab 2 (Itinerary)
    UsersPage(),              // Tab 3
  ];

  @override
  Widget build(BuildContext context) {
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
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      const SizedBox(height: 8),
                      // Booking Accordion
                      Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: TravelAppColors.textSecondary,
                          collapsedIconColor: TravelAppColors.textSecondary,
                          leading: Icon(Icons.calendar_month, color: (_selectedIndex == 1 || _selectedIndex == 2) ? TravelAppColors.primary : TravelAppColors.textSecondary),
                          title: Text('Booking', style: TextStyle(color: (_selectedIndex == 1 || _selectedIndex == 2) ? TravelAppColors.primary : TravelAppColors.textPrimary, fontWeight: FontWeight.w600)),
                          initiallyExpanded: _selectedIndex == 1 || _selectedIndex == 2,
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildSubNavItem(
                              label: 'Client Routes',
                              isSelected: _selectedIndex == 1,
                              onTap: () => setState(() => _selectedIndex = 1),
                            ),
                            _buildSubNavItem(
                              label: 'Itineraries',
                              isSelected: _selectedIndex == 2,
                              onTap: () => setState(() => _selectedIndex = 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildNavItem(
                        icon: Icons.people,
                        label: 'Users',
                        isSelected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      const SizedBox(height: 24),
                      const Divider(color: TravelAppColors.divider),
                      const SizedBox(height: 24),
                      _buildNavItem(
                        icon: Icons.settings,
                        label: 'Settings',
                        isSelected: false,
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountPage()));
                        },
                      ),
                    ],
                  ),
                ),


                // Footer Links & User Profile
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildSimpleLink(Icons.help_outline, 'Support'),
                      const SizedBox(height: 16),
                      _buildSimpleLink(Icons.logout, 'Logout'),
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
            child: _pages[_selectedIndex],
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

  Widget _buildSubNavItem({required String label, required bool isSelected, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 54, vertical: 10),
        alignment: Alignment.centerLeft,
        child: Text(label, style: TextStyle(color: isSelected ? TravelAppColors.primary : TravelAppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
      ),
    );
  }

  Widget _buildSimpleLink(IconData icon, String label) {
    return InkWell(
      onTap: () {},
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
