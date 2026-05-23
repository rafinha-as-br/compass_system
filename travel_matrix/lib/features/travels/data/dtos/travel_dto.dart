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
      id: json[TravelApiFields.id],
      clientName: json[TravelApiFields.client],
      travelName: json[TravelApiFields.travelName],
      travelStatus: json[TravelApiFields.travelStatus],
      routePlan: json[TravelApiFields.routePlanId],
      participants: json[TravelApiFields.participantIds] ?? [],
      eventsLog: json[TravelApiFields.eventIds],
      itinerary: json[TravelApiFields.itineraryId],
    );
  }

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      TravelApiFields.id: id,
      TravelApiFields.client: clientName,
      TravelApiFields.travelName: travelName,
      TravelApiFields.travelStatus: travelStatus,
      TravelApiFields.routePlanId: routePlan,
      TravelApiFields.itineraryId: itinerary,
      TravelApiFields.participantIds: participants,
      TravelApiFields.eventIds: eventsLog,
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
      travelStatus: travel.travelStatus.toString(),
      routePlan: RoutePlanDTO.fromDomain(routePlan: travel.routePlan),
      participants: travel.participantsList.map((x) => PersonDTO.fromDomain(person: x)).toList(),
      eventsLog: travel.eventsLog?.map((x) => TravelEventDTO.fromDomain(travelEvent: x)).toList(),
      itinerary: travel.itinerary == null ? null : ItineraryDTO.fromDomain(itinerary: travel.itinerary!),
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
  Person toDomain(){
    return Person(
        domainId: Uuid().v4(),
        backendId: id,
        name: name,
        age: age,
        sex: sex
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

