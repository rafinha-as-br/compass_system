class InterestPoint {
  final String id;
  final String routeId;
  final String name;
  final String description;
  final String geographicLocation;

  InterestPoint({
    required this.id,
    required this.routeId,
    required this.name,
    required this.description,
    required this.geographicLocation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeId': routeId,
      'name': name,
      'description': description,
      'geographicLocation': geographicLocation,
    };
  }
}

class RoutePlan {
  final String id;
  final String clientId;
  final String tripName;
  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String destination;
  final List<String> interestsList;
  final List<InterestPoint> pointsOfInterest;

  RoutePlan({
    required this.id,
    required this.clientId,
    required this.tripName,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.destination,
    required this.interestsList,
    this.pointsOfInterest = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'tripName': tripName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startLocation': startLocation,
      'destination': destination,
      'interestsList': interestsList,
      'pointsOfInterest': pointsOfInterest.map((p) => p.toMap()).toList(),
    };
  }
}
