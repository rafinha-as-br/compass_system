
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';

/// Represents a completion of something from the [Travel]
class TravelEvent {
  /// Main id used for local reference
  final String domainId;
  /// Main id used for API reference
  final String? backEndId;
  /// Date that happened the event
  final DateTime date;
  /// Type of event
  final TravelEventType type;
  /// Description of the event
  final String description;

  TravelEvent({
    required this.domainId,
    required this.backEndId,
    required this.date,
    required this.type,
    required this.description,
  });


}

/// Type of travel events that can occur in a [Travel]
enum TravelEventType {
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

  /// Converts enum to API string
  String toApiValue() {
    switch (this) {
      case TravelEventType.travelStarted:
        return 'travel_started';

      case TravelEventType.travelFinished:
        return 'travel_finished';

      case TravelEventType.stepCompleted:
        return 'step_completed';

      case TravelEventType.stepSkipped:
        return 'step_skipped';

      case TravelEventType.hostingCheckInCompleted:
        return 'hosting_check_in_completed';

      case TravelEventType.hostingCheckOutCompleted:
        return 'hosting_check_out_completed';

      case TravelEventType.transportStarted:
        return 'transport_started';

      case TravelEventType.transportCompleted:
        return 'transport_completed';

      case TravelEventType.transportDelayed:
        return 'transport_delayed';

      case TravelEventType.transportCancelled:
        return 'transport_cancelled';
    }
  }

  /// Converts API string to enum
  static TravelEventType fromApiValue(String value) {
    switch (value) {
      case 'travel_started':
        return TravelEventType.travelStarted;

      case 'travel_finished':
        return TravelEventType.travelFinished;

      case 'step_completed':
        return TravelEventType.stepCompleted;

      case 'step_skipped':
        return TravelEventType.stepSkipped;

      case 'hosting_check_in_completed':
        return TravelEventType.hostingCheckInCompleted;

      case 'hosting_check_out_completed':
        return TravelEventType.hostingCheckOutCompleted;

      case 'transport_started':
        return TravelEventType.transportStarted;

      case 'transport_completed':
        return TravelEventType.transportCompleted;

      case 'transport_delayed':
        return TravelEventType.transportDelayed;

      case 'transport_cancelled':
        return TravelEventType.transportCancelled;

      default:
        throw Exception(
          'Invalid TravelEventType value: $value',
        );
    }
  }
}