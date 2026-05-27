import 'package:travel_matrix/features/travels/domain/entities/travel_event.dart';

import 'itinerary.dart';
import 'person.dart';
import 'route.dart';

enum TravelStatus {
  routeCreated, // -> Needs itinerary
  itineraryCreated, // -> Travel ready to be started at the date
  travelStarted, // -> travel in progress
  travelFinished;

  /// Converts enum to API string
  String toApiValue() {
    switch (this) {
      case TravelStatus.routeCreated:
        return 'route_created';
      case TravelStatus.itineraryCreated:
        return 'itinerary_created';
      case TravelStatus.travelStarted:
        return 'travel_started';
      case TravelStatus.travelFinished:
        return 'travel_finished';
    }
  }

  /// Converts API string to enum
  static TravelStatus fromApiValue(String value) {
    switch (value) {
      case 'planned':
      case 'route_created':
        return TravelStatus.routeCreated;
      case 'itinerary_created':
        return TravelStatus.itineraryCreated;
      case 'travel_started':
        return TravelStatus.travelStarted;
      case 'travel_finished':
        return TravelStatus.travelFinished;
      default:
        throw Exception('Invalid TravelStatus value: $value');
    }
  }
}

/// Main object of the system,
class Travel {
  /// Main id used for local reference
  final String domainId;

  /// Main id used for API reference
  final String? backEndId;

  /// Client id that created the travel
  final String clientName;

  /// Travel name
  final String travelName;

  /// Travel status
  TravelStatus travelStatus;

  /// Route plan for the travel
  final RoutePlan routePlan;

  /// Itinerary for the travel
  final Itinerary? itinerary;

  /// participants list
  final List<Person> participantsList;

  /// Travel events log list, these events are done by the Client user
  final List<TravelEvent>? eventsLog;

  Travel({
    required this.domainId,
    required this.backEndId,
    required this.clientName,
    required this.travelName,
    required this.routePlan,
    required this.participantsList,
    required this.travelStatus,
    this.itinerary,
    this.eventsLog,
  });
}
