import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';

/// Base view model for step visualization cards.
abstract class StepViewCardModel {
  final String id;
  final String title;

  StepViewCardModel({
    required this.id,
    required this.title,
  });
}

/// View model for displaying a Stop step card.
class StopViewCardModel extends StepViewCardModel {
  final String name;
  final String description;
  final List<String> experiences;

  StopViewCardModel({
    required super.id,
    required super.title,
    required this.name,
    required this.description,
    required this.experiences,
  });

  factory StopViewCardModel.fromStepViewModel(StopStepViewModel step) {
    return StopViewCardModel(
      id: step.id,
      title: step.title,
      name: step.name,
      description: step.description,
      experiences: step.experiences,
    );
  }
}

/// View model for displaying a Hosting step card.
class HostingViewCardModel extends StepViewCardModel {
  final String placeName;
  final String address;
  final DateTime checkIn;
  final DateTime checkOut;

  HostingViewCardModel({
    required super.id,
    required super.title,
    required this.placeName,
    required this.address,
    required this.checkIn,
    required this.checkOut,
  });

  factory HostingViewCardModel.fromStepViewModel(HostingStepViewModel step) {
    return HostingViewCardModel(
      id: step.id,
      title: step.title,
      placeName: step.placeName,
      address: step.address,
      checkIn: step.checkIn,
      checkOut: step.checkOut,
    );
  }
}

/// View model for displaying a Flight (Airplane) segment card.
class FlightViewCardModel extends StepViewCardModel {
  final String departureAirport;
  final String arrivalAirport;
  final String flightNumber;
  final String flightCompany;
  final String departureGate;
  final DateTime flightDate;

  FlightViewCardModel({
    required super.id,
    required super.title,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.flightNumber,
    required this.flightCompany,
    required this.departureGate,
    required this.flightDate,
  });

  factory FlightViewCardModel.fromStepViewModel(TravelSegmentStepViewModel step) {
    final transport = step.transport as AirplaneViewModel;
    return FlightViewCardModel(
      id: step.id,
      title: step.title,
      departureAirport: transport.departureAirport,
      arrivalAirport: transport.arrivalAirport,
      flightNumber: transport.flightNumber,
      flightCompany: transport.flightCompany,
      departureGate: transport.departureGate,
      flightDate: transport.flightDate,
    );
  }
}

/// View model for displaying a Generic step card.
class GenericStepViewCardModel extends StepViewCardModel {
  final bool isDraft;

  GenericStepViewCardModel({
    required super.id,
    required super.title,
    required this.isDraft,
  });

  factory GenericStepViewCardModel.fromStepViewModel(ItineraryStepViewModel step) {
    return GenericStepViewCardModel(
      id: step.id,
      title: step.title,
      isDraft: step is PlaceHolderStepViewModel,
    );
  }
}

/// View model for displaying a Boundary (Start/End) step card.
class BoundaryStepViewCardModel extends StepViewCardModel {
  final String location;
  final DateTime date;
  final bool isStart;

  BoundaryStepViewCardModel({
    required super.id,
    required super.title,
    required this.location,
    required this.date,
    required this.isStart,
  });
}
