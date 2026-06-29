import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary_step.dart';
import 'package:travel_matrix/features/travels/domain/repository/itinerary_step_repository.dart';

class ItineraryStepRepositoryImpl implements ItineraryStepRepository{
  @override
  Future<Result<ItineraryStep>> createItineraryStep(Map<String, dynamic> data) {
    throw UnimplementedError("Itinerary steps are upserted via TravelItinerary API.");
  }

  @override
  Future<Result<bool>> deleteItineraryStep(String id) {
    throw UnimplementedError("Itinerary steps are upserted via TravelItinerary API.");
  }

  @override
  Future<Result<ItineraryStep>> getItineraryStep(String id) async{
    throw UnimplementedError("Itinerary steps are fetched via Travel API.");
  }

  @override
  Future<Result<List<ItineraryStep>>> getAllItineraryStep(String id) async{
     throw UnimplementedError("Itinerary steps are fetched via Travel API.");
  }

  @override
  Future<Result<ItineraryStep>> updateItineraryStep(Map<String, dynamic> data) {
    throw UnimplementedError("Itinerary steps are upserted via TravelItinerary API.");
  }

}