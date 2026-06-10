import 'package:travel_matrix/core/services/compass_service/mock_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';

class TravelApiClient {
  static TravelApiClient? _instance;

  TravelApiClient._();

  static Future<TravelApiClient> init() async {
    assert(_instance == null, 'TravelApiClient instance already initialized!');
    _instance ??= TravelApiClient._();
    return _instance!;
  }

  static TravelApiClient get instance {
    assert(_instance != null, 'TravelApiClient instance not initialized!');
    return _instance!;
  }

  Future<Map<String, dynamic>> getAllTravels(String token) async {
    return MockApiClient().get(token, ApiEndpoints.travels, {}, {}, {});
  }

  Future<Map<String, dynamic>> getTravel(String token, String travelId) async {
    return MockApiClient().get(token, ApiEndpoints.travelById(travelId), {}, {}, {});
  }

  Future<Map<String, dynamic>> getTravelsForClient(String token, String clientId) async {
    return MockApiClient().get(token, '/travels/client/$clientId', {}, {}, {});
  }

  Future<Map<String, dynamic>> createTravel(String token, Map<String, dynamic> travelData) async {
    return MockApiClient().post(token, ApiEndpoints.travels, {}, {}, travelData);
  }

  Future<Map<String, dynamic>> updateTravel(String token, String travelId, Map<String, dynamic> travelData) async {
    return MockApiClient().put(token, ApiEndpoints.travelById(travelId), {}, {}, travelData);
  }

  Future<Map<String, dynamic>> deleteTravel(String token, String travelId) async {
    return MockApiClient().delete(token, ApiEndpoints.travelById(travelId), {}, {}, {});
  }

}