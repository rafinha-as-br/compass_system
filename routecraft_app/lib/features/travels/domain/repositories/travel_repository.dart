import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

abstract interface class TravelRepository {
  Future<Result<Travel>> getTravel(String id);
  Future<Result<List<Travel>>> getTravelsForClient(String clientName);
  Future<Result<Travel>> createTravel(Travel travel);
}
