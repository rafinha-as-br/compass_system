import 'package:travel_matrix/features/travels/domain/entities/travel.dart';

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

  RoutePlan({
    required this.domainId,
    required this.backEndId,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.destination,
    required this.interestsList,
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

  InterestPoint({
    required this.domainId,
    required this.backEndId,
    required this.name,
    required this.description,
  });

}
