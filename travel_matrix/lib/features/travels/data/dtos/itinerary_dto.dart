
import '../../domain/entities/itinerary.dart';
import '../../domain/entities/itinerary_step.dart';

class ItineraryDTO {
  final String id;
  final String responsibleAgentName;
  List<String> itineraryStepsId;

  ItineraryDTO({
    required this.id,
    required this.responsibleAgentName,
    required this.itineraryStepsId,
  });

  factory ItineraryDTO.fromJson(Map<String, dynamic> json) {
    return ItineraryDTO(
      id: json['id'],
      responsibleAgentName: json['responsibleAgentName'],
      itineraryStepsId: List<String>.from(json['itineraryStepsId'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'responsibleAgentName': responsibleAgentName,
      'itineraryStepsId': itineraryStepsId,
    };
  }

  Itinerary toDomain(List<ItineraryStep> steps) {
    return Itinerary(
      id: id,
      agentId: responsibleAgentName,
      itinerarySteps: steps,
    );
  }
}