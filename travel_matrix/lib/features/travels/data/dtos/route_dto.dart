
import 'package:travel_matrix/features/travels/domain/entities/route.dart';

class RoutePlanDTO {
  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String destination;
  final List<String> interestsListId;

  RoutePlanDTO({
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.destination,
    required this.interestsListId,
  });

  /// to json method
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'startLocation': startLocation,
      'destination': destination,
      'interestsListId': interestsListId,
    };
  }
  /// from json method
  factory RoutePlanDTO.fromJson(Map<String, dynamic> json) {
    return RoutePlanDTO(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      startLocation: json['startLocation'],
      destination: json['destination'],
      interestsListId: List<String>.from(json['interestsListId']),
    );
  }

  /// to domain method
  RoutePlan toDomain(List<InterestPoint> interestsList) {
    return RoutePlan(
      startDate: startDate,
      endDate: endDate,
      startLocation: startLocation,
      destination: destination,
      interestsList: interestsList,
    );
  }


}

class InterestPointDTO {
  final String id;
  final String name;
  final String description;

  InterestPointDTO({
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

  factory InterestPointDTO.fromJson(Map<String, dynamic> json) {
    return InterestPointDTO(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  InterestPoint toDomain(){
    return InterestPoint(
      id: id,
      name: name,
      description: description,
    );
  }


}
