import 'package:uuid/uuid.dart';

import '../../domain/entities/itinerary.dart';
import '../../domain/entities/itinerary_step.dart';

/// Data transfer object for [Itinerary], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Itinerary] and [ItineraryDTO].
class ItineraryDTO {
  /// Main id used for API reference
  final String? id;
  /// Travel agent Id used for API reference
  final String agentId;
  /// Itinerary steps Ids used for API reference
  final List<String> itineraryStepsId;

  ItineraryDTO({
    required this.id,
    required this.agentId,
    required this.itineraryStepsId,
  });

  /// Factory from json method
  factory ItineraryDTO.fromJson(Map<String, dynamic> json) {
    return ItineraryDTO(
      id: json[ItineraryAPIConstants.id],
      agentId: json[ItineraryAPIConstants.agent],
      itineraryStepsId: List<String>.from(json[ItineraryAPIConstants.steps] ?? []),
    );
  }

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      ItineraryAPIConstants.id : id,
      ItineraryAPIConstants.agent : agentId,
      ItineraryAPIConstants.steps : itineraryStepsId,
    };
  }

  /// To domain mapper method
  Itinerary toDomain(List<ItineraryStep> steps) {
    return Itinerary(
        domainId: Uuid().v4(),
        backEndId: id,
        agentId: agentId,
        itinerarySteps: steps
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