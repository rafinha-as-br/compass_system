import 'itinerary_step.dart';

/// The plan built by the travel agent for a [Travel] — an ordered list of
/// [ItineraryStep]s. The client only ever reads this.
class Itinerary {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  final String agentName;
  final List<ItineraryStep> itinerarySteps;

  Itinerary({
    required this.domainId,
    required this.backEndId,
    required this.agentName,
    required this.itinerarySteps,
  });
}
