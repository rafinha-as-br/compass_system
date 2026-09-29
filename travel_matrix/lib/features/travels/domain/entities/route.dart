import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/shared/models/place_suggestion.dart';

/// Represents the abstract plan for a [Travel], created by a client on RouteCraft App.
class RoutePlan {
  /// Id used for local reference
  final String domainId;
  /// Id used reference on the Compass API
  final String? backEndId;
  /// Suggested date to start the travel
  final DateTime startDate;
  /// Suggested date to finish the travel
  final DateTime endDate;
  /// Suggested start location for the travel
  final String startLocation;
  /// Suggested destination for the travel
  final String destination;
  /// Suggested list of interests for the travel
  final List<InterestPoint> interestsList;

  /// Chosen via the places autocomplete (CPS-154) — null for routes created
  /// or last edited before CPS-144, or when free text was typed without
  /// picking a suggestion.
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

/// Represents a point of interest for a [RoutePlan]
class InterestPoint {
  /// Id used for local reference
  final String domainId;
  /// Id used reference on the Compass API
  final String? backEndId;
  /// Name of the place for the interest point
  final String name;
  /// Description of the place for the interest point
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
