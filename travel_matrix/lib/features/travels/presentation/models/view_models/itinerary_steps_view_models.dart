import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/domain/usecases/timeline_analyzer.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/timeline_problem_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/itinerary_step.dart';


/// Enum to determine the position of a step in the itinerary.
enum StepPosition{
  start,
  middle,
  finish,
}

/// Itinerary Step view model class, used to represent an [ItineraryStep] on the UI
abstract class ItineraryStepViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? _backEndId;
  final String localId;
  final String title;
  final DateTime startDate;
  final DateTime finishDate;
  final StepPosition position;
  /// List of problems, null in case of no problems
  final List<TimelineProblemViewModel>? problems;
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
    required this.problems,
  }): _backEndId = backEndId;

  /// Factory constructor from domain model
  factory ItineraryStepViewModel.fromDomain(ItineraryStep domainStep, bool isFirst, bool isLast) {

    final StepPosition position;
    if (isFirst) {
      position = StepPosition.start;
    } else if (isLast) {
      position = StepPosition.finish;
    } else {
      position = StepPosition.middle;
    }

    switch (domainStep) {
      case PlaceholderStep _:
        return ItineraryStepViewModel.fromPlaceHolder(
          placeHolder: domainStep,
          position: position,
        );
      case Stop _:
        return ItineraryStepViewModel.fromStop(
          stop: domainStep,
          position: position,
        );
      case Hosting _:
        return ItineraryStepViewModel.fromHosting(
          hosting: domainStep,
          position: position,
        );
      case TravelSegment _:
        return ItineraryStepViewModel.fromTravelSegment(
          travelSegment: domainStep,
          position: position,
        );
      default:
        ///
        return ItineraryStepViewModel.fromPlaceHolder(
          placeHolder: domainStep as PlaceholderStep,
          position: position,
        );

    }
  }

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
        problems: null,
        position: position,
        icon: Icons.edit_note);
  }

  /// Create a [PlaceHolderStepViewModel] from domain model
  factory ItineraryStepViewModel.fromPlaceHolder({
    required PlaceholderStep placeHolder,
    required StepPosition position,
  }) {
    return PlaceHolderStepViewModel._(
        backEndId: placeHolder.backEndId,
        localId: placeHolder.domainId,
        title: placeHolder.title,
        description: placeHolder.description,
        startDate: placeHolder.startDate,
        finishDate: placeHolder.finishDate,
        position: position,
        problems: null,
        icon: Icons.edit_note
    );
  }

  /// Creates a new [StopStepViewModel] on local UI
  factory ItineraryStepViewModel.newStop({
    required String title,
    required String name,
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
        name: name,
        startDate: startDate,
        finishDate: finishDate,
        position: position,
        description: description,
        experiences: experiences,
        problems: null,
        icon: Icons.place
    );
  }

  /// Create a [StopStepViewModel] from domain model
  factory ItineraryStepViewModel.fromStop({
    required Stop stop,
    required StepPosition position,
  }) {
    return StopStepViewModel._(
        backEndId: stop.backEndId,
        localId: stop.domainId,
        title: stop.title,
        name: stop.name,
        startDate: stop.startDate,
        finishDate: stop.finishDate,
        position: position,
        description: stop.description,
        experiences: stop.experiences,
        problems: null,
        icon: Icons.place
    );
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
        problems: null,
        icon: Icons.hotel);
  }

  /// Create a [HostingStepViewModel] from domain model
  factory ItineraryStepViewModel.fromHosting({
    required Hosting hosting,
    required StepPosition position,
  }) {
    return HostingStepViewModel._(
        backEndId: hosting.backEndId,
        localId: hosting.domainId,
        title: hosting.title,
        startDate: hosting.startDate,
        finishDate: hosting.finishDate,
        placeName: hosting.name,
        address: hosting.address,
        checkIn: hosting.checkIn,
        checkOut: hosting.checkOut,
        problems: null,
        position: position,
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
        problems: null,
        transport: transport,
        icon: Icons.flight);
  }

  /// Create a [TravelSegmentStepViewModel] from domain model
  factory ItineraryStepViewModel.fromTravelSegment({
    required TravelSegment travelSegment,
    required StepPosition position,
  }) {
    return TravelSegmentStepViewModel._(
        backEndId: travelSegment.backEndId,
        localId: travelSegment.domainId,
        title: travelSegment.title,
        startDate: travelSegment.startDate,
        finishDate: travelSegment.finishDate,
        startPoint: travelSegment.startPoint,
        finishPoint: travelSegment.finishPoint,
        transport: TransportViewModel.fromDomain(travelSegment.transport),
        position: position,
        problems: null,
        icon: Icons.directions
    );
  }

  /// To domain mapper method
  ItineraryStep toDomain();

  ItineraryStepViewModel copyWith({
    String? backEndId,
    String? localId,
    String? title,
    DateTime? startDate,
    DateTime? finishDate,
    StepPosition? position,
    List<TimelineProblemViewModel>? problems,
    IconData? icon,
  });

  /// Builder for [TimelineNode] for the entity
  TimelineNode toTimelineNode({required int sequenceIndex}){
    return TimelineNode(
      domainId: localId,
      startDate: startDate,
      finishDate: finishDate,
      sequenceIndex: sequenceIndex,
    );
  }

  List<TimelineNode>? buildInternalTimeline();





  /// Provides the local ID for UI reference
  String get id => localId;
  // Provides the back end id for persistence
  String? get persistedId => _backEndId;
  /// Converts [ItineraryStepViewModel.startDate] to string format
  String get startString => startDate.toString();
  /// Converts [ItineraryStepViewModel.startDate] to string format
  String get finishString => finishDate.toString();

}

