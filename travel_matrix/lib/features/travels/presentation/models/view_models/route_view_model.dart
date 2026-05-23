
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
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

  RoutePlanViewModel._({
    required this.backEndId,
    required this.localId,
    required this.startDate,
    required this.endDate,
    required this.start,
    required this.destination,
    required this.interests
  });

  /// factory constructor for domain model
  factory RoutePlanViewModel.fromDomain(
      String backEndId,
      String domainId,
      DateTime startDate,
      DateTime endDate,
      String start,
      String destination,
      List<InterestPointViewModel> interests
    ){
    return RoutePlanViewModel._(
      backEndId: backEndId,
      localId: domainId,
      startDate: startDate,
      endDate: endDate,
      start: start,
      destination: destination,
      interests: interests
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
        interestsList: interests.map((x) => x.toDomain()).toList()
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

  InterestPointViewModel({
    required this.backEndId,
    required this.localId,
    required this.name,
    required this.description
  });

  /// factory constructor for domain model
  factory InterestPointViewModel.fromDomain(String backEndId, String domainId, String name, String description){
    return InterestPointViewModel(
      backEndId: backEndId,
      localId: domainId,
      name: name,
      description: description
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
      description: description
    );
  }

}