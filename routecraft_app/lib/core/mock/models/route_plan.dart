import 'interest_point.dart';

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
    required List<InterestPoint> interestsList,
  }) : interestsList = List.unmodifiable(interestsList);

  Map<String, dynamic> toMap() => {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'startLocation': startLocation,
        'destination': destination,
        'interestsList': interestsList.map((poi) => poi.toMap()).toList(),
      };

  factory RoutePlan.fromJson(Map<String, dynamic> json) {
    return RoutePlan(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      startLocation: json['startLocation'] as String,
      destination: json['destination'] as String,
      interestsList: (json['interestsList'] as List<dynamic>? ?? [])
          .map((poi) => InterestPoint.fromJson(poi as Map<String, dynamic>))
          .toList(),
    );
  }
}