/// Placeholder view model type, used to represent a [ItineraryStepViewModel] on the UI
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
      required super.problems,
      required super.icon,
  }): super._();

  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newPlaceholder(
      domainId: localId,
      backEndId: _backEndId,
      title: title,
      description: description,
      startDate: startDate,
      finishDate: finishDate,
    );
  }

  @override
  PlaceHolderStepViewModel copyWith({
    String? backEndId,
    String? localId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? finishDate,
    StepPosition? position,
    List<TimelineProblemViewModel>? problems,
    IconData? icon,
  }) {
    return PlaceHolderStepViewModel._(
      backEndId: backEndId ?? _backEndId,
      localId: localId ?? this.localId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      position: position ?? this.position,
      problems: (problems ?? this.problems)?.toList(),
      icon: icon ?? this.icon,
    );
  }

  /// Placeholder does not need to build a timeline
  @override
  List<TimelineNode>? buildInternalTimeline() {
    return null;
  }

}

/// Stop step view model class, used to represent a [Stop] on the UI
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
    required super.problems,
    required super.icon,
  }) : super._();

  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newStop(
      domainId: localId,
      backEndId: _backEndId,
      title: title,
      name: name,
      startDate: startDate,
      finishDate: finishDate,
      description: description,
      experiences: experiences,
    );
  }

  @override
  StopStepViewModel copyWith({
    String? backEndId,
    String? localId,
    String? title,
    DateTime? startDate,
    DateTime? finishDate,
    StepPosition? position,
    String? name,
    String? description,
    List<String>? experiences,
    List<TimelineProblemViewModel>? problems,
    IconData? icon,
  }) {
    return StopStepViewModel._(
      backEndId: backEndId ?? _backEndId,
      localId: localId ?? this.localId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      position: position ?? this.position,
      name: name ?? this.name,
      description: description ?? this.description,
      experiences: (experiences ?? this.experiences).toList(),
      problems: (problems ?? this.problems)?.toList(),
      icon: icon ?? this.icon,
    );
  }

  /// Stop does not need to build a timeline
  @override
  List<TimelineNode>? buildInternalTimeline() {
    return null;
  }



}

