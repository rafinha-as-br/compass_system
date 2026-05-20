import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:uuid/uuid.dart';

import 'itinerary_step.dart';

/// Represents the planning schedule for an [Travel], created by an Travel Agent,
/// contains a list of [ItineraryStep]s.
class Itinerary {
  /// Id used for local reference
  final String domainId;
  /// Id used reference on the Compass API
  final String? backEndId;
  /// Id used on the Compass API as reference for the [Travel Agent] that created the itinerary
  final String agentId;
  /// List of [ItineraryStep]s that make up the itinerary
  List<ItineraryStep> itinerarySteps;

  /// Private constructor
  Itinerary({
    required this.domainId,
    required this.backEndId,
    required this.agentId,
    required this.itinerarySteps,
  });


  /// To json method, returns a [Map] with the itinerary data
  Map<String, dynamic> toJson({required String travelId}) {
    return {
      'travelId' : travelId,
      'agentId': agentId,
      'itinerarySteps': itinerarySteps.map((e) => e.toJson()).toList(),
    };
  }

  /// From json method, returns a [Itinerary] from a [Map]
  Itinerary fromJson(Map<String, dynamic> json) {
    return Itinerary(
      domainId: Uuid().v4(),
      backEndId: json['backEndId'],
      agentId: json['agentId'],
      itinerarySteps: json['itinerarySteps'].map((e) => e.fromJson()).toList(),
    );
  }


}
