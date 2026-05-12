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

  /// validation method


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'itinerarySteps': itinerarySteps.map((e) => e.toJson()).toList(),
    };
  }
}
