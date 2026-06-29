import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';

/// Displays route data for the selected travel.
///
/// Consumes a [TravelViewModel] and shows the route details like locations,
/// dates, and interest points.
///
/// Layout: Scrollable column with a list of info tiles and interest point cards.
class RouteViewTab extends StatelessWidget {
  final TravelViewModel travel;

  const RouteViewTab({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    final route = travel.route;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(
                  '${AppRoutes.travels}/${travel.localId}/${AppRoutes.routeCreate}',
                  extra: {
                    'travel': travel,
                    'controller': context.read<TravelsController>(),
                  },
                );
              },
              icon: const Icon(Icons.edit_road),
              label: const Text('Edit Route Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Route Details',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _infoTile(theme, Icons.location_on, 'From',
              route.start),
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
          Text('Interest Points (${route.interests.length})',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (route.interests.isEmpty)
            const Text('No interest points defined.')
          else
            ...route.interests.map(
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
