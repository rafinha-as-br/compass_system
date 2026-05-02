

import 'package:travel_matrix/features/travels/presentation/view_models/transports_view_model.dart';

abstract class ItineraryStepViewModel{
  final String id;
  final String title;
  final DateTime startDate;
  final DateTime finishDate;

  ItineraryStepViewModel({
    required this.id,
    required this.title,
    required this.startDate,
    required this.finishDate,
  });

  String get startString => startDate.toString();


  String get finishString => finishDate.toString();


}

class PlaceHolderStepViewModel extends ItineraryStepViewModel{
  PlaceHolderStepViewModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate
  });

}

class StartStepViewModel extends ItineraryStepViewModel{
  StartStepViewModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate
  });

}

class FinishStepModel extends ItineraryStepViewModel{
  FinishStepModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate
  });
}

class StopStepViewModel extends ItineraryStepViewModel{
  final String name;
  final String description;
  final List<String> experiences;

  StopStepViewModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required this.name,
    required this.description,
    required this.experiences
  });

}

class HostingStepViewModel extends ItineraryStepViewModel{
  final String placeName;
  final String address;
  final DateTime checkIn;
  final DateTime checkOut;

  HostingStepViewModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required this.placeName,
    required this.address,
    required this.checkIn,
    required this.checkOut
  });

  String get checkInString => checkIn.toString();

  String get checkOutString => checkOut.toString();


}

class TravelSegmentStepViewModel extends ItineraryStepViewModel{
  final String startPoint;
  final String finishPoint;
  final TransportViewModel transport;

  TravelSegmentStepViewModel({
    required super.id,
    required super.title,
    required super.startDate,
    required super.finishDate,
    required this.startPoint,
    required this.finishPoint,
    required this.transport
  });

}