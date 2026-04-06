import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/controllers/settings_controller.dart';
import '../../../../app/gates/gate_auth.dart';
import '../../../../core/services/auth_service.dart';
import '../../../travels/presentation/pages/travels_dashboard_page.dart';
import '../../../users/presentation/pages/users_dashboard_page.dart';
import 'main_dashboard_page.dart';


/// Root container after authentication.
/// Contains a persistent Sidebar (NavigationRail) for switching between
/// Main Dashboard, Users Dashboard, and Travels Dashboard.
/// Each tab has its own nested Navigator for independent navigation stacks.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Global keys for each nested Navigator to preserve state
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          // ─── Sidebar Navigation ─────────────────────────────────────
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              if (_selectedIndex == index) {
                // Pop to root of current tab if already selected
                _navigatorKeys[index].currentState?.popUntil(
                  (route) => route.isFirst,
                );
              } else {
                setState(() => _selectedIndex = index);
              }
            },
            extended: false,
            labelType: NavigationRailLabelType.all,
            backgroundColor: theme.colorScheme.primary,
            selectedIconTheme: IconThemeData(
              color: theme.colorScheme.secondary,
            ),
            unselectedIconTheme: IconThemeData(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
            ),
            selectedLabelTextStyle: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            indicatorColor: theme.colorScheme.secondary.withValues(alpha: 0.15),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Icon(
                Icons.grid_view_rounded,
                size: 32,
                color: theme.colorScheme.secondary,
              ),
            ),
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Toggle Theme',
                    icon: Icon(
                      Icons.brightness_6,
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
                    ),
                    onPressed: () {
                      context.read<SettingsController>().toggleTheme();
                    },
                  ),
                  IconButton(
                    tooltip: 'Log Out',
                    icon: Icon(
                      Icons.logout,
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
                    ),
                    onPressed: () async {
                      await AuthService.instance.clearToken();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const GateAuth()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.flight_takeoff_outlined),
                selectedIcon: Icon(Icons.flight_takeoff),
                label: Text('Travels'),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: theme.dividerColor,
          ),
          // ─── Main Content with nested navigation ────────────────────
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _NestedNavigator(
                  navigatorKey: _navigatorKeys[0],
                  child: const MainDashboardPage(),
                ),
                _NestedNavigator(
                  navigatorKey: _navigatorKeys[1],
                  child: const UsersDashboardPage(),
                ),
                _NestedNavigator(
                  navigatorKey: _navigatorKeys[2],
                  child: const TravelsDashboardPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Wraps page content in its own Navigator for nested navigation.
/// Intercepts system back button to pop the nested stack first.
class _NestedNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  const _NestedNavigator({
    required this.navigatorKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => child,
        );
      },
    );
  }
}
