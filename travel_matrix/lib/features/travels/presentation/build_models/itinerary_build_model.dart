import '../view_models/route_view_model.dart';
import '../../domain/entities/itinerary_step.dart';
import '../view_models/itinerary_steps_view_models.dart';
import '../../domain/entities/transport.dart';
import '../view_models/transports_view_model.dart';

/// Presentation model used to pass data into [ItineraryBuildPage].
///
/// [steps] is null in create mode and populated in edit mode.
class ItineraryBuildModel {
  final String travelName;
  final ItineraryStepsBuildModel? steps;
  final List<InterestPointViewModel> interestsPoints;

  ItineraryBuildModel({
    required this.travelName,
    required this.steps,
    required this.interestsPoints,
  });
}

/// Groups the itinerary steps into pinned start/finish and the editable middle steps.
class ItineraryStepsBuildModel {
  final List<ItineraryStepViewModel?> normalSteps;
  final ItineraryStepViewModel? startStep;
  final ItineraryStepViewModel? finishStep;

  ItineraryStepsBuildModel({
    required this.normalSteps,
    required this.startStep,
    required this.finishStep,
  });
}

/// Converts between [ItineraryStepViewModel] and the domain [ItineraryStep].
class ItineraryStepMapper {
  /// Maps a [ItineraryStepViewModel] to its corresponding domain [ItineraryStep].
  static ItineraryStep toDomain(ItineraryStepViewModel vm) {
    if (vm is PlaceHolderStepViewModel) {
      return PlaceholderStep(
        id: vm.id,
        title: vm.title,
        startDate: vm.startDate,
        finishDate: vm.finishDate,
      );
    }

    if (vm is StopStepViewModel) {
      return Stop(
        id: vm.id,
        title: vm.title,
        startDate: vm.startDate,
        finishDate: vm.finishDate,
        name: vm.name,
        description: vm.description,
        experiences: vm.experiences,
      );
    }

    if (vm is HostingStepViewModel) {
      return Hosting(
        id: vm.id,
        title: vm.title,
        startDate: vm.startDate,
        finishDate: vm.finishDate,
        name: vm.placeName,
        address: vm.address,
        checkIn: vm.checkIn,
        checkOut: vm.checkOut,
      );
    }

    if (vm is TravelSegmentStepViewModel) {
      return TravelSegment(
        id: vm.id,
        title: vm.title,
        startDate: vm.startDate,
        finishDate: vm.finishDate,
        travelSegmentId: vm.id,
        transport: TransportMapper.toDomain(vm.transport),
        startPoint: vm.startPoint,
        finishPoint: vm.finishPoint,
      );
    }

    throw Exception(
      'Unsupported ViewModel type: ${vm.runtimeType}',
    );
  }
}

/// Converts between [TransportViewModel] and the domain [Transport].
class TransportMapper {
  /// Maps a [TransportViewModel] to its corresponding domain [Transport].
  static Transport toDomain(TransportViewModel vm) {
    if (vm is RentalCarViewModel) {
      return RentalCar(
        id: vm.id,
        vehicleModelName: vm.vehicleModelName,
        vehicleLicensePlate: vm.vehicleLicensePlate,
        companyName: vm.companyName,
        checkInDate: vm.checkInDate,
        checkOutDate: vm.checkOutDate,
      );
    }

    if (vm is BusViewModel) {
      return Bus(
        id: vm.id,
        travelNumber: vm.travelNumber,
        travelCompany: vm.travelCompany,
        departureGate: vm.departureGate,
        departureDateTime: vm.departureDateTime,
        busStationName: vm.busStationName,
        description: vm.description,
        details: vm.details,
      );
    }

    if (vm is AirplaneViewModel) {
      return Airplane(
        id: vm.id,
        flightNumber: vm.flightNumber,
        flightCompany: vm.flightCompany,
        flightDate: vm.flightDate,
        departureGate: vm.departureGate,
        departureAirport: vm.departureAirport,
        arrivalAirport: vm.arrivalAirport,
      );
    }

    throw Exception(
      'Unsupported TransportViewModel type: ${vm.runtimeType}',
    );
  }

  /// Converts a domain [Transport] back to its corresponding [TransportViewModel].
  ///
  /// Used when a form widget emits an updated domain entity and the page
  /// needs to store it as a ViewModel in [ItineraryEditorController].
  static TransportViewModel fromDomain(Transport domain) {
    if (domain is RentalCar) {
      return RentalCarViewModel(
        id: domain.id,
        vehicleModelName: domain.vehicleModelName,
        vehicleLicensePlate: domain.vehicleLicensePlate,
        companyName: domain.companyName,
        checkInDate: domain.checkInDate,
        checkOutDate: domain.checkOutDate,
      );
    }

    if (domain is Bus) {
      return BusViewModel(
        id: domain.id,
        travelNumber: domain.travelNumber,
        travelCompany: domain.travelCompany,
        departureGate: domain.departureGate,
        departureDateTime: domain.departureDateTime,
        busStationName: domain.busStationName,
        description: domain.description,
        details: domain.details,
      );
    }

    if (domain is Airplane) {
      return AirplaneViewModel(
        id: domain.id,
        flightNumber: domain.flightNumber,
        flightCompany: domain.flightCompany,
        flightDate: domain.flightDate,
        departureGate: domain.departureGate,
        departureAirport: domain.departureAirport,
        arrivalAirport: domain.arrivalAirport,
      );
    }

    throw Exception(
      'Unsupported Transport type: ${domain.runtimeType}',
    );
  }
}
