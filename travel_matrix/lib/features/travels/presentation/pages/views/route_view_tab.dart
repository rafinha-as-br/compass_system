import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

/// Displays route data for the selected travel.
class RouteViewTab extends StatelessWidget {
  final Travel travel;

  const RouteViewTab({required this.travel});

  @override
  Widget build(BuildContext context) {
    final route = travel.routePlan;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route Details',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _infoTile(theme, Icons.location_on, 'From',
              route.startLocation),
          _infoTile(theme, Icons.flag, 'To', route.destination),
          _infoTile(
            theme,
            Icons.calendar_today,
            'Start Date',
            '${route.startDate.day}/${route.startDate.month}/${route.startDate.year}',
          ),
          _infoTile(
            theme,
            Icons.event,
            'End Date',
            '${route.endDate.day}/${route.endDate.month}/${route.endDate.year}',
          ),
          const SizedBox(height: 24),
          Text('Interest Points (${route.interestsList.length})',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (route.interestsList.isEmpty)
            const Text('No interest points defined.')
          else
            ...route.interestsList.map(
                  (poi) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.place,
                      color: theme.colorScheme.secondary),
                  title: Text(poi.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  subtitle: Text(poi.description),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoTile(
      ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
