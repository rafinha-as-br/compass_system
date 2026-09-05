import 'itinerary.dart';
import 'person.dart';
import 'route.dart';

enum TravelStatus {
  routeCreated,
  itineraryCreated,
  travelStarted,
  travelFinished;

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

  static TravelStatus fromApiValue(String? value) {
    switch (value) {
      case 'itinerary_created':
        return TravelStatus.itineraryCreated;
      case 'travel_started':
        return TravelStatus.travelStarted;
      case 'travel_finished':
        return TravelStatus.travelFinished;
      default:
        return TravelStatus.routeCreated;
    }
  }
}

/// A trip: the client's [RoutePlan] plus, once the agent has built one, an
/// [Itinerary]. The client creates and refines the route; the itinerary is
/// read-only here — building it is exclusive to the agent in Travel Matrix.
class Travel {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  final String clientName;
  final String travelName;
  TravelStatus travelStatus;
  final RoutePlan routePlan;
  final Itinerary? itinerary;
  final List<Person> participantsList;

  Travel({
    required this.domainId,
    required this.backEndId,
    required this.clientName,
    required this.travelName,
    required this.travelStatus,
    required this.routePlan,
    required this.participantsList,
    this.itinerary,
  });

  /// True once the agent has moved the travel past the initial route-only
  /// stage — see `Regra de Negócio - Ciclo de Vida da Viagem`.
  bool get hasItinerary => travelStatus != TravelStatus.routeCreated;
}
