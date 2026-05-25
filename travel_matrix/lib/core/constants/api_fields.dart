/*
this file centralizes all API field names and fixed values used across DTOs and data layer serialization.
*/
/// ===========================================================
/// COMMON FIELDS
/// ===========================================================
abstract final class CommonApiFields {
static const String id = 'id';

static const String title = 'title';
static const String name = 'name';
static const String description = 'description';

static const String type = 'type';

static const String startDate = 'startDate';
static const String finishDate = 'finishDate';

static const String createdAt = 'createdAt';
static const String updatedAt = 'updatedAt';
}

/// ===========================================================
/// TRAVEL
/// ===========================================================

abstract final class TravelApiFields {
static const String id = CommonApiFields.id;

static const String client = 'clientName';

static const String travelName = 'travelName';

static const String travelStatus = 'travelStatus';

static const String startDate = CommonApiFields.startDate;
static const String finishDate = CommonApiFields.finishDate;

static const String routePlan = 'routePlan';

static const String itinerary = 'itinerary';

static const String participants = 'participants';

static const String events = 'events';
}

/// ===========================================================
/// TRAVEL EVENT
/// ===========================================================

abstract final class TravelEventApiFields {
static const String id = CommonApiFields.id;

static const String eventType = 'eventType';

static const String eventDate = 'eventDate';

static const String eventDescription = 'eventDescription';

}

/// ===========================================================
/// PERSON
/// ===========================================================

abstract final class PersonApiFields {
static const String id = CommonApiFields.id;

static const String name = CommonApiFields.name;

static const String age = 'age';

static const String sex = 'sex';
}

/// ===========================================================
/// ROUTE PLAN
/// ===========================================================

abstract final class RoutePlanApiFields {
static const String id = CommonApiFields.id;

static const String startDate = CommonApiFields.startDate;

static const String finishDate = CommonApiFields.finishDate;

static const String startLocation = 'startLocation';

static const String destination = 'destination';

static const String interestPoints = 'interestPoints';
}

/// ===========================================================
/// INTEREST POINT
/// ===========================================================

abstract final class InterestPointApiFields {
static const String name = CommonApiFields.name;

static const String description =
CommonApiFields.description;
}

/// ===========================================================
/// ITINERARY
/// ===========================================================

abstract final class ItineraryApiFields {
static const String id = CommonApiFields.id;

static const String agentName = 'agentName';

static const String steps = 'steps';
}

/// ===========================================================
/// ITINERARY STEP
/// ===========================================================

abstract final class ItineraryStepApiFields {
static const String id = CommonApiFields.id;

static const String title = CommonApiFields.title;

static const String startDate =
CommonApiFields.startDate;

static const String finishDate =
CommonApiFields.finishDate;

static const String finished = 'finished';

static const String type = CommonApiFields.type;

static const String location = 'location';

static const String isStart = 'isStart';

static const String name = CommonApiFields.name;

static const String description =
CommonApiFields.description;

static const String experiences = 'experiences';

static const String address = 'address';

static const String checkIn = 'checkIn';

static const String checkOut = 'checkOut';

static const String transport = 'transport';

static const String startPoint = 'startPoint';

static const String finishPoint = 'finishPoint';
}

/// ===========================================================
/// ITINERARY STEP VALUES
/// ===========================================================

abstract final class ItineraryStepApiValues {
static const String placeholder = 'placeholder';

static const String stop = 'stop';

static const String hosting = 'hosting';

static const String travelSegment = 'travel_segment';
}

/// ===========================================================
/// TRANSPORT
/// ===========================================================

abstract final class TransportApiFields {
static const String id = CommonApiFields.id;

static const String type = CommonApiFields.type;

/// Rental car
static const String vehicleModelName =
'vehicleModelName';

static const String vehicleLicensePlate =
'vehicleLicensePlate';

static const String companyName = 'companyName';

static const String checkInDate = 'checkInDate';

static const String checkOutDate = 'checkOutDate';

/// Bus
static const String travelNumber = 'travelNumber';

static const String travelCompany = 'travelCompany';

static const String departureGate = 'departureGate';

static const String departureDateTime =
'departureDateTime';

static const String busStationName =
'busStationName';

static const String description =
CommonApiFields.description;

static const String details = 'details';

/// Airplane
static const String flightNumber = 'flightNumber';


static const String flightDate = 'flightDate';

static const String departureAirport =
'departureAirport';

static const String arrivalAirport =
'arrivalAirport';
}

/// ===========================================================
/// TRANSPORT VALUES
/// ===========================================================

abstract final class TransportApiValues {
static const String placeholder = 'placeholder';

static const String rentalCar = 'rental_car';

static const String bus = 'bus';

static const String airplane = 'airplane';
}

