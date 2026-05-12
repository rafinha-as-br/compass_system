
abstract class Transport {
  final String id;

  Transport({required this.id});

  Map<String, dynamic> toJson();
}

class RentalCar extends Transport {
  final String vehicleModelName;
  final String vehicleLicensePlate;
  final String companyName;
  final DateTime checkInDate;
  final DateTime checkOutDate;

  RentalCar({
    required super.id,
    required this.vehicleModelName,
    required this.vehicleLicensePlate,
    required this.companyName,
    required this.checkInDate,
    required this.checkOutDate,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleModelName': vehicleModelName,
      'vehicleLicensePlate': vehicleLicensePlate,
      'companyName': companyName,
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'type': 'RentalCar',
    };
  }
}

class Bus extends Transport {
  final String travelNumber;
  final String travelCompany;
  final String departureGate;
  final DateTime departureDateTime;
  final String busStationName;
  final String description;
  final String? details;

  Bus({
    required super.id,
    required this.travelNumber,
    required this.travelCompany,
    required this.departureGate,
    required this.departureDateTime,
    required this.busStationName,
    required this.description,
    required this.details,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'travelNumber': travelNumber,
      'travelCompany': travelCompany,
      'departureGate': departureGate,
      'departureDateTime': departureDateTime.toIso8601String(),
      'busStationName': busStationName,
      'description': description,
      'details': details,
      'type': 'Bus',
    };
  }
}

class Airplane extends Transport {
  final String flightNumber;
  final String flightCompany;
  final DateTime flightDate;
  final String departureGate;
  final String departureAirport;
  final String arrivalAirport;

  Airplane({
    required super.id,
    required this.flightNumber,
    required this.flightCompany,
    required this.flightDate,
    required this.departureGate,
    required this.departureAirport,
    required this.arrivalAirport,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flightNumber': flightNumber,
      'flightCompany': flightCompany,
      'flightDate': flightDate.toIso8601String(),
      'departureGate': departureGate,
      'departureAirport': departureAirport,
      'arrivalAirport': arrivalAirport,
      'type': 'Airplane',
    };
  }
}