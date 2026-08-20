import 'route_plan.dart';
import 'travel_status.dart';

class Travel {
  final String id;
  final String clientId;
  final String agentId;
  final String travelName;
  final TravelStatus travelStatus;
  final List<String> participantsList;
  final RoutePlan routePlan;

  Travel({
    required this.id,
    required this.clientId,
    required this.agentId,
    required this.travelName,
    required this.travelStatus,
    required List<String> participantsList,
    required this.routePlan,
  }) : participantsList = List.unmodifiable(participantsList);

  /// A travel is considered to have an itinerary once it has moved past the
  /// initial route-only stage.
  bool get hasItinerary => travelStatus != TravelStatus.routeCreated;

  factory Travel.fromJson(Map<String, dynamic> json) {
    return Travel(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      agentId: json['agentId'] as String,
      travelName: json['travelName'] as String,
      travelStatus: TravelStatus.fromName(json['travelStatus'] as String?),
      participantsList: (json['participantsList'] as List<dynamic>? ?? [])
          .map((p) => p as String)
          .toList(),
      routePlan: RoutePlan.fromJson(json['routePlan'] as Map<String, dynamic>),
    );
  }
}
