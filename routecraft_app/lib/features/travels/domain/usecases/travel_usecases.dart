import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';

class TravelUseCases {
  final TravelRepository repository;

  const TravelUseCases(this.repository);

  Future<Result<Travel>> getTravel(String id) => repository.getTravel(id);

  Future<Result<List<Travel>>> getTravelsForClient(String clientName) =>
      repository.getTravelsForClient(clientName);

  Future<Result<Travel>> createTravel(Travel travel) => repository.createTravel(travel);
}
