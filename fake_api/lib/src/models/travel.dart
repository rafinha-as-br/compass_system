
/* this entity represents the Travel itself.. */
import 'package:mock_repository/mock_repository.dart';
class Travel{
  final String travelName;
  final RoutePlan routePlan;
  final Itinerary itinerary;

  /// from jsonMethod
  factory Travel.fromJson(Map<String, dynamic> json){
    return Travel(
        travelName: json['travelName']
        routePlan: json['routePlan'],
        itinerary: json['itinerary']
    );
  }

  /// to map method
  ///

  Map<String, dynamic> toMap() {
    return {
      'routePlan': routePlan.toMap(),
      'itinerary': itinerary.toMap(),
    };
  }





  Travel({required this.travelName, required this.routePlan, required this.itinerary});

}