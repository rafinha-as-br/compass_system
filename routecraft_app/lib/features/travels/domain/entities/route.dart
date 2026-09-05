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

/// A point of interest the client wants covered by the [RoutePlan].
class InterestPoint {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  final String name;
  final String description;

  InterestPoint({
    required this.domainId,
    required this.backEndId,
    required this.name,
    required this.description,
  });
}
