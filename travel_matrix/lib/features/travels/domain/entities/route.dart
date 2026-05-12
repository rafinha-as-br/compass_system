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

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startLocation': startLocation,
      'destination': destination,
      'interestsList': interestsList.map((e) => e.toJson()).toList(),
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
