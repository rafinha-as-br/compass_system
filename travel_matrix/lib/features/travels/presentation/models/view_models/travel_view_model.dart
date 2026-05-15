

import 'package:travel_matrix/features/travels/presentation/models/view_models/route_view_model.dart';

import 'itinerary_view_model.dart';

enum TravelStatusModel{
  notReady,
  ready,
  inProgress,
  completed,
}

class TravelViewModel{
  final String id;
  final String clientName;
  final String agentName;
  final String travelTitle;
  final TravelStatusModel status;
  final RouteViewModel route;
  final ItineraryViewModel? itinerary;


  TravelViewModel({
    required this.id,
    required this.clientName,
    required this.agentName,
    required this.travelTitle,
    required this.status,
    required this.route,
    this.itinerary,
  });

  String get statusString{
    switch(status){
      case TravelStatusModel.notReady:
        return 'Not Ready';
        case TravelStatusModel.ready:
        return 'Ready';
        case TravelStatusModel.inProgress:
        return 'In Progress';
        case TravelStatusModel.completed:
        return 'Completed';
    }
  }


}