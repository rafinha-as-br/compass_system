import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';
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
    final result = await HttpApiClient.instance.get(token, ApiEndpoints.travels);
    // The backend returns a List directly, wrap it for compatibility
    if (result.containsKey('data')) return result;
    return {'data': result};
  }

  Future<Map<String, dynamic>> getTravel(String token, String travelId) async {
    return HttpApiClient.instance.get(token, ApiEndpoints.travelById(travelId));
  }

  Future<Map<String, dynamic>> getTravelsForClient(String token, String clientId) async {
    final result = await HttpApiClient.instance.get(token, ApiEndpoints.travelsByClient(clientId));
    if (result.containsKey('data')) return result;
    return {'data': result};
  }

  Future<Map<String, dynamic>> createTravel(String token, Map<String, dynamic> travelData) async {
    return HttpApiClient.instance.post(token, ApiEndpoints.travels, travelData);
  }

  Future<Map<String, dynamic>> updateTravel(String token, String travelId, Map<String, dynamic> travelData) async {
    return HttpApiClient.instance.put(token, ApiEndpoints.travelById(travelId), travelData);
  }

  Future<Map<String, dynamic>> deleteTravel(String token, String travelId) async {
    return HttpApiClient.instance.delete(token, ApiEndpoints.travelById(travelId));
  }
}