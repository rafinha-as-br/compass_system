import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/domain/usecases/timeline_analyzer.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/transport.dart';

/// Transport view model class, used to represent a [Transport] on the UI
abstract class TransportViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final TimelineProblemSeverity? problemSeverity;
  /// Icon for the step type
  final IconData icon;

  TransportViewModel._({
    required this.backEndId,
    required this.localId,
    required this.problemSeverity,
    required this.icon,
  });

  /// Factory constructor from domain model
  factory TransportViewModel.fromDomain(Transport transport){
    switch (transport) {
      case PlaceholderTransport _:
        return TransportViewModel.fromPlaceHolder(placeHolder: transport);
      case RentalCar _:
        return TransportViewModel.fromRentalCar(rentalCar: transport);
      case Bus _:
        return TransportViewModel.fromBus(bus: transport);
      case Airplane _:
        return TransportViewModel.fromAirplane(airplane: transport);
      default:
      return TransportViewModel.fromPlaceHolder(placeHolder:
      transport as PlaceholderTransport);


    }
  }

  /// Creates a new [PlaceHolderTransportViewModel] on local UI
  factory TransportViewModel.newPlaceHolder(){
    return PlaceHolderTransportViewModel._(
      backEndId: null,
      localId: Uuid().v4(),
      description: 'New transport description',
      problemSeverity: null,
      icon: Icons.lightbulb,
    );
  }

  /// Creates a new [PlaceHolderTransportViewModel] from domain model
  factory TransportViewModel.fromPlaceHolder({required PlaceholderTransport placeHolder}){
    return PlaceHolderTransportViewModel._(
      backEndId: placeHolder.backEndId,
      localId: placeHolder.domainId,
      description: placeHolder.description,
      problemSeverity: null,
      icon: Icons.lightbulb,
    );
  }

  /// Creates a new [RentalCarViewModel] on local UI
  factory TransportViewModel.newRentalCar({
    required String vehicleModelName,
    required String vehicleLicensePlate,
    required String companyName,
    required DateTime checkInDate,
    required DateTime checkOutDate
  }){
    return RentalCarViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        vehicleModelName: vehicleModelName,
        vehicleLicensePlate: vehicleLicensePlate,
        companyName: companyName,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        problemSeverity: null,
        icon: Icons.car_rental
    );
  }

  /// Create a [RentalCarViewModel] from domain model
  factory TransportViewModel.fromRentalCar({required RentalCar rentalCar}){
    return RentalCarViewModel._(
        backEndId: rentalCar.backEndId,
        localId: rentalCar.domainId,
        vehicleModelName: rentalCar.vehicleModelName,
        vehicleLicensePlate: rentalCar.vehicleLicensePlate,
        companyName: rentalCar.companyName,
        checkInDate: rentalCar.checkInDate,
        checkOutDate: rentalCar.checkOutDate,
        problemSeverity: null,
        icon: Icons.car_rental
    );
  }

  /// Create a [BusViewModel] on local UI
  factory TransportViewModel.newBus({
    required String travelNumber,
    required String travelCompany,
    required String departureGate,
    required DateTime departureDateTime,
    required String busStationName,
    required String description,
    required String? details,
  }){
    return BusViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        travelNumber: travelNumber,
        travelCompany: travelCompany,
        departureGate: departureGate,
        departureDateTime: departureDateTime,
        busStationName: busStationName,
        description: description,
        details: details,
        problemSeverity: null,
        icon: Icons.directions_bus
    );
  }

  /// Create a [BusViewModel] from domain model
  factory TransportViewModel.fromBus({required Bus bus}){
    return BusViewModel._(
        backEndId: bus.backEndId,
        localId: bus.domainId,
        travelNumber: bus.travelNumber,
        travelCompany: bus.travelCompany,
        departureGate: bus.departureGate,
        departureDateTime: bus.departureDateTime,
        busStationName: bus.busStationName,
        description: bus.description,
        details: bus.details,
        problemSeverity: null,
        icon: Icons.directions_bus
    );
  }

  /// Create a [AirplaneViewModel] on local UI
  factory TransportViewModel.newAirplane({
    required String flightNumber,
    required String flightCompany,
    required DateTime flightDate,
    required String departureGate,
    required String departureAirport,
    required String arrivalAirport
  }){
    return AirplaneViewModel._(
        backEndId: null,
        localId: Uuid().v4(),
        flightNumber: flightNumber,
        flightCompany: flightCompany,
        flightDate: flightDate,
        departureGate: departureGate,
        departureAirport: departureAirport,
        arrivalAirport: arrivalAirport,
        problemSeverity: null,
        icon: Icons.flight
    );
  }

  /// Create a [AirplaneViewModel] from domain model
  factory TransportViewModel.fromAirplane({required Airplane airplane}){
    return AirplaneViewModel._(
      backEndId: airplane.backEndId,
      localId: airplane.domainId,
      flightNumber: airplane.flightNumber,
      flightCompany: airplane.flightCompany,
      flightDate: airplane.flightDate,
      departureGate: airplane.departureGate,
      departureAirport: airplane.departureAirport,
      arrivalAirport: airplane.arrivalAirport,
      problemSeverity: null,
      icon: Icons.flight
    );
  }

  /// To domain mapper method
  Transport toDomain();

  TransportViewModel copyWith({
    TimelineProblemSeverity? problemSeverity,
  });

  /// Provides the local ID for UI reference
  String get id => localId;
  // Provides the back end id for persistence
  String? get persistedId => backEndId;


}

