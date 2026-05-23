import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_matrix/core/constants/api_fields.dart';

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
  final List<InterestPointDTO> interestsList;

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
      RoutePlanApiFields.id: id,
      RoutePlanApiFields.startDate: startDate.toIso8601String(),
      RoutePlanApiFields.finishDate: endDate.toIso8601String(),
      RoutePlanApiFields.startLocation: startLocation,
      RoutePlanApiFields.destination: destination,
      RoutePlanApiFields.interestPoints: interestsList.map((x) => x.toJson()).toList(),
    };
  }

  /// from json method
  factory RoutePlanDTO.fromJson(Map<String, dynamic> json) {
    return RoutePlanDTO(
      id: json[RoutePlanApiFields.id],
      startDate: DateTime.parse(json[RoutePlanApiFields.startDate]),
      endDate: DateTime.parse(json[RoutePlanApiFields.finishDate]),
      startLocation: json[RoutePlanApiFields.startLocation],
      destination: json[RoutePlanApiFields.destination],
      interestsList: List<InterestPointDTO>.from(
        json[RoutePlanApiFields.interestPoints].map(
          (x) => InterestPointDTO.fromJson(x),
        )
      )
    );
  }

  /// to domain method
  RoutePlan toDomain() {
    return RoutePlan(
        domainId: Uuid().v4(),
        backEndId: id,
        startDate: startDate,
        endDate: endDate,
        startLocation: startLocation,
        destination: destination,
        interestsList: interestsList.map((x) => x.toDomain()).toList()
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
      interestsList: routePlan.interestsList.map((x) => InterestPointDTO.fromDomain(interestPoint: x)).toList(),
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
      CommonApiFields.id: id,
      InterestPointApiFields.name: name,
      InterestPointApiFields.description: description,
    };
  }

  /// Factory from json method
  factory InterestPointDTO.fromJson(Map<String, dynamic> json) {
    return InterestPointDTO(
      id: json[CommonApiFields.id],
      name: json[InterestPointApiFields.name],
      description: json[InterestPointApiFields.description],
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


