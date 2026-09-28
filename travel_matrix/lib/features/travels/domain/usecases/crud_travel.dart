import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';

class CrudTravelUseCases {
  final TravelRepository repository;

  CrudTravelUseCases(this.repository);

  Future<Result<Travel>> create(Travel travel) async {
    return await repository.createTravel(travel);
  }

  /// See [TravelRepository.createTravelFromRequest].
  Future<Result<Travel>> createFromRequest(Map<String, dynamic> request) async {
    return await repository.createTravelFromRequest(request);
  }

  Future<Result<Travel>> read(String id) async {
    return await repository.getTravel(id);
  }

  Future<Result<List<Travel>>> readAll() async {
    return await repository.getAllTravels();
  }

  Future<Result<Travel>> update(Travel travel) async {
    return await repository.updateTravel(travel);
  }

  Future<Result<bool>> delete(String id) async {
    return await repository.deleteTravel(id);
  }

  /// Confirms "Preparar viagem" by fetching the current travel and
  /// resubmitting it with [Travel.prepared] set to true. Does not touch
  /// [Travel.travelStatus] — that already advances to
  /// [TravelStatus.itineraryCreated] on its own, as soon as an itinerary
  /// exists (CPS-166).
  Future<Result<Travel>> markAsReady(String id) async {
    final travelResult = await repository.getTravel(id);
    if (!travelResult.isSuccess || travelResult.data == null) {
      return Result.failure(travelResult.error ?? 'Travel not found.');
    }

    final travel = travelResult.data!;
    // This use case owns the invariant, not just the app bar's disabled
    // button — an itinerary must exist before the trip can be prepared.
    if (travel.travelStatus != TravelStatus.itineraryCreated) {
      return Result.failure('Travel needs an itinerary before it can be prepared.');
    }

    travel.prepared = true;
    return await repository.updateTravel(travel);
  }
}