import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/repository/itinerary_repository.dart';

/// Uses Cases responsible for CRUD operations on Itinerary entity.
class CrudItinerary {
  final ItineraryRepository repository;

  CrudItinerary(this.repository);

  /// Using [ItineraryRepository], upserts an Itinerary on the API.
  Future<Result<Itinerary>> upsert(String travelId, Itinerary itinerary) async {
    return await repository.upsertItinerary(travelId, itinerary);
  }
}