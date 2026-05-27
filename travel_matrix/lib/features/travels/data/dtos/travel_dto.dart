import 'package:travel_matrix/features/travels/data/dtos/itinerary_dto.dart';
import 'package:travel_matrix/features/travels/data/dtos/route_dto.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_event_dto.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/travel.dart';
import '../../domain/entities/person.dart';
import 'package:travel_matrix/core/constants/api_fields.dart';

/// Data transfer object for [Travel], having the same structure as the API.
class TravelDTO {
  /// Main id used for API reference
  final String? id;

  /// Client name that created the travel
  final String clientName;

  /// Travel main name
  final String travelName;

  /// Travel status
  final String travelStatus;

  /// Route plan back end id for the travel
  final RoutePlanDTO routePlan;

  /// Itinerary DTO
  final ItineraryDTO? itinerary;
  // Participants DTO list in the travel
  final List<PersonDTO> participants;

  /// Travel events DTO list
  final List<TravelEventDTO>? eventsLog;

  TravelDTO({
    required this.id,
    required this.clientName,
    required this.travelName,
    required this.travelStatus,
    required this.routePlan,
    required this.participants,
    this.eventsLog,
    this.itinerary,
  });

  /// From json factory constructor
  factory TravelDTO.fromJson(Map<String, dynamic> json) {
    return TravelDTO(
      id: json[TravelApiFields.id] as String?,
      clientName: (json[TravelApiFields.client] as String?) ?? '',
      travelName: (json[TravelApiFields.travelName] as String?) ?? '',
      travelStatus:
          (json[TravelApiFields.travelStatus] as String?) ?? 'route_created',
      routePlan: json[TravelApiFields.routePlan] != null
          ? RoutePlanDTO.fromJson(
              Map<String, dynamic>.from(json[TravelApiFields.routePlan] as Map),
            )
          : RoutePlanDTO.empty(),
      participants: _participantsFromJson(json[TravelApiFields.participants]),
      eventsLog: _eventsFromJson(json[TravelApiFields.events]),
      itinerary: json[TravelApiFields.itinerary] == null
          ? null
          : ItineraryDTO.fromJson(
              Map<String, dynamic>.from(json[TravelApiFields.itinerary] as Map),
            ),
    );
  }

  static List<PersonDTO> _participantsFromJson(Object? value) {
    if (value is! Iterable) return <PersonDTO>[];

    return <PersonDTO>[
      for (final item in value)
        PersonDTO.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  static List<TravelEventDTO>? _eventsFromJson(Object? value) {
    if (value == null) return null;
    if (value is! Iterable) return <TravelEventDTO>[];

    return <TravelEventDTO>[
      for (final item in value)
        TravelEventDTO.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      TravelApiFields.id: id,
      TravelApiFields.client: clientName,
      TravelApiFields.travelName: travelName,
      TravelApiFields.travelStatus: travelStatus,
      TravelApiFields.routePlan: routePlan.toJson(),
      TravelApiFields.itinerary: itinerary?.toJson(),
      TravelApiFields.participants: participants
          .map((x) => x.toJson())
          .toList(),
      TravelApiFields.events: eventsLog?.map((x) => x.toJson()).toList(),
    };
  }

  /// To domain mapper method
  Travel toDomain() {
    return Travel(
      domainId: Uuid().v4(),
      backEndId: id,
      clientName: clientName,
      travelName: travelName,
      routePlan: routePlan.toDomain(),
      participantsList: participants.map((x) => x.toDomain()).toList(),
      travelStatus: TravelStatus.fromApiValue(travelStatus),
      eventsLog: eventsLog?.map((x) => x.toDomain()).toList(),
      itinerary: itinerary?.toDomain(),
    );
  }

  /// From domain factory constructor
  factory TravelDTO.fromDomain({required Travel travel}) {
    return TravelDTO(
      id: travel.backEndId,
      clientName: travel.clientName,
      travelName: travel.travelName,
      travelStatus: travel.travelStatus.toApiValue(),
      routePlan: RoutePlanDTO.fromDomain(routePlan: travel.routePlan),
      participants: travel.participantsList
          .map((x) => PersonDTO.fromDomain(person: x))
          .toList(),
      eventsLog: travel.eventsLog
          ?.map((x) => TravelEventDTO.fromDomain(travelEvent: x))
          .toList(),
      itinerary: travel.itinerary == null
          ? null
          : ItineraryDTO.fromDomain(itinerary: travel.itinerary!),
    );
  }
}

/// Data transfer object for [Person], having the same structure as the API.
class PersonDTO {
  /// Main id used for API reference
  final String? id;

  /// Person name
  final String name;

  /// Person age
  final String age;

  /// Person sex
  final String sex;

  PersonDTO({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
  });

  Map<String, dynamic> toJson() {
    return {
      PersonApiFields.id: id,
      PersonApiFields.name: name,
      PersonApiFields.age: age,
      PersonApiFields.sex: sex,
    };
  }

  factory PersonDTO.fromJson(Map<String, dynamic> json) {
    return PersonDTO(
      id: json[PersonApiFields.id],
      name: json[PersonApiFields.name],
      age: json[PersonApiFields.age],
      sex: json[PersonApiFields.sex],
    );
  }

  /// To domain mapper method
  Person toDomain() {
    return Person(
      domainId: Uuid().v4(),
      backendId: id,
      name: name,
      age: age,
      sex: sex,
    );
  }

  /// From domain factory constructor
  factory PersonDTO.fromDomain({required Person person}) {
    return PersonDTO(
      id: person.backendId,
      name: person.name,
      age: person.age,
      sex: person.sex,
    );
  }
}
