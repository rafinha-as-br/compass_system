import 'package:uuid/uuid.dart';

import '../../domain/entities/transport.dart';
import 'package:travel_matrix/core/constants/api_fields.dart';
import 'package:travel_matrix/shared/models/place_suggestion.dart';

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
  PlaceHolderStepDTO._({required super.id, required this.description})
    : super._();

  /// from Json factory constructor
  factory PlaceHolderStepDTO.fromJson(Map<String, dynamic> json) {
    return PlaceHolderStepDTO._(
      id: json[TransportApiFields.id]?.toString(),
      description: json[TransportApiFields.description]?.toString() ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportApiFields.type: TransportApiValues.placeholder,
      TransportApiFields.id: id,
      TransportApiFields.description: description,
    };
  }

  @override
  Transport toDomain() {
    return Transport.newPlaceholder(
      domainId: Uuid().v4(),
      backEndId: id,
      description: description,
    );
  }

  /// From domain factory constructor
  factory PlaceHolderStepDTO.fromDomain({
    required PlaceholderTransport placeholder,
  }) {
    return PlaceHolderStepDTO._(
      id: placeholder.backEndId,
      description: placeholder.description,
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

  final String pickupLocation;
  final PlaceCoordinate? pickupLocationCoordinate;

  RentalCarDTO._({
    required super.id,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
    this.pickupLocation = '',
    this.pickupLocationCoordinate,
  }) : super._();

  /// from Json factory constructor
  factory RentalCarDTO.fromJson(Map<String, dynamic> json) {
    return RentalCarDTO._(
      id: json[TransportApiFields.id]?.toString(),
      vehicleModelName:
          json[TransportApiFields.vehicleModelName]?.toString() ?? '',
      vehicleLicensePlate:
          json[TransportApiFields.vehicleLicensePlate]?.toString() ?? '',
      companyName: json[TransportApiFields.companyName]?.toString() ?? '',
      checkInDate: _parseDate(json[TransportApiFields.checkInDate]),
      checkOutDate: _parseDate(json[TransportApiFields.checkOutDate]),
      pickupLocation: json[TransportApiFields.pickupLocation]?.toString() ?? '',
      pickupLocationCoordinate: PlaceCoordinate.tryFromJson(json[TransportApiFields.pickupLocationCoordinate]),
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
      TransportApiFields.pickupLocation: pickupLocation,
      TransportApiFields.pickupLocationCoordinate: pickupLocationCoordinate?.toJson(),
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
      checkOutDate: checkOutDate,
      pickupLocation: pickupLocation,
      pickupLocationCoordinate: pickupLocationCoordinate,
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
      pickupLocation: rentalCar.pickupLocation,
      pickupLocationCoordinate: rentalCar.pickupLocationCoordinate,
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
  final PlaceCoordinate? busStationCoordinate;

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
    this.busStationCoordinate,
  }) : super._();

  /// from Json factory constructor
  factory BusDTO.fromJson(Map<String, dynamic> json) {
    return BusDTO(
      id: json[TransportApiFields.id]?.toString(),
      travelNumber: json[TransportApiFields.travelNumber]?.toString() ?? '',
      travelCompany: json[TransportApiFields.travelCompany]?.toString() ?? '',
      departureGate: json[TransportApiFields.departureGate]?.toString() ?? '',
      departureDateTime: _parseDate(json[TransportApiFields.departureDateTime]),
      busStationName: json[TransportApiFields.busStationName]?.toString() ?? '',
      description: json[TransportApiFields.description]?.toString() ?? '',
      details: json[TransportApiFields.details]?.toString(),
      busStationCoordinate: PlaceCoordinate.tryFromJson(json[TransportApiFields.busStationCoordinate]),
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
      TransportApiFields.busStationCoordinate: busStationCoordinate?.toJson(),
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
      busStationCoordinate: busStationCoordinate,
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
      busStationCoordinate: bus.busStationCoordinate,
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
  final PlaceCoordinate? departureAirportCoordinate;

  /// Arrival airport
  final String arrivalAirport;
  final PlaceCoordinate? arrivalAirportCoordinate;

  AirplaneDTO({
    required super.id,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
    this.departureAirportCoordinate,
    this.arrivalAirportCoordinate,
  }) : super._();

  factory AirplaneDTO.fromJson(Map<String, dynamic> json) {
    return AirplaneDTO(
      id: json[TransportApiFields.id]?.toString(),
      flightNumber: json[TransportApiFields.flightNumber]?.toString() ?? '',
      flightCompany: json[TransportApiFields.companyName]?.toString() ?? '',
      flightDate: _parseDate(json[TransportApiFields.flightDate]),
      departureGate: json[TransportApiFields.departureGate]?.toString() ?? '',
      departureAirport:
          json[TransportApiFields.departureAirport]?.toString() ?? '',
      arrivalAirport: json[TransportApiFields.arrivalAirport]?.toString() ?? '',
      departureAirportCoordinate: PlaceCoordinate.tryFromJson(json[TransportApiFields.departureAirportCoordinate]),
      arrivalAirportCoordinate: PlaceCoordinate.tryFromJson(json[TransportApiFields.arrivalAirportCoordinate]),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      TransportApiFields.type: TransportApiValues.airplane,
      TransportApiFields.id: id,
      TransportApiFields.flightNumber: flightNumber,
      TransportApiFields.companyName: flightCompany,
      TransportApiFields.flightDate: flightDate.toIso8601String(),
      TransportApiFields.departureGate: departureGate,
      TransportApiFields.departureAirport: departureAirport,
      TransportApiFields.arrivalAirport: arrivalAirport,
      TransportApiFields.departureAirportCoordinate: departureAirportCoordinate?.toJson(),
      TransportApiFields.arrivalAirportCoordinate: arrivalAirportCoordinate?.toJson(),
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
      departureAirportCoordinate: departureAirportCoordinate,
      arrivalAirportCoordinate: arrivalAirportCoordinate,
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
      departureAirportCoordinate: airplane.departureAirportCoordinate,
      arrivalAirportCoordinate: airplane.arrivalAirportCoordinate,
    );
  }
}

DateTime _parseDate(dynamic value) {
  return DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
}
