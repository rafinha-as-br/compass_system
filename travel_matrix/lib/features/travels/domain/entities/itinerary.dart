import 'itinerary_step.dart';

class Itinerary {
  final String id;
  final String agentId;
  List<ItineraryStep> itinerarySteps;

  Itinerary({
    required this.id,
    required this.agentId,
    required this.itinerarySteps,
  });
}

