import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:routecraft_app/app/router/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RouteCraft Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNavButton(
              context,
              'Create a Route',
              Icons.add_location_alt,
              () => context.push(AppRoutes.homeCreateRoute),
            ),
            const SizedBox(height: 16),
            _buildNavButton(
              context,
              'Follow a Travel',
              Icons.search,
              () => context.push(AppRoutes.homeFollowTravel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
      BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      height: 80,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).primaryColor,
        ),
        icon: Icon(icon, size: 32),
        label: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
