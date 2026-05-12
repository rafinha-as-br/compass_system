import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

import '../../../build_models/itinerary_build_model.dart';
import '../../../pages/builds/itinerary_build_page.dart';
import '../../../view_models/route_view_model.dart';

/// Displayed when a travel has no itinerary yet.
///
/// Shows an empty state with a button that navigates to [ItineraryBuildPage]
/// in create mode (null steps).
class NoItineraryPage extends StatelessWidget {
  const NoItineraryPage({super.key, required this.travel});
  final Travel travel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No itinerary has been created yet.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItineraryBuildPage(
                    travelId: travel.id,
                    itineraryBuildModel: ItineraryBuildModel(
                      travelName: travel.travelName,
                      steps: null,
                      interestsPoints: travel.routePlan.interestsList
                          .map((ip) => InterestPointViewModel(
                                id: ip.id,
                                name: ip.name,
                                description: ip.description,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Itinerary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
