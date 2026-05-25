import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/itinerary_build_page.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/no_itinerary_page.dart';

import '../../models/build_models/itinerary_build_model.dart';
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
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final steps = travel.itinerary!.steps;
                    if (steps.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Itinerary is incomplete and cannot be edited.'),
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ItineraryBuildPage(
                          travelId: travel.localId,
                          itineraryBuildModel: ItineraryBuildModel(
                            travelName: travel.travelTitle,
                            interestsPoints: travel.route.interests,
                            steps: ItineraryStepsBuildModel(
                              startStep: steps.first,
                              finishStep: steps.last,
                              normalSteps: steps.sublist(1, steps.length - 1),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_calendar),
                  label: const Text('Edit Itinerary'),
                ),
              ),
              const SizedBox(height: 16),
              ItineraryTimeline(travel: travel),
            ],
          ),
        );
      },
    );
  }
}
