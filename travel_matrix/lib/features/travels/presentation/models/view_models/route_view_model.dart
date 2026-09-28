
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/shared/models/place_suggestion.dart';
import 'package:uuid/uuid.dart';

/// Route view model class, used to represent a [RoutePlan] on the UI
class RoutePlanViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final DateTime startDate;
  final DateTime endDate;
  final String start;
  final String destination;
  final List<InterestPointViewModel> interests;
  final PlaceCoordinate? startCoordinate;
  final PlaceCoordinate? destinationCoordinate;

  RoutePlanViewModel._({
    required this.backEndId,
    required this.localId,
    required this.startDate,
    required this.endDate,
    required this.start,
    required this.destination,
    required this.interests,
    this.startCoordinate,
    this.destinationCoordinate,
  });

  /// factory constructor for domain model
  factory RoutePlanViewModel.fromDomain(
      RoutePlan routePlan,
    ){
    return RoutePlanViewModel._(
      backEndId: routePlan.backEndId,
      localId: routePlan.domainId,
      startDate: routePlan.startDate,
      endDate: routePlan.endDate,
      start: routePlan.startLocation,
      destination: routePlan.destination,
      interests: routePlan.interestsList.map((x) => InterestPointViewModel.fromDomain(x)).toList(),
      startCoordinate: routePlan.startLocationCoordinate,
      destinationCoordinate: routePlan.destinationCoordinate,
    );
  }

  /// factory constructor for local model
  factory RoutePlanViewModel.fromLocal(
      DateTime startDate,
      DateTime endDate,
      String start,
      String destination,
      List<InterestPointViewModel> interests){
    return RoutePlanViewModel._(
      backEndId: null,
      localId: Uuid().v4(),
      startDate: startDate,
      endDate: endDate,
      start: start,
      destination: destination,
      interests: interests
    );
  }

  /// Provides the local ID for UI reference
  String get id => localId;

  /// Converts [RoutePlanViewModel.startDate] to string format
  String get startString => startDate.toString();
  /// Converts [RoutePlanViewModel.startDate] to string format
  String get finishString => endDate.toString();

  /// To domain mapper method
  RoutePlan toDomain(){
    return RoutePlan(
        domainId: localId,
        backEndId: backEndId,
        startDate: startDate,
        endDate: endDate,
        startLocation: start,
        destination: destination,
        interestsList: interests.map((x) => x.toDomain()).toList(),
        startLocationCoordinate: startCoordinate,
        destinationCoordinate: destinationCoordinate,
    );
  }

}

/// Interest point view model class, used to represent an interest point on the UI
class InterestPointViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final String name;
  final String description;
  final PlaceCoordinate? coordinate;

  InterestPointViewModel({
    required this.backEndId,
    required this.localId,
    required this.name,
    required this.description,
    this.coordinate,
  });

  /// factory constructor for domain model
  factory InterestPointViewModel.fromDomain(InterestPoint interestPoint){
    return InterestPointViewModel(
      backEndId: interestPoint.backEndId,
      localId: interestPoint.domainId,
      name: interestPoint.name,
      description: interestPoint.description,
      coordinate: interestPoint.coordinate,
    );
  }

  /// factory constructor for local model
  factory InterestPointViewModel.fromLocal(String name, String description){
    return InterestPointViewModel(
      backEndId: null,
      localId: Uuid().v4(),
      name: name,
      description: description
    );
  }

  /// Provides the local ID for UI reference
  String get id => localId;

  /// To domain mapper method
  InterestPoint toDomain(){
    return InterestPoint(
      domainId: localId,
      backEndId: backEndId,
      name: name,
      description: description,
      coordinate: coordinate,
    );
  }

}