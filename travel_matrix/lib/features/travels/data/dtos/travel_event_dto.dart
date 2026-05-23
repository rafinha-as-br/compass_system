import 'package:uuid/uuid.dart';

import '../../domain/entities/travel_event.dart';

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
      TravelEventAPIConstants.id: id,
      TravelEventAPIConstants.eventType: eventType,
      TravelEventAPIConstants.eventDate: eventDate.toIso8601String(),
      TravelEventAPIConstants.eventDescription: eventDescription,
    };
  }

  /// From json method
  factory TravelEventDTO.fromJson(Map<String, dynamic> json) {
    return TravelEventDTO(
      id: json[TravelEventAPIConstants.id ],
      eventType: json[TravelEventAPIConstants.eventType],
      eventDate: DateTime.parse(json[TravelEventAPIConstants.eventDate]),
      eventDescription: json[TravelEventAPIConstants.eventDescription],
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
      eventType: travelEvent.type.toString(),
      eventDate: travelEvent.date,
      eventDescription: travelEvent.description,
    );
  }

}

class TravelEventAPIConstants{
  static const String id = 'id';
  static const String eventType = 'eventType';
  static const String eventDate = 'eventDate';
  static const String eventDescription = 'eventDescription';
}