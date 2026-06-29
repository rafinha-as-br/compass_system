import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';

abstract class TravelRepository{

  /// get
  Future<Result<Travel>> getTravel(String id);

  /// get all
  Future<Result<List<Travel>>> getAllTravels();

  /// create
  Future<Result<Travel>> createTravel(Travel travel);

  /// update
  Future<Result<Travel>> updateTravel(Travel travel);

  /// delete
  Future<Result<bool>> deleteTravel(String id);

}