/// Placeholder view model type, used to represent a [PlaceholderTransport] on the UI
class PlaceHolderTransportViewModel extends TransportViewModel{
  final String description;
  PlaceHolderTransportViewModel._({
    required super.backEndId,
    required super.localId,
    required super.problemSeverity,
    required this.description,
    required super.icon,
  }): super._();

  @override
  Transport toDomain() {
    return Transport.newPlaceholder(
      domainId: localId,
      backEndId: backEndId,
      description: description,
    );
  }

  @override
  PlaceHolderTransportViewModel copyWith({
    TimelineProblemSeverity? problemSeverity,
  }) {
    return PlaceHolderTransportViewModel._(
      backEndId: backEndId,
      localId: localId,
      description: description,
      problemSeverity: problemSeverity ?? this.problemSeverity,
      icon: icon,
    );
  }
}

/// Rental car view model type, used to represent a [RentalCar] on the UI
class RentalCarViewModel extends TransportViewModel{
  final String vehicleModelName;
  final String vehicleLicensePlate;
  final String companyName;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  RentalCarViewModel._({
    required super.backEndId,
    required super.localId,
    required super.problemSeverity,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
    required super.icon
  }): super._();

  String get checkInString => checkInDate.toString();

  String get checkOutString => checkOutDate.toString();

  @override
  Transport toDomain() {
    return Transport.newRentalCar(
      domainId: localId,
      backEndId: backEndId,
      vehicleModelName: vehicleModelName,
      vehicleLicensePlate: vehicleLicensePlate,
      companyName: companyName,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
    );
  }

  @override
  RentalCarViewModel copyWith({
    TimelineProblemSeverity? problemSeverity,
  }) {
    return RentalCarViewModel._(
      backEndId: backEndId,
      localId: localId,
      vehicleModelName: vehicleModelName,
      vehicleLicensePlate: vehicleLicensePlate,
      companyName: companyName,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      problemSeverity: problemSeverity ?? this.problemSeverity,
      icon: icon,
    );
  }
}

/// Bus view model type, used to represent a [Bus] on the UI
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
    required super.problemSeverity,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required super.icon,
    this.details,
  }): super._();

  String get departureDateTimeString => departureDateTime.toString();

  @override
  Transport toDomain() {
    return Transport.newBus(
      domainId: localId,
      backEndId: backEndId,
      travelNumber: travelNumber,
      travelCompany: travelCompany,
      departureGate: departureGate,
      departureDateTime: departureDateTime,
      busStationName: busStationName,
      description: description,
      details: details,
    );
  }

  @override
  BusViewModel copyWith({
    TimelineProblemSeverity? problemSeverity,
  }) {
    return BusViewModel._(
      backEndId: backEndId,
      localId: localId,
      travelNumber: travelNumber,
      travelCompany: travelCompany,
      departureGate: departureGate,
      departureDateTime: departureDateTime,
      busStationName: busStationName,
      description: description,
      details: details,
      problemSeverity: problemSeverity ?? this.problemSeverity,
      icon: icon,
    );
  }
}

/// Airplane view model type, used to represent an [Airplane] on the UI
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
    required super.problemSeverity,
    required super.icon,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  }): super._();

  String get flightDateString => flightDate.toString();

  @override
  Transport toDomain() {
    return Transport.newAirplane(
      domainId: localId,
      backEndId: backEndId,
      flightNumber: flightNumber,
      flightCompany: flightCompany,
      flightDate: flightDate,
      departureGate: departureGate,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
    );
  }

  @override
  AirplaneViewModel copyWith({
    TimelineProblemSeverity? problemSeverity,
  }) {
    return AirplaneViewModel._(
      backEndId: backEndId,
      localId: localId,
      flightNumber: flightNumber,
      flightCompany: flightCompany,
      flightDate: flightDate,
      departureGate: departureGate,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
      problemSeverity: problemSeverity ?? this.problemSeverity,
      icon: icon,
    );
  }
}