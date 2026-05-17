import 'package:uuid/uuid.dart';

/// Transport view model class, used to represent different types of transports on the UI
abstract class TransportViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;

  TransportViewModel._({
    required this.backEndId,
    required this.localId,
  });

  /// Creates a new [RentalCarViewModel] on local UI
  factory TransportViewModel.newRentalCar(
      String vehicleModelName,
      String vehicleLicensePlate,
      String companyName,
      DateTime checkInDate,
      DateTime checkOutDate
      ){
    return RentalCarViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        vehicleModelName: vehicleModelName,
        vehicleLicensePlate: vehicleLicensePlate,
        companyName: companyName,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate
    );
  }

  /// Create a [RentalCarViewModel] from domain model
  factory TransportViewModel.fromRentalCar(
    String vehicleModelName,
    String vehicleLicensePlate,
    String companyName,
    DateTime checkInDate,
    DateTime checkOutDate
      ){
    return RentalCarViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        vehicleModelName: vehicleModelName,
        vehicleLicensePlate: vehicleLicensePlate,
        companyName: companyName,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate
    );
  }

  /// Create a [BusViewModel] on local UI
  factory TransportViewModel.newBus(
      String travelNumber,
      String travelCompany,
      String departureGate,
      DateTime departureDateTime,
      String busStationName,
      String description,
      String? details
      ){
    return BusViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        travelNumber: travelNumber,
        travelCompany: travelCompany,
        departureGate: departureGate,
        departureDateTime: departureDateTime,
        busStationName: busStationName,
        description: description,
        details: details
    );
  }

  /// Create a [BusViewModel] from domain model
  factory TransportViewModel.fromBus(
      String travelNumber,
      String travelCompany,
      String departureGate,
      DateTime departureDateTime,
      String busStationName,
      String description,
      String? details
      ){
    return BusViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        travelNumber: travelNumber,
        travelCompany: travelCompany,
        departureGate: departureGate,
        departureDateTime: departureDateTime,
        busStationName: busStationName,
        description: description,
        details: details
    );
  }

  /// Create a [AirplaneViewModel] on local UI
  factory TransportViewModel.newAirplane(
      String flightNumber,
      String flightCompany,
      DateTime flightDate,
      String departureGate,
      String departureAirport,
      String arrivalAirport
      ){
    return AirplaneViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        flightNumber: flightNumber,
        flightCompany: flightCompany,
        flightDate: flightDate,
        departureGate: departureGate,
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport
    );
  }

  /// Create a [AirplaneViewModel] from domain model
  factory TransportViewModel.fromAirplane(
      String flightNumber,
      String flightCompany,
      DateTime flightDate,
      String departureGate,
      String departureAirport,
      String arrivalAirport
      ){
    return AirplaneViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        flightNumber: flightNumber,
        flightCompany: flightCompany,
        flightDate: flightDate,
        departureGate: departureGate,
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport
    );
  }


}

/// Rental car view model type
/// TODO: For future updates, place the icons that are going to be displayed on the UI, with every type of transport.
class RentalCarViewModel extends TransportViewModel{
  final String vehicleModelName;
  final String vehicleLicensePlate;
  final String companyName;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  RentalCarViewModel._({
    required super.backEndId,
    required super.localId,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate
  }): super._();

  String get checkInString => checkInDate.toString();

  String get checkOutString => checkOutDate.toString();


}

/// Bus view model type
class BusViewModel extends TransportViewModel{
  final String travelNumber;
  final String travelCompany;
  final String departureGate;
  final DateTime departureDateTime;
  final String busStationName;
  final String description;
  final String? details;

  BusViewModel._({
    required super.backEndId,
    required super.localId,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    this.details
  }): super._();

}

/// Airplane view model type
class AirplaneViewModel extends TransportViewModel{
  final String flightNumber;
  final String flightCompany;
  final DateTime flightDate;
  final String departureGate;
  final String departureAirport;
  final String arrivalAirport;

  AirplaneViewModel._({
    required super.backEndId,
    required super.localId,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport
  }): super._();

}