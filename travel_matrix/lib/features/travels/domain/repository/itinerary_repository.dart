

import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';

abstract class ItineraryRepository{

  /// get
  Future<Result<Itinerary>> getItinerary(String id);

  /// create
  Future<Result> createItinerary(Itinerary itinerary);

  /// update
  Future<Result> updateItinerary(Map<String, dynamic> data);

  /// delete
  Future<Result> deleteItinerary(String id);


}