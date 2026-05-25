
import 'package:travel_matrix/features/travels/domain/entities/travel_event.dart';

class TravelEventViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final TravelEventTypeViewModel type;
  final String date;
  final String description;

  TravelEventViewModel({
    required this.backEndId,
    required this.localId,
    required this.type,
    required this.date,
    required this.description,
  });

  /// Factory constructor from domain model
  factory TravelEventViewModel.fromDomain(TravelEvent event){
    return TravelEventViewModel(
      backEndId: event.backEndId,
      localId: event.domainId,
      type: TravelEventTypeViewModel.fromDomain(event.type),
      date: event.date.toIso8601String(),
      description: event.description,
    );
  }

  /// To domain mapper method
  TravelEvent toDomain(){
    return TravelEvent(
      domainId: localId,
      backEndId: backEndId,
      type: type.toDomain(),
      date: DateTime.parse(date),
      description: description,
    );
  }
}

enum TravelEventTypeViewModel {
  travelStarted,
  travelFinished,

  stepCompleted,
  stepSkipped,

  hostingCheckInCompleted,
  hostingCheckOutCompleted,

  transportStarted,
  transportCompleted,

  transportDelayed,
  transportCancelled;

  /// Converts [TravelEventType] domain enum
  /// to [TravelEventTypeViewModel]
  static TravelEventTypeViewModel fromDomain(
      TravelEventType type,
      ) {
    switch (type) {
      case TravelEventType.travelStarted:
        return TravelEventTypeViewModel.travelStarted;

      case TravelEventType.travelFinished:
        return TravelEventTypeViewModel.travelFinished;

      case TravelEventType.stepCompleted:
        return TravelEventTypeViewModel.stepCompleted;

      case TravelEventType.stepSkipped:
        return TravelEventTypeViewModel.stepSkipped;

      case TravelEventType.hostingCheckInCompleted:
        return TravelEventTypeViewModel.hostingCheckInCompleted;

      case TravelEventType.hostingCheckOutCompleted:
        return TravelEventTypeViewModel.hostingCheckOutCompleted;

      case TravelEventType.transportStarted:
        return TravelEventTypeViewModel.transportStarted;

      case TravelEventType.transportCompleted:
        return TravelEventTypeViewModel.transportCompleted;

      case TravelEventType.transportDelayed:
        return TravelEventTypeViewModel.transportDelayed;

      case TravelEventType.transportCancelled:
        return TravelEventTypeViewModel.transportCancelled;
    }
  }

  /// Converts [TravelEventTypeViewModel]
  /// to [TravelEventType] domain enum
  TravelEventType toDomain() {
    switch (this) {
      case TravelEventTypeViewModel.travelStarted:
        return TravelEventType.travelStarted;

      case TravelEventTypeViewModel.travelFinished:
        return TravelEventType.travelFinished;

      case TravelEventTypeViewModel.stepCompleted:
        return TravelEventType.stepCompleted;

      case TravelEventTypeViewModel.stepSkipped:
        return TravelEventType.stepSkipped;

      case TravelEventTypeViewModel.hostingCheckInCompleted:
        return TravelEventType.hostingCheckInCompleted;

      case TravelEventTypeViewModel.hostingCheckOutCompleted:
        return TravelEventType.hostingCheckOutCompleted;

      case TravelEventTypeViewModel.transportStarted:
        return TravelEventType.transportStarted;

      case TravelEventTypeViewModel.transportCompleted:
        return TravelEventType.transportCompleted;

      case TravelEventTypeViewModel.transportDelayed:
        return TravelEventType.transportDelayed;

      case TravelEventTypeViewModel.transportCancelled:
        return TravelEventType.transportCancelled;
    }
  }
}

