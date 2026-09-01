import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';

abstract class TravelRepository{

  /// get
  Future<Result<Travel>> getTravel(String id);

  /// get all
  Future<Result<List<Travel>>> getAllTravels();

  /// create
  Future<Result<Travel>> createTravel(Travel travel);

  /// Creates a travel from a raw creation-request payload (client id, agent
  /// id, travel name, route plan) — the backend's create endpoint takes a
  /// different shape than the full [Travel] representation (e.g. a
  /// `clientId` reference rather than the resolved `clientName`), so this
  /// bypasses the [Travel] domain mapping on the way in while still
  /// returning a fully mapped [Travel] from the response.
  Future<Result<Travel>> createTravelFromRequest(Map<String, dynamic> request);

  /// update
  Future<Result<Travel>> updateTravel(Travel travel);

  /// delete
  Future<Result<bool>> deleteTravel(String id);

}