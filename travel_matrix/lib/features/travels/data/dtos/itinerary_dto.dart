import 'package:travel_matrix/features/travels/data/dtos/itinerary_step_dto.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/itinerary.dart';

/// Data transfer object for [Itinerary], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Itinerary] and [ItineraryDTO].
class ItineraryDTO {
  /// Main id used for API reference
  final String? id;
  /// Travel agent Id used for API reference
  final String agentId;
  /// Itinerary steps DTO
  final List<ItineraryStepDTO> itinerarySteps;

  ItineraryDTO({
    required this.id,
    required this.agentId,
    required this.itinerarySteps,
  });

  /// Factory from json method
  factory ItineraryDTO.fromJson(Map<String, dynamic> json) {
    return ItineraryDTO(
      id: json[ItineraryAPIConstants.id],
      agentId: json[ItineraryAPIConstants.agent],
      itinerarySteps: List<ItineraryStepDTO>.from(
        json[ItineraryAPIConstants.steps].map(
          (x) => ItineraryStepDTO.fromJson(x),
        )
      )
    );
  }

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      ItineraryAPIConstants.id : id,
      ItineraryAPIConstants.agent : agentId,
      ItineraryAPIConstants.steps : itinerarySteps.map((x) => x.toJson()).toList(),
    };
  }

  /// To domain mapper method
  Itinerary toDomain() {
    return Itinerary(
        domainId: Uuid().v4(),
        backEndId: id,
        agentId: agentId,
        itinerarySteps: itinerarySteps.map((x) => x.toDomain()).toList()
    );
  }

  /// From domain factory constructor
  factory ItineraryDTO.fromDomain({required Itinerary itinerary}) {
    return ItineraryDTO(
      id: itinerary.backEndId,
      agentId: itinerary.agentId,
      itinerarySteps: itinerary.itinerarySteps.map((x) => ItineraryStepDTO.fromDomain(step: x)).toList(),
    );
  }

}

/// Contains the constants field names from the API
abstract class ItineraryAPIConstants{
  /// Main Id field
  static const String id = 'id';
  /// Travel agent Id field
  static const String agent = 'agentId';
  /// Itinerary steps list ids field
  static const String steps = 'itineraryStepsId';
}