

import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/route_view_model.dart';

import '../../../domain/entities/travel.dart';
import 'itinerary_view_model.dart';

/// Enum view model for [TravelStatus]
enum TravelStatusViewModel {
  notReady,
  ready,
  inProgress,
  completed;

  /// Converts [TravelStatus] domain enum
  /// to [TravelStatusViewModel]
  static TravelStatusViewModel fromDomain(
      TravelStatus status,
      ) {
    switch (status) {
      case TravelStatus.routeCreated:
        return TravelStatusViewModel.notReady;

      case TravelStatus.itineraryCreated:
        return TravelStatusViewModel.ready;

      case TravelStatus.travelStarted:
        return TravelStatusViewModel.inProgress;

      case TravelStatus.travelFinished:
        return TravelStatusViewModel.completed;
    }
  }

  /// Converts [TravelStatusViewModel]
  /// to [TravelStatus] domain enum
  TravelStatus toDomain() {
    switch (this) {
      case TravelStatusViewModel.notReady:
        return TravelStatus.routeCreated;

      case TravelStatusViewModel.ready:
        return TravelStatus.itineraryCreated;

      case TravelStatusViewModel.inProgress:
        return TravelStatus.travelStarted;

      case TravelStatusViewModel.completed:
        return TravelStatus.travelFinished;
    }
  }
}


/// Travel view model class, used to represent a [Travel] on the UI
class TravelViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final String clientName;
  final String agentName;
  final String travelTitle;
  final TravelStatusViewModel status;
  final RoutePlanViewModel route;
  final ItineraryViewModel? itinerary;
  final List<PersonViewModel> participants;


  TravelViewModel({
    required this.backEndId,
    required this.localId,
    required this.clientName,
    required this.agentName,
    required this.travelTitle,
    required this.status,
    required this.route,
    required this.participants,
    this.itinerary,
  });

  /// To domain mapper method
  Travel toDomain(){
    return Travel(
      domainId: localId,
      backEndId: backEndId,
      clientId: clientName,
      travelName: travelTitle,
      routePlan: route.toDomain(),
      participantsList: participants.map((x) => x.toDomain()).toList(),
      travelStatus: status.toDomain(),
      itinerary: itinerary?.toDomain(),
    );
  }

  String get statusString{
    switch(status){
      case TravelStatusViewModel.notReady:
        return 'Not Ready';
        case TravelStatusViewModel.ready:
        return 'Ready';
        case TravelStatusViewModel.inProgress:
        return 'In Progress';
        case TravelStatusViewModel.completed:
        return 'Completed';
    }
  }

}

/// Person view model class, used to represent a [Person] on the UI
class PersonViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final String name;
  final String age;
  final String sex;

  PersonViewModel({
    required this.backEndId,
    required this.localId,
    required this.name,
    required this.age,
    required this.sex,
  });

  /// To domain mapper method
  Person toDomain(){
    return Person(
      domainId: localId,
      backendId: backEndId,
      name: name,
      age: age,
      sex: sex,
    );
  }

  /// Factory constructor from domain model
  factory PersonViewModel.fromDomain(
      Person person,
      ){
    return PersonViewModel(
      backEndId: person.backendId,
      localId: person.domainId,
      name: person.name,
      age: person.age,
      sex: person.sex,
    );
  }

  /// Factory constructor for local model
  factory PersonViewModel.fromLocal(
      String name,
      String age,
      String sex,
    ){
    return PersonViewModel(
      backEndId: null,
      localId: name,
      name: name,
      age: age,
      sex: sex,
    );
  }

  /// Provides the local ID for UI reference
  String get id => localId;


}