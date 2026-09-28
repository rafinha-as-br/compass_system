import 'package:routecraft_app/shared/models/place_suggestion.dart';

/// Represents the trip plan the client writes for a [Travel] — origin,
/// destination, dates and points of interest — before the agent builds an
/// itinerary on top of it.
class RoutePlan {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String destination;
  final List<InterestPoint> interestsList;

  /// Chosen via the places autocomplete (CPS-154) — null for routes created
  /// or last edited before CPS-144, or when the client typed free text
  /// without picking a suggestion.
  final PlaceCoordinate? startLocationCoordinate;
  final PlaceCoordinate? destinationCoordinate;

  RoutePlan({
    required this.domainId,
    required this.backEndId,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.destination,
    required this.interestsList,
    this.startLocationCoordinate,
    this.destinationCoordinate,
  });
}

/// A point of interest the client wants covered by the [RoutePlan].
class InterestPoint {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  final String name;
  final String description;

  /// Chosen via the places autocomplete (CPS-154) — null for points added
  /// before CPS-144, or free text without a picked suggestion.
  final PlaceCoordinate? coordinate;

  InterestPoint({
    required this.domainId,
    required this.backEndId,
    required this.name,
    required this.description,
    this.coordinate,
  });
}
