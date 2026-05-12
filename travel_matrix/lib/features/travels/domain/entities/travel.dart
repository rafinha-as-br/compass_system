
import 'itinerary.dart';
import 'person.dart';
import 'route.dart';

enum TravelStatus{
  routeCreated, // -> Needs itinerary
  itineraryCreated, // -> Travel ready to be started at the date
  travelStarted, // -> travel in progress
  travelFinished
}

class Travel {
  final String id;
  final String clientId;
  final String travelName;
  TravelStatus travelStatus;

  /// real travel start date
  DateTime? startDate;

  /// real travel finish date
  DateTime? finishDate;

  final RoutePlan routePlan;
  final Itinerary? itinerary;

  // participants list
  final List<Person> participantsList;


  Travel({
    required this.id,
    required this.clientId,
    required this.travelName,
    this.travelStatus = TravelStatus.routeCreated,
    required this.routePlan,
    required this.participantsList,
    this.startDate,
    this.finishDate,
    this.itinerary,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'travelName': travelName,
      'travelStatus': travelStatus.name,
      'startDate': startDate?.toIso8601String(),
      'finishDate': finishDate?.toIso8601String(),
      'routePlan': routePlan.toJson(),
      'itinerary': itinerary?.toJson(),
      'participantsList': participantsList.map((e) => e.toJson()).toList(),
    };
  }
}