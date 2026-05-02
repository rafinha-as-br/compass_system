class RoutePlan {
  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String destination;
  final List<InterestPoint> interestsList;

  RoutePlan({
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.destination,
    required this.interestsList,
  });
}

class InterestPoint {
  final String id;
  final String name;
  final String description;

  InterestPoint({
    required this.id,
    required this.name,
    required this.description,
  });
}
