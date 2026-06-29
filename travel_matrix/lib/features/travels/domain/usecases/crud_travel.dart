import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';

class CrudTravelUseCases {
  final TravelRepository repository;

  CrudTravelUseCases(this.repository);

  Future<Result<Travel>> create(Travel travel) async {
    return await repository.createTravel(travel);
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
}