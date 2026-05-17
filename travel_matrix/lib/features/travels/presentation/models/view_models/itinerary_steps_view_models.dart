import 'package:flutter/material.dart';
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
  /// Icon for the step type
  final IconData icon;

  /// private constructor
  ItineraryStepViewModel._({
    required String? backEndId,
    required this.localId,
    required this.title,
    required this.startDate,
    required this.finishDate,
    required this.position,
    required this.icon,
  }): _backEndId = backEndId;



  /// Creates a new [PlaceHolderStepViewModel] on local UI.
  /// Guarantees that title, description, startDate, and finishDate are not empty.
  factory ItineraryStepViewModel.newPlaceHolder({
    /// Index value to determine the step position on the placeholder title
    required int currentIndex,
    required StepPosition position,
  }) {
    return PlaceHolderStepViewModel._(
        backEndId: null,
        localId: const Uuid().v4(),
        title: 'New Step — ${currentIndex + 1}',
        description: 'New step description',
        startDate: DateTime.now(),
        finishDate: DateTime.now().add(
          const Duration(days: 1),
        ),
        position: position,
        icon: Icons.edit_note);
  }

  /// Create a [PlaceHolderStepViewModel] from domain model
  factory ItineraryStepViewModel.fromPlaceHolder({
    required String backEndId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime finishDate,
    required StepPosition position,
  }) {
    return PlaceHolderStepViewModel._(
        backEndId: backEndId,
        localId: const Uuid().v4(),
        title: title,
        description: description,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        icon: Icons.edit_note);
  }

  /// Creates a new [StopStepViewModel] on local UI
  factory ItineraryStepViewModel.newStop({
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required StepPosition position,
    required String description,
    required List<String> experiences,
  }) {
    return StopStepViewModel._(
        backEndId: null,
        localId: const Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        description: description,
        experiences: experiences,
        icon: Icons.place);
  }

  /// Create a [StopStepViewModel] from domain model
  factory ItineraryStepViewModel.fromStop({
    required String backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required StepPosition position,
    required String description,
    required List<String> experiences,
  }) {
    return StopStepViewModel._(
        backEndId: backEndId,
        localId: const Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        description: description,
        experiences: experiences,
        icon: Icons.place);
  }

  /// Creates a new [HostingStepViewModel] on local UI
  factory ItineraryStepViewModel.newHosting({
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required StepPosition position,
    required String placeName,
    required String address,
    required DateTime checkIn,
    required DateTime checkOut,
  }) {
    return HostingStepViewModel._(
        backEndId: null,
        localId: const Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        placeName: placeName,
        address: address,
        checkIn: checkIn,
        checkOut: checkOut,
        icon: Icons.hotel);
  }

  /// Create a [HostingStepViewModel] from domain model
  factory ItineraryStepViewModel.fromHosting({
    required String backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required StepPosition position,
    required String placeName,
    required String address,
    required DateTime checkIn,
    required DateTime checkOut,
  }) {
    return HostingStepViewModel._(
        backEndId: backEndId,
        localId: const Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        placeName: placeName,
        address: address,
        checkIn: checkIn,
        checkOut: checkOut,
        icon: Icons.hotel);
  }

  /// Creates a new [TravelSegmentStepViewModel] on local UI
  factory ItineraryStepViewModel.newTravelSegment({
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required StepPosition position,
    required String startPoint,
    required String finishPoint,
    required TransportViewModel transport,
  }) {
    return TravelSegmentStepViewModel._(
        backEndId: null,
        localId: const Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        startPoint: startPoint,
        finishPoint: finishPoint,
        transport: transport,
        icon: Icons.flight);
  }

  /// Create a [TravelSegmentStepViewModel] from domain model
  factory ItineraryStepViewModel.fromTravelSegment({
    required String backEndId,
    required String title,
    required DateTime startDate,
    required DateTime finishDate,
    required StepPosition position,
    required String startPoint,
    required String finishPoint,
    required TransportViewModel transport,
  }) {
    return TravelSegmentStepViewModel._(
        backEndId: backEndId,
        localId: const Uuid().v4(),
        title: title,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        startPoint: startPoint,
        finishPoint: finishPoint,
        transport: transport,
        icon: Icons.flight);
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

/// Placeholder view model type, used to represent a [ItineraryStepViewModel] without a type
class PlaceHolderStepViewModel extends ItineraryStepViewModel{
  final String description;
  PlaceHolderStepViewModel._({
      required super.backEndId,
      required super.localId,
      required super.title,
      required this.description,
      required super.startDate,
      required super.finishDate,
      required super.position,
      required super.icon,
  }): super._();

}

/// Stop step view model class
class StopStepViewModel extends ItineraryStepViewModel{
  final String description;
  final List<String> experiences;

  StopStepViewModel._({
    required super.backEndId,
    required super.localId,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required super.position,
    required this.description,
    required this.experiences,
    required super.icon,
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
    required super.icon,
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
    required this.transport,
    required super.icon,
  }): super._();

}