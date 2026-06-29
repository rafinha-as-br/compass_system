import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';

abstract class ItineraryRepository {
  /// upsert
  Future<Result<Itinerary>> upsertItinerary(String travelId, Itinerary itinerary);
}