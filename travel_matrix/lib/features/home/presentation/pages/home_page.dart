import 'package:flutter/material.dart';

import 'package:travel_matrix/features/account/presentation/pages/account_page.dart';
import 'package:travel_matrix/features/itinerary_creation/presentation/pages/itinerary_creation_page.dart';
import 'package:travel_matrix/features/visualization/presentation/pages/visualization_page.dart';
import 'package:travel_matrix/features/users/presentation/pages/users_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    VisualizationPage(),      // Tab 0
    ItineraryCreationPage(),  // Tab 1
    UsersPage(),              // Tab 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Matrix Dashboard'),
        actions: [
          IconButton(
            tooltip: 'User Account & Settings',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountPage()));
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map),
                label: Text('Routes & Itineraries'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_task),
                selectedIcon: Icon(Icons.add_task),
                label: Text('Create Itinerary'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Manage Users'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
