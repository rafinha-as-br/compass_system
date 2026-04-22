import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/itinerary/itinerary_timeline.dart';
import 'package:travel_matrix/features/travels/presentation/pages/itinerary_creation_page.dart';

/// Travel View Page — divided into Route View and Itinerary View tabs.
class TravelViewPage extends StatelessWidget {
  final Travel travel;

  const TravelViewPage({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(travel.travelName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom:  TabBar(
            automaticIndicatorColorAdjustment: true,
            tabs: [
              Tab(icon: Icon(Icons.map, color: Theme.of(context).colorScheme.onPrimary,), text: 'Route'),
              Tab(icon: Icon(Icons.list_alt, color: Theme.of(context).colorScheme.onPrimary,), text: 'Itinerary'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final controller = context.read<TravelsController>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: controller,
                  child: ItineraryCreationPage(travel: travel),
                ),
              ),
            );
          },
          icon: const Icon(Icons.add_road),
          label: const Text('Edit Itinerary'),
        ),
        body: TabBarView(
          children: [
            _RouteViewTab(travel: travel),
            _ItineraryViewTab(travel: travel),
          ],
        ),
      ),
    );
  }
}

/// Displays route data for the selected travel.
class _RouteViewTab extends StatelessWidget {
  final Travel travel;

  const _RouteViewTab({required this.travel});

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

/// Displays itinerary data or a prompt to create one.
class _ItineraryViewTab extends StatelessWidget {
  final Travel travel;

  const _ItineraryViewTab({required this.travel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!travel.hasItinerary) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No itinerary has been created yet.',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final controller = context.read<TravelsController>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: controller,
                      child: ItineraryCreationPage(travel: travel),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Itinerary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final itinerary = travel.itinerary!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Itinerary Details',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Agent: ${itinerary.responsibleAgentName}',
              style: TextStyle(
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6))),
          const SizedBox(height: 24),
          // Unified Itinerary Timeline
          Text('Itinerary Timeline (${itinerary.itinerarySteps.length} steps)',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          if (itinerary.itinerarySteps.isEmpty)
            const Text('The itinerary is empty.')
          else
            ItineraryTimeline(steps: itinerary.itinerarySteps),
        ],
      ),
    );
  }
}

