import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/transport.dart';

/// Transport view model class, used to represent a [Transport] on the UI
abstract class TransportViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  /// Icon for the step type
  final IconData icon;

  TransportViewModel._({
    required this.backEndId,
    required this.localId,
    required this.icon,
  });

  /// Factory constructor from domain model
  factory TransportViewModel.fromDomain(Transport transport){
    switch (transport) {
      case PlaceholderTransport _:
        return TransportViewModel.fromPlaceHolder(
          id: transport.backEndId!,
          description: transport.description,
        );
      case RentalCar _:
        return TransportViewModel.fromRentalCar(
          vehicleModelName: transport.vehicleModelName,
          vehicleLicensePlate: transport.vehicleLicensePlate,
          companyName: transport.companyName,
          checkInDate: transport.checkInDate,
          checkOutDate: transport.checkOutDate,
        );
      case Bus _:
        return TransportViewModel.fromBus(
          travelNumber: transport.travelNumber,
          travelCompany: transport.travelCompany,
          departureGate: transport.departureGate,
          departureDateTime: transport.departureDateTime,
          busStationName: transport.busStationName,
          description: transport.description,
          details: transport.details,
        );
      case Airplane _:
        return TransportViewModel.fromAirplane(
          flightNumber: transport.flightNumber,
          flightCompany: transport.flightCompany,
          flightDate: transport.flightDate,
          departureGate: transport.departureGate,
          departureAirport: transport.departureAirport,
          arrivalAirport: transport.arrivalAirport,
        );
      default:
      return TransportViewModel.fromPlaceHolder(
        id: transport.backEndId!,
        description: 'No description',
      );


    }
  }

  /// Creates a new [PlaceHolderTransportViewModel] on local UI
  factory TransportViewModel.newPlaceHolder(){
    return PlaceHolderTransportViewModel._(
      backEndId: null,
      localId: Uuid().v4(),
      description: 'New transport description',
      icon: Icons.lightbulb,
    );
  }

  /// Creates a new [PlaceHolderTransportViewModel] from domain model
  factory TransportViewModel.fromPlaceHolder({
    required String id,
    required String description,
  }){
    return PlaceHolderTransportViewModel._(
      backEndId: id,
      localId: Uuid().v4(),
      description: description,
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
        icon: Icons.car_rental
    );
  }

  /// Create a [RentalCarViewModel] from domain model
  factory TransportViewModel.fromRentalCar({
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
        icon: Icons.directions_bus
    );
  }

  /// Create a [BusViewModel] from domain model
  factory TransportViewModel.fromBus({
    required String travelNumber,
    required String travelCompany,
    required String departureGate,
    required DateTime departureDateTime,
    required String busStationName,
    required String description,
    required String? details
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
        icon: Icons.flight
    );
  }

  /// Create a [AirplaneViewModel] from domain model
  factory TransportViewModel.fromAirplane({
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
        icon: Icons.flight
    );
  }

  /// To domain mapper method
  Transport toDomain();

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
}