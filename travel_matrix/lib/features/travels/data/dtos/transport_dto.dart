import 'package:uuid/uuid.dart';

import '../../domain/entities/transport.dart';
import 'package:travel_matrix/core/constants/api_fields.dart';

/// Data transfer object for [Transport], having the same structure as the API.
abstract class TransportDTO {
  /// Main id used for API reference
  final String? id;

  TransportDTO._({required this.id});

  /// Factory constructor to create a Transport DTO type from JSON
  factory TransportDTO.fromJson(Map<String, dynamic> json) {
    final type = json[TransportApiFields.type];
    switch (type) {
      case TransportApiValues.placeholder:
        return PlaceHolderStepDTO.fromJson(json);
      case TransportApiValues.rentalCar:
        return RentalCarDTO.fromJson(json);
      case TransportApiValues.bus:
        return BusDTO.fromJson(json);
      case TransportApiValues.airplane:
        return AirplaneDTO.fromJson(json);
      default:
        /// Return a placeholder and throw the rest of the data out
        return PlaceHolderStepDTO.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();

  /// To domain mapper method
  Transport toDomain();

  /// From domain factory constructor
  factory TransportDTO.fromDomain({required Transport transport}) {
    switch (transport) {
      case PlaceholderTransport _:
        return PlaceHolderStepDTO.fromDomain(placeholder: transport);
      case RentalCar _:
        return RentalCarDTO.fromDomain(rentalCar: transport);
      case Bus _:
        return BusDTO.fromDomain(bus: transport);
      case Airplane _:
        return AirplaneDTO.fromDomain(airplane: transport);
      default:
        throw Exception('Unknown transport type: ${transport.runtimeType}');
    }
  }

}

/// Data transfer object for [PlaceholderTransport], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [PlaceholderTransport] and [PlaceHolderStepDTO].
class PlaceHolderStepDTO extends TransportDTO {
  /// Description for the placeholder
  final String description;
  PlaceHolderStepDTO._({required super.id, required this.description}): super._();

  /// from Json factory constructor
  factory PlaceHolderStepDTO.fromJson(Map<String, dynamic> json) {
    return PlaceHolderStepDTO._(
      id: json[TransportApiFields.id],
      description: json[TransportApiFields.description]
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportApiFields.type: TransportApiValues.placeholder,
      TransportApiFields.id: id,
    };
  }

  @override
  Transport toDomain() {
    return Transport.newPlaceholder(
      domainId: Uuid().v4(),
      backEndId: id,
      description: description
    );
  }

  /// From domain factory constructor
  factory PlaceHolderStepDTO.fromDomain({required PlaceholderTransport placeholder}) {
    return PlaceHolderStepDTO._(
        id: placeholder.backEndId,
        description: placeholder.description
    );
  }


}

/// Data transfer object for [RentalCar], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [RentalCar] and [RentalCarDTO].
class RentalCarDTO extends TransportDTO {
  /// Vehicle model name used on the rental car
  final String vehicleModelName;
  /// Vehicle license plate used on the rental car
  final String vehicleLicensePlate;
  /// Company name used on the rental car
  final String companyName;
  /// Check in date for getting the car
  final DateTime checkInDate;
  /// Check out date to return the car
  final DateTime checkOutDate;

  RentalCarDTO._({
    required super.id,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
  }): super._();

  /// from Json factory constructor
  factory RentalCarDTO.fromJson(Map<String, dynamic> json) {
    return RentalCarDTO._(
      id: json[TransportApiFields.id],
      vehicleModelName: json[TransportApiFields.vehicleModelName],
      vehicleLicensePlate: json[TransportApiFields.vehicleLicensePlate],
      companyName: json[TransportApiFields.companyName],
      checkInDate: DateTime.parse(json[TransportApiFields.checkInDate]),
      checkOutDate: DateTime.parse(json[TransportApiFields.checkOutDate]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportApiFields.type: TransportApiValues.rentalCar,
      TransportApiFields.id: id,
      TransportApiFields.vehicleModelName: vehicleModelName,
      TransportApiFields.vehicleLicensePlate: vehicleLicensePlate,
      TransportApiFields.companyName: companyName,
      TransportApiFields.checkInDate: checkInDate.toIso8601String(),
      TransportApiFields.checkOutDate: checkOutDate.toIso8601String(),
    };
  }

  @override
  Transport toDomain() {
    return Transport.newRentalCar(
      domainId: Uuid().v4(),
      backEndId: id,
      vehicleModelName: vehicleModelName,
      vehicleLicensePlate: vehicleLicensePlate,
      companyName: companyName,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate
    );
  }

  /// From domain factory constructor
  factory RentalCarDTO.fromDomain({required RentalCar rentalCar}) {
    return RentalCarDTO._(
      id: rentalCar.backEndId,
      vehicleModelName: rentalCar.vehicleModelName,
      vehicleLicensePlate: rentalCar.vehicleLicensePlate,
      companyName: rentalCar.companyName,
      checkInDate: rentalCar.checkInDate,
      checkOutDate: rentalCar.checkOutDate,
    );
  }

}

/// Data transfer object for [Bus], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Bus] and [BusDTO].
class BusDTO extends TransportDTO {
  /// Ticket number
  final String travelNumber;
  /// Company name
  final String travelCompany;
  /// Departure gate to get on the bus
  final String departureGate;
  /// Departure date and time
  final DateTime departureDateTime;
  /// Bus station name to get on the bus
  final String busStationName;
  /// Description of the bus travel
  final String description;
  /// Extra details if necessary
  final String? details;

  BusDTO({
    required super.id,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required this.details,
  }): super._();

  /// from Json factory constructor
  factory BusDTO.fromJson(Map<String, dynamic> json) {
    return BusDTO(
      id: json[TransportApiFields.id],
      travelNumber: json[TransportApiFields.travelNumber],
      travelCompany: json[TransportApiFields.travelCompany],
      departureGate: json[TransportApiFields.departureGate],
      departureDateTime: DateTime.parse(json[TransportApiFields.departureDateTime]),
      busStationName: json[TransportApiFields.busStationName],
      description: json[TransportApiFields.description],
      details: json[TransportApiFields.details],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportApiFields.type: TransportApiValues.bus,
      TransportApiFields.id: id,
      TransportApiFields.travelNumber: travelNumber,
      TransportApiFields.travelCompany: travelCompany,
      TransportApiFields.departureGate: departureGate,
      TransportApiFields.departureDateTime: departureDateTime.toIso8601String(),
      TransportApiFields.busStationName: busStationName,
      TransportApiFields.description: description,
      TransportApiFields.details: details,
    };
  }

  @override
  Transport toDomain() {
    return Transport.newBus(
      domainId: Uuid().v4(),
      backEndId: id,
      travelNumber: travelNumber,
      travelCompany: travelCompany,
      departureGate: departureGate,
      departureDateTime: departureDateTime,
      busStationName: busStationName,
      description: description,
      details: details,
    );
  }

  /// From domain factory constructor
  factory BusDTO.fromDomain({required Bus bus}) {
    return BusDTO(
      id: bus.backEndId,
      travelNumber: bus.travelNumber,
      travelCompany: bus.travelCompany,
      departureGate: bus.departureGate,
      departureDateTime: bus.departureDateTime,
      busStationName: bus.busStationName,
      description: bus.description,
      details: bus.details,
    );
  }


}

/// Data transfer object for [Airplane], having the same structure as the API.
///
/// This class contains the mapper methods to convert between [Airplane] and [AirplaneDTO].
class AirplaneDTO extends TransportDTO {
  /// Flight number
  final String flightNumber;
  /// Company name
  final String flightCompany;
  /// Flight date and time
  final DateTime flightDate;
  /// Departure gate to get on the airplane
  final String departureGate;
  /// Departure airport
  final String departureAirport;
  /// Arrival airport
  final String arrivalAirport;

  AirplaneDTO({
    required super.id,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  }): super._();

  factory AirplaneDTO.fromJson(Map<String, dynamic> json) {
    return AirplaneDTO(
      id: json[TransportApiFields.id],
      flightNumber: json[TransportApiFields.flightNumber],
      flightCompany: json[TransportApiFields.flightCompany],
      flightDate: DateTime.parse(json[TransportApiFields.flightDate]),
      departureGate: json[TransportApiFields.departureGate],
      departureAirport: json[TransportApiFields.departureAirport],
      arrivalAirport: json[TransportApiFields.arrivalAirport],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportApiFields.type: TransportApiValues.airplane,
      TransportApiFields.id: id,
      TransportApiFields.flightNumber: flightNumber,
      TransportApiFields.flightCompany: flightCompany,
      TransportApiFields.flightDate: flightDate.toIso8601String(),
      TransportApiFields.departureGate: departureGate,
      TransportApiFields.departureAirport: departureAirport,
      TransportApiFields.arrivalAirport: arrivalAirport,
    };
  }

  @override
  Transport toDomain() {
    return Transport.newAirplane(
      domainId: Uuid().v4(),
      backEndId: id,
      flightNumber: flightNumber,
      flightCompany: flightCompany,
      flightDate: flightDate,
      departureGate: departureGate,
      departureAirport: departureAirport,
      arrivalAirport: arrivalAirport,
    );
  }

  /// From domain factory constructor
  factory AirplaneDTO.fromDomain({required Airplane airplane}) {
    return AirplaneDTO(
      id: airplane.backEndId,
      flightNumber: airplane.flightNumber,
      flightCompany: airplane.flightCompany,
      flightDate: airplane.flightDate,
      departureGate: airplane.departureGate,
      departureAirport: airplane.departureAirport,
      arrivalAirport: airplane.arrivalAirport,
    );
  }

}


