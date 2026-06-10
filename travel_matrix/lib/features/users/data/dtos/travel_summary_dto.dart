
import 'package:travel_matrix/features/users/domain/entities/travel_summary.dart';
import 'package:uuid/uuid.dart';

/// DTO for [TravelSummary]
class TravelSummaryDTO{
  final String backEndId;
  final String travelName;
  final String destination;
  final String status;
  final DateTime startDate;

  TravelSummaryDTO({
    required this.backEndId,
    required this.travelName,
    required this.destination,
    required this.status,
    required this.startDate,
  });

  /// From domain mapper method
  factory TravelSummaryDTO.fromDomain(TravelSummary travel){
    return TravelSummaryDTO(
      backEndId: travel.backEndId,
      travelName: travel.travelName,
      destination: travel.destination,
      status: travel.status,
      startDate: travel.startDate,
    );
  }

  /// to Domain mapper method
  TravelSummary toDomain(){
    return TravelSummary(
      backEndId: backEndId,
      domainId: Uuid().v4(),
      travelName: travelName,
      destination: destination,
      status: status,
      startDate: startDate,
    );
  }

  /// From json factory method
  factory TravelSummaryDTO.fromJson(Map<String, dynamic> json){
    return TravelSummaryDTO(
      backEndId: json['backEndId'],
      travelName: json['travelName'],
      destination: json['destination'],
      status: json['status'],
      startDate: DateTime.parse(json['startDate']),
    );
  }

}