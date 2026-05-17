
import 'package:uuid/uuid.dart';

/// Route view model class, used to represent a route on the UI
class RouteViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final String startDate;
  final String endDate;
  final String start;
  final String destination;
  final List<InterestPointViewModel> interests;

  RouteViewModel._({
    required this.backEndId,
    required this.localId,
    required this.startDate,
    required this.endDate,
    required this.start,
    required this.destination,
    required this.interests
  });

  /// factory constructor for domain model
  factory RouteViewModel.fromDomain(String backEndId, String startDate, String endDate, String start, String destination, List<InterestPointViewModel> interests){
    return RouteViewModel._(
      backEndId: backEndId,
      localId: Uuid().v4(),
      startDate: startDate,
      endDate: endDate,
      start: start,
      destination: destination,
      interests: interests
    );
  }

  /// factory constructor for local model
  factory RouteViewModel.fromLocal(String startDate, String endDate, String start, String destination, List<InterestPointViewModel> interests){
    return RouteViewModel._(
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

  /// Converts [RouteViewModel.startDate] to string format
  String get startString => startDate.toString();
  /// Converts [RouteViewModel.startDate] to string format
  String get finishString => endDate.toString();

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
  factory InterestPointViewModel.fromDomain(String backEndId, String name, String description){
    return InterestPointViewModel(
      backEndId: backEndId,
      localId: Uuid().v4(),
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

}