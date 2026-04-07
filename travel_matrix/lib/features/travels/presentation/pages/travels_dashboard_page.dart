import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/shared/widgets/breadcrumb_bar.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/pages/travel_creation_page.dart';
import 'package:travel_matrix/features/travels/presentation/pages/travel_view_page.dart';

/// Travels Dashboard Tab — lists all travels with state indicator.
class TravelsDashboardPage extends StatelessWidget {
  const TravelsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TravelsController(),
      child: const _TravelsDashboardView(),
    );
  }
}

class _TravelsDashboardView extends StatelessWidget {
  const _TravelsDashboardView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TravelsController>();
    final state = controller.state;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BreadcrumbBar(items: ['Travels Dashboard']),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Travels',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: controller,
                              child: const TravelCreationPage(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Travel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.travels.isEmpty
                          ? Center(
                              child: Text(
                                'No travels created yet.',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.travels.length,
                              itemBuilder: (context, index) {
                                final travel = state.travels[index];
                                return _buildTravelCard(
                                    context, travel, controller);
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelCard(
    BuildContext context,
    Travel travel,
    TravelsController controller,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: travel.hasItinerary
              ? const Color(0xFF2E7D5B).withValues(alpha: 0.15)
              : const Color(0xFFC08A2E).withValues(alpha: 0.15),
          child: Icon(
            travel.hasItinerary ? Icons.check : Icons.map,
            color: travel.hasItinerary
                ? const Color(0xFF2E7D5B)
                : const Color(0xFFC08A2E),
          ),
        ),
        title: Text(
          travel.travelName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${travel.routePlan.startLocation} ➔ ${travel.routePlan.destination}\n'
          'Client: ${travel.clientId}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: travel.hasItinerary
                    ? const Color(0xFF2E7D5B).withValues(alpha: 0.1)
                    : const Color(0xFFC08A2E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                travel.hasItinerary ? 'Itinerary Ready' : 'Route Only',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: travel.hasItinerary
                      ? const Color(0xFF2E7D5B)
                      : const Color(0xFFC08A2E),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: controller,
                      child: TravelViewPage(travel: travel),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: controller,
                child: TravelViewPage(travel: travel),
              ),
            ),
          );
        },
      ),
    );
  }
}
