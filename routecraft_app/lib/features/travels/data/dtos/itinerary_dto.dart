import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/constants/api_fields.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary.dart';
import 'itinerary_step_dto.dart';

class ItineraryDTO {
  final String? id;
  final String agentName;
  final List<ItineraryStepDTO> itinerarySteps;

  ItineraryDTO({required this.id, required this.agentName, required this.itinerarySteps});

  factory ItineraryDTO.fromJson(Map<String, dynamic> json) {
    return ItineraryDTO(
      id: json[ItineraryApiFields.id]?.toString(),
      agentName: json[ItineraryApiFields.agentName]?.toString() ?? '',
      itinerarySteps: (json[ItineraryApiFields.steps] as List<dynamic>? ?? const [])
          .map((x) => ItineraryStepDTO.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ItineraryApiFields.id: id,
      ItineraryApiFields.agentName: agentName,
      ItineraryApiFields.steps: itinerarySteps.map((x) => x.toJson()).toList(),
    };
  }

  Itinerary toDomain() {
    return Itinerary(
      domainId: const Uuid().v4(),
      backEndId: id,
      agentName: agentName,
      itinerarySteps: itinerarySteps.map((x) => x.toDomain()).toList(),
    );
  }
}
