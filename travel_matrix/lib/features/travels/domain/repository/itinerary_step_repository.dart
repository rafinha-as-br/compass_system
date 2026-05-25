
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary_step.dart';

abstract class ItineraryStepRepository{

  /// get
  Future<Result<ItineraryStep>> getItineraryStep(String id);

  // get all
  Future<Result<List<ItineraryStep>>> getAllItineraryStep(String id);

  /// create
  Future<Result<ItineraryStep>> createItineraryStep(Map<String, dynamic> data);

  /// update
  Future<Result<ItineraryStep>> updateItineraryStep(Map<String, dynamic> data);

  /// delete
  Future<Result<bool>> deleteItineraryStep(String id);


}