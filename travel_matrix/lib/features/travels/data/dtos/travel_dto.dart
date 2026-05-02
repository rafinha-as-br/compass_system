
import '../../domain/entities/travel.dart';
import '../../domain/entities/route.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/itinerary.dart';

class TravelDTO {
  final String id;
  final String clientId;
  final String agentId;
  final String travelName;
  final String travelStatus;

  /// real travel start date
  DateTime? startDate;

  /// real travel finish date
  DateTime? finishDate;

  final String routePlanId;
  final String? itineraryId;

  // participants list
  final List<String> participantsListIds;


  TravelDTO({
    required this.id,
    required this.clientId,
    required this.agentId,
    required this.travelName,
    required this.travelStatus,
    required this.routePlanId,
    required this.participantsListIds,
    this.startDate,
    this.finishDate,
    this.itineraryId,
  });


  factory TravelDTO.fromJson(Map<String, dynamic> json) {
    return TravelDTO(
      id: json['id'],
      clientId: json['clientId'],
      agentId: json['agentId'],
      travelName: json['travelName'],
      travelStatus: json['travelStatus'],
      routePlanId: json['routePlanId'],
      participantsListIds: json['participantsListIds'] ?? [],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      finishDate: json['finishDate'] != null ? DateTime.parse(json['finishDate']) : null,
      itineraryId: json['itineraryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'agentId': agentId,
      'travelName': travelName,
      'travelStatus': travelStatus,
      'startDate': startDate?.toIso8601String(),
      'finishDate': finishDate?.toIso8601String(),
      'routePlanId': routePlanId,
      'itineraryId': itineraryId,
      'participantsListIds': participantsListIds,
    };
  }

  Travel toDomain(RoutePlan routePlan, List<Person> participants, {Itinerary? itinerary}) {
    return Travel(
      id: id,
      clientId: clientId,
      travelName: travelName,
      travelStatus: TravelStatus.values.firstWhere(
        (e) => e.toString().split('.').last == travelStatus,
        orElse: () => TravelStatus.routeCreated,
      ),
      routePlan: routePlan,
      participantsList: participants,
      startDate: startDate,
      finishDate: finishDate,
      itinerary: itinerary,
    );
  }


}

class PersonDTO {
  final String id;
  final String name;
  final String age;
  final String sex;

  PersonDTO({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'sex': sex,
    };
  }

  factory PersonDTO.fromJson(Map<String, dynamic> json) {
    return PersonDTO(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      sex: json['sex'],
    );
  }

  Person toDomain(){
    return Person(
      id: id,
      name: name,
      age: age,
      sex: sex,
    );
  }


}