import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/constants/api_fields.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/shared/models/place_suggestion.dart';
import 'date_parsing.dart';

class RoutePlanDTO {
  final String? id;
  final DateTime startDate;
  final DateTime endDate;
  final String startLocation;
  final String destination;
  final List<InterestPointDTO> interestsList;
  final PlaceCoordinate? startLocationCoordinate;
  final PlaceCoordinate? destinationCoordinate;

  RoutePlanDTO({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.startLocation,
    required this.destination,
    required this.interestsList,
    this.startLocationCoordinate,
    this.destinationCoordinate,
  });

  factory RoutePlanDTO.fromJson(Map<String, dynamic> json) {
    final startDate = parseIsoDate(json[RoutePlanApiFields.startDate]);
    return RoutePlanDTO(
      id: json[RoutePlanApiFields.id]?.toString(),
      startDate: startDate,
      endDate: parseIsoDate(json[RoutePlanApiFields.finishDate], fallback: startDate),
      startLocation: json[RoutePlanApiFields.startLocation]?.toString() ?? '',
      destination: json[RoutePlanApiFields.destination]?.toString() ?? '',
      interestsList: (json[RoutePlanApiFields.interestPoints] as List<dynamic>? ?? const [])
          .map((x) => InterestPointDTO.fromJson(x as Map<String, dynamic>))
          .toList(),
      startLocationCoordinate: PlaceCoordinate.tryFromJson(json[RoutePlanApiFields.startLocationCoordinate]),
      destinationCoordinate: PlaceCoordinate.tryFromJson(json[RoutePlanApiFields.destinationCoordinate]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      RoutePlanApiFields.id: id,
      RoutePlanApiFields.startDate: startDate.toIso8601String(),
      RoutePlanApiFields.finishDate: endDate.toIso8601String(),
      RoutePlanApiFields.startLocation: startLocation,
      RoutePlanApiFields.destination: destination,
      RoutePlanApiFields.interestPoints: interestsList.map((x) => x.toJson()).toList(),
      RoutePlanApiFields.startLocationCoordinate: startLocationCoordinate?.toJson(),
      RoutePlanApiFields.destinationCoordinate: destinationCoordinate?.toJson(),
    };
  }

  RoutePlan toDomain() {
    return RoutePlan(
      domainId: const Uuid().v4(),
      backEndId: id,
      startDate: startDate,
      endDate: endDate,
      startLocation: startLocation,
      destination: destination,
      interestsList: interestsList.map((x) => x.toDomain()).toList(),
      startLocationCoordinate: startLocationCoordinate,
      destinationCoordinate: destinationCoordinate,
    );
  }

  factory RoutePlanDTO.fromDomain(RoutePlan routePlan) {
    return RoutePlanDTO(
      id: routePlan.backEndId,
      startDate: routePlan.startDate,
      endDate: routePlan.endDate,
      startLocation: routePlan.startLocation,
      destination: routePlan.destination,
      interestsList: routePlan.interestsList.map(InterestPointDTO.fromDomain).toList(),
      startLocationCoordinate: routePlan.startLocationCoordinate,
      destinationCoordinate: routePlan.destinationCoordinate,
    );
  }
}

class InterestPointDTO {
  final String? id;
  final String name;
  final String description;
  final PlaceCoordinate? coordinate;

  InterestPointDTO({required this.id, required this.name, required this.description, this.coordinate});

  factory InterestPointDTO.fromJson(Map<String, dynamic> json) {
    return InterestPointDTO(
      id: json[InterestPointApiFields.id]?.toString(),
      name: json[InterestPointApiFields.name]?.toString() ?? '',
      description: json[InterestPointApiFields.description]?.toString() ?? '',
      coordinate: PlaceCoordinate.tryFromJson(json[InterestPointApiFields.coordinate]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      InterestPointApiFields.id: id,
      InterestPointApiFields.name: name,
      InterestPointApiFields.description: description,
      InterestPointApiFields.coordinate: coordinate?.toJson(),
    };
  }

  InterestPoint toDomain() {
    return InterestPoint(domainId: const Uuid().v4(), backEndId: id, name: name, description: description, coordinate: coordinate);
  }

  factory InterestPointDTO.fromDomain(InterestPoint interestPoint) {
    return InterestPointDTO(
      id: interestPoint.backEndId,
      name: interestPoint.name,
      description: interestPoint.description,
      coordinate: interestPoint.coordinate,
    );
  }
}
