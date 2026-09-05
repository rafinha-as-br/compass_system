import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/constants/api_fields.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'itinerary_dto.dart';
import 'route_dto.dart';

class TravelDTO {
  final String? id;
  final String clientName;
  final String travelName;
  final String travelStatus;
  final RoutePlanDTO routePlan;
  final ItineraryDTO? itinerary;
  final List<PersonDTO> participants;

  TravelDTO({
    required this.id,
    required this.clientName,
    required this.travelName,
    required this.travelStatus,
    required this.routePlan,
    required this.participants,
    this.itinerary,
  });

  factory TravelDTO.fromJson(Map<String, dynamic> json) {
    final itinerary = json[TravelApiFields.itinerary];
    return TravelDTO(
      id: json[TravelApiFields.id]?.toString(),
      clientName: json[TravelApiFields.clientName]?.toString() ?? '',
      travelName: json[TravelApiFields.travelName]?.toString() ?? '',
      travelStatus: json[TravelApiFields.travelStatus]?.toString() ?? 'route_created',
      routePlan: RoutePlanDTO.fromJson(
        json[TravelApiFields.routePlan] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      participants: (json[TravelApiFields.participants] as List<dynamic>? ?? const [])
          .map((x) => PersonDTO.fromJson(x as Map<String, dynamic>))
          .toList(),
      itinerary: itinerary == null ? null : ItineraryDTO.fromJson(itinerary as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      TravelApiFields.id: id,
      TravelApiFields.clientName: clientName,
      TravelApiFields.travelName: travelName,
      TravelApiFields.travelStatus: travelStatus,
      TravelApiFields.routePlan: routePlan.toJson(),
      TravelApiFields.itinerary: itinerary?.toJson(),
      TravelApiFields.participants: participants.map((x) => x.toJson()).toList(),
    };
  }

  Travel toDomain() {
    return Travel(
      domainId: const Uuid().v4(),
      backEndId: id,
      clientName: clientName,
      travelName: travelName,
      travelStatus: TravelStatus.fromApiValue(travelStatus),
      routePlan: routePlan.toDomain(),
      participantsList: participants.map((x) => x.toDomain()).toList(),
      itinerary: itinerary?.toDomain(),
    );
  }

  factory TravelDTO.fromDomain(Travel travel) {
    return TravelDTO(
      id: travel.backEndId,
      clientName: travel.clientName,
      travelName: travel.travelName,
      travelStatus: travel.travelStatus.toApiValue(),
      routePlan: RoutePlanDTO.fromDomain(travel.routePlan),
      participants: travel.participantsList.map(PersonDTO.fromDomain).toList(),
    );
  }
}

class PersonDTO {
  final String? id;
  final String name;
  final String age;
  final String sex;

  PersonDTO({required this.id, required this.name, required this.age, required this.sex});

  factory PersonDTO.fromJson(Map<String, dynamic> json) {
    return PersonDTO(
      id: json[PersonApiFields.id]?.toString(),
      name: json[PersonApiFields.name]?.toString() ?? '',
      age: json[PersonApiFields.age]?.toString() ?? '',
      sex: json[PersonApiFields.sex]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      PersonApiFields.id: id,
      PersonApiFields.name: name,
      PersonApiFields.age: age,
      PersonApiFields.sex: sex,
    };
  }

  Person toDomain() {
    return Person(domainId: const Uuid().v4(), backEndId: id, name: name, age: age, sex: sex);
  }

  factory PersonDTO.fromDomain(Person person) {
    return PersonDTO(id: person.backEndId, name: person.name, age: person.age, sex: person.sex);
  }
}
