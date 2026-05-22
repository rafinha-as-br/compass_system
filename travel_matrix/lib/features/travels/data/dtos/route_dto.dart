import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:uuid/uuid.dart';

/// Data transfer object for [RoutePlan], having the same structure as the API.
class RoutePlanDTO {
  /// Main id used for API reference
  final String? id;
  /// Start date for the route
  final DateTime startDate;
  /// Finish date for the route
  final DateTime endDate;
  /// Start location for the route
  final String startLocation;
  /// Destination for the route
  final String destination;
  /// List of interests for the route
  final List<String?> interestsList;

  RoutePlanDTO({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.destination,
    required this.interestsList,
  });

  /// to json method
  Map<String, dynamic> toJson() {
    return {
      RoutePlanAPIConstants.id: id,
      RoutePlanAPIConstants.startDate: startDate.toIso8601String(),
      RoutePlanAPIConstants.endDate: endDate.toIso8601String(),
      RoutePlanAPIConstants.startLocation: startLocation,
      RoutePlanAPIConstants.destination: destination,
      RoutePlanAPIConstants.interestsList: interestsList,
    };
  }

  /// from json method
  factory RoutePlanDTO.fromJson(Map<String, dynamic> json) {
    return RoutePlanDTO(
      id: json[RoutePlanAPIConstants.id],
      startDate: DateTime.parse(json[RoutePlanAPIConstants.startDate]),
      endDate: DateTime.parse(json[RoutePlanAPIConstants.endDate]),
      startLocation: json[RoutePlanAPIConstants.startLocation],
      destination: json[RoutePlanAPIConstants.destination],
      interestsList: List<String>.from(json[RoutePlanAPIConstants.interestsList]),
    );
  }

  /// to domain method
  RoutePlan toDomain(List<InterestPoint> interestsList) {
    return RoutePlan(
        domainId: Uuid().v4(),
        backEndId: id,
        startDate: startDate,
        endDate: endDate,
        startLocation: startLocation,
        destination: destination,
        interestsList: interestsList
    );
  }

  /// From domain factory constructor
  factory RoutePlanDTO.fromDomain({required RoutePlan routePlan}) {
    return RoutePlanDTO(
      id: routePlan.backEndId,
      startDate: routePlan.startDate,
      endDate: routePlan.endDate,
      startLocation: routePlan.startLocation,
      destination: routePlan.destination,
      interestsList: routePlan.interestsList.map((interest) => interest.backEndId).toList(),
    );
  }


}

/// Represents a point of interest for a [RoutePlan]
class InterestPointDTO {
  /// Main id used for API reference
  final String? id;
  /// Name of the place for the interest point
  final String name;
  /// Description of the place for the interest point
  final String description;

  InterestPointDTO({
    required this.id,
    required this.name,
    required this.description,
  });

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      RoutePlanAPIConstants.id: id,
      RoutePlanAPIConstants.interestPointName: name,
      RoutePlanAPIConstants.interestPointDescription: description,
    };
  }

  /// Factory from json method
  factory InterestPointDTO.fromJson(Map<String, dynamic> json) {
    return InterestPointDTO(
      id: json[RoutePlanAPIConstants.id],
      name: json[RoutePlanAPIConstants.interestPointName],
      description: json[RoutePlanAPIConstants.interestPointDescription],
    );
  }

  /// To domain mapper method
  InterestPoint toDomain(){
    return InterestPoint(
      domainId: Uuid().v4(),
      backEndId: id,
      name: name,
      description: description,
    );
  }

  /// From domain factory constructor
  factory InterestPointDTO.fromDomain({required InterestPoint interestPoint}) {
    return InterestPointDTO(
      id: interestPoint.backEndId,
      name: interestPoint.name,
      description: interestPoint.description,
    );
  }

}

class RoutePlanAPIConstants{
  /// Main id field
  static const String id = 'id';
  /// Start date for the route field
  static const String startDate = 'startDate';
  /// Finish date for the route field
  static const String endDate = 'endDate';
  /// Start location for the route field
  static const String startLocation = 'startLocation';
  /// Destination for the route field
  static const String destination = 'destination';
  /// List of interests for the route field
  static const String interestsList = 'interestsListIds';
  /// Interest point name field
  static const String interestPointName = 'name';
  /// Interest point description field
  static const String interestPointDescription = 'description';

}
