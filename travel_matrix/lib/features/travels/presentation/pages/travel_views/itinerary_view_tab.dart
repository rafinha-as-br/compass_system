import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/no_itinerary_page.dart';

import '../../widgets/view/itinerary/itinerary_timeline.dart';

/// Displays itinerary data or a prompt to create one.
class ItineraryViewTab extends StatelessWidget {
  final Travel travel;

  const ItineraryViewTab({required this.travel});

  @override
  Widget build(BuildContext context) {

    // if does not has Itinerary
    if (!travel.hasItinerary) {
      return NoItineraryPage(travel: travel,);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItineraryTimeline(travel: travel),
        ],
      ),
    );
  }
}
