
import '../../domain/entities/travel_summary.dart';

/// View model class for [TravelSummary]
class TravelSummaryViewModel{
  final String backEndId;
  final String domainId;
  final String travelName;
  final String destination;
  final String status;
  final DateTime startDate;

  TravelSummaryViewModel({
    required this.backEndId,
    required this.domainId,
    required this.travelName,
    required this.destination,
    required this.status,
    required this.startDate,
  });

  /// From domain mapper method
  factory TravelSummaryViewModel.fromDomain(TravelSummary travel){
    return TravelSummaryViewModel(
      backEndId: travel.backEndId,
      domainId: travel.domainId,
      travelName: travel.travelName,
      destination: travel.destination,
      status: travel.status,
      startDate: travel.startDate,
    );
  }

  /// To domain mapper method
  TravelSummary toDomain(){
    return TravelSummary(
      backEndId: backEndId,
      domainId: domainId,
      travelName: travelName,
      destination: destination,
      status: status,
      startDate: startDate,
    );
  }
}