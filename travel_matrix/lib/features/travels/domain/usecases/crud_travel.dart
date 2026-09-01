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

  /// Marks a travel as ready (moves it from [TravelStatus.routeCreated] to
  /// [TravelStatus.itineraryCreated]) by fetching the current travel and
  /// resubmitting it with the updated status.
  Future<Result<Travel>> markAsReady(String id) async {
    final travelResult = await repository.getTravel(id);
    if (!travelResult.isSuccess || travelResult.data == null) {
      return Result.failure(travelResult.error ?? 'Travel not found.');
    }

    travelResult.data!.travelStatus = TravelStatus.itineraryCreated;
    return await repository.updateTravel(travelResult.data!);
  }
}