import 'package:uuid/uuid.dart';

import '../../domain/entities/travel_event.dart';
import 'package:travel_matrix/core/constants/api_fields.dart';

/// Data transfer object for [TravelEvent], having the same structure as the API.
class TravelEventDTO{
  /// Main id used for API reference
  final String? id;
  /// Event type
  final String eventType;
  /// Event date
  final DateTime eventDate;
  /// Event description
  final String eventDescription;

  TravelEventDTO({
    required this.id,
    required this.eventType,
    required this.eventDate,
    required this.eventDescription,
  });

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      TravelEventApiFields.id: id,
      TravelEventApiFields.eventType: eventType,
      TravelEventApiFields.eventDate: eventDate.toIso8601String(),
      TravelEventApiFields.eventDescription: eventDescription,
    };
  }

  /// From json method
  factory TravelEventDTO.fromJson(Map<String, dynamic> json) {
    return TravelEventDTO(
      id: json[TravelEventApiFields.id ],
      eventType: json[TravelEventApiFields.eventType],
      eventDate: DateTime.parse(json[TravelEventApiFields.eventDate]),
      eventDescription: json[TravelEventApiFields.eventDescription],
    );
  }

  /// To domain mapper method
  TravelEvent toDomain() {
    return TravelEvent(
        domainId: Uuid().v4(),
        backEndId: id,
        date: eventDate,
        type: TravelEventType.fromApiValue(eventType),
        description: eventDescription
    );
  }

  /// From domain factory constructor
  factory TravelEventDTO.fromDomain({required TravelEvent travelEvent}) {
    return TravelEventDTO(
      id: travelEvent.backEndId,
      eventType: travelEvent.type.toApiValue(),
      eventDate: travelEvent.date,
      eventDescription: travelEvent.description,
    );
  }

}