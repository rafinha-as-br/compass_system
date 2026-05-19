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
  Itinerary._({
    required this.domainId,
    required this.backEndId,
    required this.agentId,
    required this.itinerarySteps,
  });

  /// Creates a new [Itinerary] on local data
  factory Itinerary.newLocal({
    required String agentId,
    required List<ItineraryStep> itinerarySteps,
  }) {
    return Itinerary._(
      domainId: Uuid().v4(),
      backEndId: null,
      agentId: agentId,
      itinerarySteps: itinerarySteps,
    );
  }

  /// Creates a new [Itinerary] from API data
  factory Itinerary.fromApi({
    required String domainId,
    required String backEndId,
    required String agentId,
    required List<ItineraryStep> itinerarySteps,
  }) {
    return Itinerary._(
      domainId: domainId,
      backEndId: backEndId,
      agentId: agentId,
      itinerarySteps: itinerarySteps,
    );
  }


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
    return Itinerary.fromApi(
      domainId: json['domainId'],
      backEndId: json['backEndId'],
      agentId: json['agentId'],
      itinerarySteps: json['itinerarySteps'].map((e) => ItineraryStep.fromJson(e)).toList(),
    );
  }


}