/// Hosting step view model class, used to represent a [Hosting] on the UI
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
    required super.problems,
    required super.icon,
  }): super._();

  String get checkInString => checkIn.toString();

  String get checkOutString => checkOut.toString();

  @override
  ItineraryStep toDomain() {
    return ItineraryStep.newHosting(
      domainId: localId,
      backEndId: _backEndId,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      name: placeName,
      address: address,
      checkIn: checkIn,
      checkOut: checkOut,
    );
  }

  @override
  HostingStepViewModel copyWith({
    String? backEndId,
    String? localId,
    String? title,
    DateTime? startDate,
    DateTime? finishDate,
    StepPosition? position,
    String? placeName,
    String? address,
    DateTime? checkIn,
    DateTime? checkOut,
    List<TimelineProblemViewModel>? problems,
    IconData? icon,
  }) {
    return HostingStepViewModel._(
      backEndId: backEndId ?? _backEndId,
      localId: localId ?? this.localId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      position: position ?? this.position,
      placeName: placeName ?? this.placeName,
      address: address ?? this.address,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      problems: (problems ?? this.problems)?.toList(),
      icon: icon ?? this.icon,
    );
  }

  @override
  List<TimelineNode>? buildInternalTimeline() {
    final List<TimelineNode> nodes = [];
    nodes.add(
        TimelineNode.instant(
            domainId: localId,
            date: startDate,
            sequenceIndex: 0
        )
    );
    nodes.add(
        TimelineNode(
            domainId: localId,
            startDate: checkIn,
            finishDate: checkOut,
            sequenceIndex: 1
        )
    );
    nodes.add(
        TimelineNode.instant(
            domainId: localId,
            date: finishDate,
            sequenceIndex: 2
        )
    );


    return nodes;


  }




}

/// Travel segment step view model class, used to represent a [TravelSegment] on the UI
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
    required super.problems,
    required super.position,
    required this.startPoint,
    required this.finishPoint,
    required this.transport,
    required super.icon,
  }): super._();

  @override
  ItineraryStep toDomain() {
    return  ItineraryStep.newTravelSegment(
      domainId: localId,
      backEndId: _backEndId,
      title: title,
      startDate: startDate,
      finishDate: finishDate,
      startPoint: startPoint,
      finishPoint: finishPoint,
      transport: transport.toDomain(),
    );
  }

  @override
  TravelSegmentStepViewModel copyWith({
    String? backEndId,
    String? localId,
    String? title,
    DateTime? startDate,
    DateTime? finishDate,
    StepPosition? position,
    String? startPoint,
    String? finishPoint,
    TransportViewModel? transport,
    List<TimelineProblemViewModel>? problems,
    IconData? icon,
  }) {
    return TravelSegmentStepViewModel._(
      backEndId: backEndId ?? _backEndId,
      localId: localId ?? this.localId,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      finishDate: finishDate ?? this.finishDate,
      position: position ?? this.position,
      startPoint: startPoint ?? this.startPoint,
      finishPoint: finishPoint ?? this.finishPoint,
      problems: (problems ?? this.problems)?.toList(),
      transport: transport ?? this.transport,
      icon: icon ?? this.icon,
    );
  }

  @override
  List<TimelineNode>? buildInternalTimeline() {
    final List<TimelineNode> nodes = [];
    final transportNode = transport.toTimelineNode();

    nodes.add(
      TimelineNode.instant(
        domainId: localId,
        date: startDate,
        sequenceIndex: 0
      )
    );

    if(transportNode != null){
      nodes.add(transportNode);
    }

    nodes.add(
        TimelineNode.instant(
            domainId: localId,
            date: finishDate,
            sequenceIndex: transportNode == null ? 1 : transportNode.sequenceIndex + 1
        )
    );

    return nodes;
  }

}

