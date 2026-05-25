import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/no_itinerary_page.dart';

import '../../widgets/view/itinerary/itinerary_timeline.dart';

/// Displays itinerary data or a prompt to create one.
///
/// Consumes a [TravelViewModel] and shows either the itinerary steps in a timeline
/// or the [NoItineraryPage] if it doesn't exist yet.
class ItineraryViewTab extends StatelessWidget {
  final TravelViewModel travel;

  const ItineraryViewTab({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {

    // if does not have Itinerary
    if (travel.itinerary == null) {
      return NoItineraryPage(travel: travel,);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        final horizontalPadding = isDesktop ? 40.0 : 24.0;
        
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItineraryTimeline(travel: travel),
            ],
          ),
        );
      },
    );
  }
}
