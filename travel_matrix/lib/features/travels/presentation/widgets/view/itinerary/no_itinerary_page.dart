import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';


class NoItineraryPage extends StatelessWidget {
  final TravelViewModel travel;

  const NoItineraryPage({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month,
              size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(
            'No Itinerary Yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go(
                '${AppRoutes.travels}/${travel.localId}/${AppRoutes.itineraryCreate}',
                extra: {
                  'travelId': travel.localId,
                  'itineraryBuildModel': ItineraryBuildModel(
                    travelName: travel.travelTitle,
                    interestsPoints: travel.route.interests,
                    steps: null,
                  ),
                },
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
