
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';

abstract class ItineraryRepository{

  /// get
  Future<Result<Itinerary>> getItinerary(String id);

  /// create
  Future<Result<Itinerary>> createItinerary(Map<String, dynamic> data);

  /// update
  Future<Result<Itinerary>> updateItinerary(Map<String, dynamic> data);

  /// delete
  Future<Result<bool>> deleteItinerary(String id);


}