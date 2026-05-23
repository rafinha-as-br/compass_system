import 'package:travel_matrix/features/travels/data/dtos/itinerary_dto.dart';
import 'package:travel_matrix/features/travels/data/dtos/route_dto.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_event_dto.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/travel.dart';
import '../../domain/entities/person.dart';

/// Data transfer object for [Travel], having the same structure as the API.
class TravelDTO {
  /// Main id used for API reference
  final String? id;
  /// Client id that created the travel
  final String clientId;
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
    required this.clientId,
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
      id: json[TravelAPIConstants.id],
      clientId: json[TravelAPIConstants.clientId],
      travelName: json[TravelAPIConstants.travelName],
      travelStatus: json[TravelAPIConstants.travelStatus],
      routePlan: json[TravelAPIConstants.routePlanId],
      participants: json[TravelAPIConstants.participantsListIds] ?? [],
      eventsLog: json[TravelAPIConstants.eventsLogIds],
      itinerary: json[TravelAPIConstants.itineraryId],
    );
  }

  /// To json method
  Map<String, dynamic> toJson() {
    return {
      TravelAPIConstants.id: id,
      TravelAPIConstants.clientId: clientId,
      TravelAPIConstants.travelName: travelName,
      TravelAPIConstants.travelStatus: travelStatus,
      TravelAPIConstants.routePlanId: routePlan,
      TravelAPIConstants.itineraryId: itinerary,
      TravelAPIConstants.participantsListIds: participants,
      TravelAPIConstants.eventsLogIds: eventsLog,
    };
  }

  /// To domain mapper method
  Travel toDomain() {
    return Travel(
      domainId: Uuid().v4(),
      backEndId: id,
      clientId: clientId,
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
      clientId: travel.clientId,
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
      PersonAPIConstants.id: id,
      PersonAPIConstants.name: name,
      PersonAPIConstants.age: age,
      PersonAPIConstants.sex: sex,
    };
  }

  factory PersonDTO.fromJson(Map<String, dynamic> json) {
    return PersonDTO(
      id: json[PersonAPIConstants.id],
      name: json[PersonAPIConstants.name],
      age: json[PersonAPIConstants.age],
      sex: json[PersonAPIConstants.sex],
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

/// Contains the constants field names from the API
class TravelAPIConstants{
  static const String id = 'id';
  static const String clientId = 'clientId';
  static const String travelName = 'travelName';
  static const String travelStatus = 'travelStatus';
  static const String startDate = 'startDate';
  static const String finishDate = 'finishDate';
  static const String routePlanId = 'routePlanId';
  static const String itineraryId = 'itineraryId';
  static const String participantsListIds = 'participantsListIds';
  static const String eventsLogIds = 'eventsLogIds';
}

class PersonAPIConstants{
  static const String id = 'id';
  static const String name = 'name';
  static const String age = 'age';
  static const String sex = 'sex';
}