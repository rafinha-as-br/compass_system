import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/boundary_step_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/flight_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/generic_step_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/hosting_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_cards/stop_card.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/step_icon.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/timeline_step_item.dart';


class ItineraryTimeline extends StatelessWidget {
  final Travel travel;

  const ItineraryTimeline({
    super.key,
    required this.travel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itinerary = travel.itinerary;
    
    if (itinerary == null) {
      return const Center(child: Text('No itinerary available.'));
    }

    final baseSteps = itinerary.itinerarySteps;
    
    // Inject boundary steps
    final List<ItineraryStep> allSteps = [
      BoundaryStep(
        id: 'start_boundary',
        title: 'Departing from',
        startDate: travel.routePlan.startDate,
        finishDate: travel.routePlan.startDate,
        location: travel.routePlan.startLocation,
        isStart: true,
      ),
      ...baseSteps,
      BoundaryStep(
        id: 'end_boundary',
        title: 'Arriving at',
        startDate: travel.routePlan.endDate,
        finishDate: travel.routePlan.endDate,
        location: travel.routePlan.destination,
        isStart: false,
      ),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allSteps.length,
      itemBuilder: (context, index) {
        final step = allSteps[index];
        final typeLabel = _getStepTypeLabel(step);

        return TimelineStepItem(
          isFirst: index == 0,
          isLast: index == allSteps.length - 1,
          date: step.startDate,
          icon: _buildStepIcon(step),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (typeLabel != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    typeLabel.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              _buildStepCard(context, step, index),
            ],
          ),
        );
      },
    );
  }

  String? _getStepTypeLabel(ItineraryStep step) {
    if (step is Stop) return 'Stop';
    if (step is Hosting) return 'Hosting';
    if (step is TravelSegment) return 'Segment';
    if (step is PlaceholderStep) return 'Draft';
    return null;
  }

  Widget _buildStepIcon(ItineraryStep step) {
    IconData iconData = Icons.help_outline;
    Color? color;

    if (step is Stop) {
      iconData = Icons.place;
      color = Colors.orange;
    } else if (step is Hosting) {
      iconData = Icons.hotel;
      color = Colors.blue;
    } else if (step is TravelSegment) {
      iconData = Icons.flight;
      color = Colors.green;
    } else if (step is PlaceholderStep) {
      iconData = Icons.edit_note;
      color = Colors.grey;
    } else if (step is BoundaryStep) {
      iconData = step.isStart ? Icons.trip_origin : Icons.flag;
      color = Colors.grey.shade400;
    }

    return StepIcon(
      icon: iconData,
      color: color,
      isCompleted: step.finished,
    );
  }

  Widget _buildStepCard(BuildContext context, ItineraryStep step, int index) {
    if (step is Stop) {
      return StopCard(stop: step);
    } else if (step is Hosting) {
      return HostingCard(hosting: step);
    } else if (step is TravelSegment) {
      final transport = step.transport;
      if (transport is Airplane) {
        return FlightCard(segment: step, transport: transport);
      }
      // Fallback for other transports or use generic if needed
      return GenericStepCard(step: step);
    } else if (step is BoundaryStep) {
      return BoundaryStepCard(step: step);
    } else {
      return GenericStepCard(step: step);
    }
  }
}
