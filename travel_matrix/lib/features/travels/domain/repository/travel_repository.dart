
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';

abstract class TravelRepository{

  /// get
  Future<Result<Travel>> getTravel(String id);

  /// create
  Future<Result<Travel>> createTravel(Map<String, dynamic> data);

  /// update
  Future<Result<Travel>> updateTravel(Map<String, dynamic> data);

  /// delete
  Future<Result<bool>> deleteTravel(String id);

}