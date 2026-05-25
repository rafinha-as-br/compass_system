import 'package:travel_matrix/core/services/compass_service/api_client.dart';
import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';

class ItineraryApiClient {
  static ItineraryApiClient? _instance;

  ItineraryApiClient._();

  static Future<ItineraryApiClient> init() async {
    assert(_instance == null, 'ItineraryApiClient instance already initialized!');
    _instance ??= ItineraryApiClient._();
    return _instance!;
  }

  static ItineraryApiClient get instance {
    assert(_instance != null, 'ItineraryApiClient instance not initialized!');
    return _instance!;
  }

  Future<Map<String, dynamic>> upsertItinerary(String token, String travelId, Map<String, dynamic> itineraryData) async {
    return ApiClient().put(token, ApiEndpoints.travelItinerary(travelId), {}, {}, itineraryData);
  }
}