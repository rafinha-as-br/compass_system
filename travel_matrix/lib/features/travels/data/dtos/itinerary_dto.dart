import 'package:travel_matrix/features/travels/data/dtos/itinerary_step_dto.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/itinerary.dart';
import 'package:travel_matrix/core/constants/api_fields.dart';

/// Data transfer object for [Itinerary], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Itinerary] and [ItineraryDTO].
class ItineraryDTO {
  /// Main id used for API reference
  final String? id;

  /// Travel agent name that created the itinerary
  final String agentName;

  /// Itinerary steps DTO
  final List<ItineraryStepDTO> itinerarySteps;

  ItineraryDTO({
    required this.id,
    required this.agentName,
    required this.itinerarySteps,
  });

  /// Factory from json method
  factory ItineraryDTO.fromJson(Map<String, dynamic> json) {
    final rawSteps = json[ItineraryApiFields.steps];

    return ItineraryDTO(
      id: json[ItineraryApiFields.id],
      agentName: (json[ItineraryApiFields.agentName] as String?) ?? '',
      itinerarySteps: rawSteps is Iterable
          ? <ItineraryStepDTO>[
              for (final step in rawSteps)
                ItineraryStepDTO.fromJson(
                  Map<String, dynamic>.from(step as Map),
                ),
            ]
          : <ItineraryStepDTO>[],
    );
  }

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      ItineraryApiFields.id: id,
      ItineraryApiFields.agentName: agentName,
      ItineraryApiFields.steps: itinerarySteps.map((x) => x.toJson()).toList(),
    };
  }

  /// To domain mapper method
  Itinerary toDomain() {
    return Itinerary(
      domainId: Uuid().v4(),
      backEndId: id,
      agentName: agentName,
      itinerarySteps: itinerarySteps.map((x) => x.toDomain()).toList(),
    );
  }

  /// From domain factory constructor
  factory ItineraryDTO.fromDomain({required Itinerary itinerary}) {
    return ItineraryDTO(
      id: itinerary.backEndId,
      agentName: itinerary.agentName,
      itinerarySteps: itinerary.itinerarySteps
          .map((x) => ItineraryStepDTO.fromDomain(step: x))
          .toList(),
    );
  }
}
