import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/step_card_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/boundary_step_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/flight_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/generic_step_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/hosting_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/stop_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_icon.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/timeline_step_item.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';


/// Timeline widget displaying the itinerary steps.
///
/// Consumes a [TravelViewModel] and renders a list of [TimelineStepItem]s,
/// including synthetic boundary steps (start/end) and mapping each
/// [ItineraryStepViewModel] to its corresponding view card.
///
/// Layout: ListView with custom timeline items.
class ItineraryTimeline extends StatelessWidget {
  final TravelViewModel travel;

  const ItineraryTimeline({
    super.key,
    required this.travel,
  });

  @override
  Widget build(BuildContext context) {
    final itinerary = travel.itinerary;
    
    if (itinerary == null) {
      return const Center(child: Text('No itinerary available.'));
    }

    final baseSteps = itinerary.steps;
    
    // Inject boundary steps as View Models
    final startBoundary = BoundaryStepViewCardModel(
      id: 'start_boundary',
      title: 'Departing from',
      date: travel.route.startDate,
      location: travel.route.start,
      isStart: true,
    );

    final endBoundary = BoundaryStepViewCardModel(
      id: 'end_boundary',
      title: 'Arriving at',
      date: travel.route.endDate,
      location: travel.route.destination,
      isStart: false,
    );

    // Combine steps: Start Boundary, Base Steps, End Boundary
    final int totalCount = baseSteps.length + 2;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        // Determine the step for this index
        final bool isFirst = index == 0;
        final bool isLast = index == totalCount - 1;
        
        dynamic currentStep;
        DateTime stepDate;
        
        if (isFirst) {
          currentStep = startBoundary;
          stepDate = startBoundary.date;
        } else if (isLast) {
          currentStep = endBoundary;
          stepDate = endBoundary.date;
        } else {
          currentStep = baseSteps[index - 1];
          stepDate = (currentStep as ItineraryStepViewModel).startDate;
        }

        final typeLabel = _getStepTypeLabel(currentStep);

        return TimelineStepItem(
          isFirst: isFirst,
          isLast: isLast,
          date: stepDate,
          typeLabel: typeLabel,
          icon: _buildStepIcon(currentStep),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepCard(context, currentStep),
            ],
          ),
        );
      },
    );
  }

  String? _getStepTypeLabel(dynamic step) {
    if (step is StopStepViewModel) return 'Stop';
    if (step is HostingStepViewModel) return 'Hosting';
    if (step is TravelSegmentStepViewModel) {
      final transport = step.transport;
      if (transport is AirplaneViewModel) return 'Flight';
      if (transport is BusViewModel) return 'Bus';
      if (transport is RentalCarViewModel) return 'Car Rental';
      return 'Transport';
    }
    if (step is PlaceHolderStepViewModel) return 'Draft';
    return null;
  }

  Widget _buildStepIcon(dynamic step) {
    IconData iconData = Icons.help_outline;
    Color? color;
    bool isCompleted = false;

    if (step is ItineraryStepViewModel) {
      isCompleted = step.finishDate.isBefore(DateTime.now());
    }

    if (step is StopStepViewModel) {
      iconData = Icons.place;
      color = Colors.orange;
    } else if (step is HostingStepViewModel) {
      iconData = Icons.hotel;
      color = Colors.blue;
    } else if (step is TravelSegmentStepViewModel) {
      iconData = Icons.flight; // Adjust based on transport type if needed
      color = Colors.green;
    } else if (step is PlaceHolderStepViewModel) {
      iconData = Icons.edit_note;
      color = Colors.grey;
    } else if (step is BoundaryStepViewCardModel) {
      iconData = step.isStart ? Icons.trip_origin : Icons.flag;
      color = Colors.grey.shade400;
      isCompleted = step.date.isBefore(DateTime.now());
    }

    return StepIcon(
      icon: iconData,
      color: color,
      isCompleted: isCompleted,
    );
  }

  Widget _buildStepCard(BuildContext context, dynamic step) {
    if (step is StopStepViewModel) {
      return StopCard(stop: StopViewCardModel.fromStepViewModel(step));
    } else if (step is HostingStepViewModel) {
      return HostingCard(hosting: HostingViewCardModel.fromStepViewModel(step));
    } else if (step is TravelSegmentStepViewModel) {
      if (step.transport is AirplaneViewModel) {
        return FlightCard(flight: FlightViewCardModel.fromStepViewModel(step));
      } else {
        return GenericStepCard(step: GenericStepViewCardModel.fromStepViewModel(step));
      }
    } else if (step is BoundaryStepViewCardModel) {
      return BoundaryStepCard(step: step);
    } else if (step is ItineraryStepViewModel) {
      return GenericStepCard(step: GenericStepViewCardModel.fromStepViewModel(step));
    } else {
      return const SizedBox.shrink();
    }
  }
}

