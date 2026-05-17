

import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:uuid/uuid.dart';


/// Enum to determine the position of a step in the itinerary.
enum StepPosition{
  start,
  middle,
  finish,
}

/// Base view model class for all itinerary steps.
abstract class ItineraryStepViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? _backEndId;
  final String localId;
  final String title;
  final DateTime startDate;
  final DateTime finishDate;
  final StepPosition position;

  /// private constructor
  ItineraryStepViewModel._({
    required String? backEndId,
    required this.localId,
    required this.title,
    required this.startDate,
    required this.finishDate,
    required this.position,
  }): _backEndId = backEndId;

  /// Creates a new [PlaceHolderStepViewModel] on local UI
  factory ItineraryStepViewModel.newPlaceHolder(
      String title,
      DateTime startDate,
      DateTime finishDate,
      StepPosition position
      ){
    return PlaceHolderStepViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position
    );
  }

  /// Create a [PlaceHolderStepViewModel] from domain model
  factory ItineraryStepViewModel.fromPlaceHolder(
      String backEndId,
      String title,
      DateTime startDate,
      DateTime finishDate,
      StepPosition position
      ){
    return PlaceHolderStepViewModel._(
        backEndId: backEndId,
        localId: Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position
    );
  }

  /// Creates a new [StopStepViewModel] on local UI
  factory ItineraryStepViewModel.newStop(
      String title,
      DateTime startDate,
      DateTime finishDate,
      StepPosition position,
      String name,
      String description,
      List<String> experiences
      ){
    return StopStepViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        name: name,
        description: description,
        experiences: experiences
    );
  }

  /// Create a [StopStepViewModel] from domain model
  factory ItineraryStepViewModel.fromStop(
      String backEndId,
      String title,
      DateTime startDate,
      DateTime finishDate,
      StepPosition position,
      String name,
      String description,
      List<String> experiences
      ){
    return StopStepViewModel._(
        backEndId: backEndId,
        localId: Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        name: name,
        description: description,
        experiences: experiences
    );
  }

  /// Creates a new [HostingStepViewModel] on local UI
  factory ItineraryStepViewModel.newHosting(
      String title,
      DateTime startDate,
      DateTime finishDate,
      StepPosition position,
      String placeName,
      String address,
      DateTime checkIn,
      DateTime checkOut
      ){
    return HostingStepViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        placeName: placeName,
        address: address,
        checkIn: checkIn,
        checkOut: checkOut
    );
  }

  /// Create a [HostingStepViewModel] from domain model
  factory ItineraryStepViewModel.fromHosting(
      String backEndId,
      String title,
      DateTime startDate,
      DateTime finishDate,
      StepPosition position,
      String placeName,
      String address,
      DateTime checkIn,
      DateTime checkOut
      ){
    return HostingStepViewModel._(
        backEndId: backEndId,
        localId: Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        placeName: placeName,
        address: address,
        checkIn: checkIn,
        checkOut: checkOut
    );
  }

  /// Creates a new [TravelSegmentStepViewModel] on local UI
  factory ItineraryStepViewModel.newTravelSegment(
      String title,
      DateTime startDate,
      DateTime finishDate,
      StepPosition position,
      String startPoint,
      String finishPoint,
      TransportViewModel transport
      ){
    return TravelSegmentStepViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        startPoint: startPoint,
        finishPoint: finishPoint,
        transport: transport
    );
  }

  /// Create a [TravelSegmentStepViewModel] from domain model
  factory ItineraryStepViewModel.fromTravelSegment(
      String backEndId,
      String title,
      DateTime startDate,
      DateTime finishDate,
      StepPosition position,
      String startPoint,
      String finishPoint,
      TransportViewModel transport
      ){
    return TravelSegmentStepViewModel._(
        backEndId: backEndId,
        localId: Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        startPoint: startPoint,
        finishPoint: finishPoint,
        transport: transport
    );
  }

  /// Provides the local ID for UI reference
  String get id => localId;
  // Provides the back end id for persistence
  String? get persistedId => _backEndId;
  /// Converts [ItineraryStepViewModel.startDate] to string format
  String get startString => startDate.toString();
  /// Converts [ItineraryStepViewModel.startDate] to string format
  String get finishString => finishDate.toString();

}

/// Place holder model for empty/non finished steps.
class PlaceHolderStepViewModel extends ItineraryStepViewModel{
  PlaceHolderStepViewModel._({
      required super.backEndId,
      required super.localId,
      required super.title,
      required super.startDate,
      required super.finishDate,
      required super.position,
  }): super._();

}

/// Stop step view model class
class StopStepViewModel extends ItineraryStepViewModel{
  final String name;
  final String description;
  final List<String> experiences;

  StopStepViewModel._({
    required super.backEndId,
    required super.localId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.position,
    required this.name,
    required this.description,
    required this.experiences,
  }) : super._();

}

/// Hosting step view model class
class HostingStepViewModel extends ItineraryStepViewModel{
  final String placeName;
  final String address;
  final DateTime checkIn;
  final DateTime checkOut;

  HostingStepViewModel._({
    required super.backEndId,
    required super.localId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.position,
    required this.placeName,
    required this.address,
    required this.checkIn,
    required this.checkOut,
  }): super._();

  String get checkInString => checkIn.toString();

  String get checkOutString => checkOut.toString();


}

/// Travel segment step view model class
class TravelSegmentStepViewModel extends ItineraryStepViewModel{
  final String startPoint;
  final String finishPoint;
  final TransportViewModel transport;

  TravelSegmentStepViewModel._({
    required super.backEndId,
    required super.localId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.position,
    required this.startPoint,
    required this.finishPoint,
    required this.transport
  }): super._();

}