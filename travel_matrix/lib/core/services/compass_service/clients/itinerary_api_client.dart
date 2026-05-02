
import '../api_client.dart';

class ItineraryApiClient{
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

  Future<Map<String, dynamic>> getAllItineraries(String token) async {
    return ApiClient().get(token, '/itineraries', {}, {}, {});
  }

  Future<Map<String, dynamic>> getItinerary(String token, String itineraryId) async {
    return ApiClient().get(token, '/itineraries/$itineraryId', {}, {}, {});
  }

  Future<Map<String, dynamic>> createItinerary(String token, Map<String, dynamic> itineraryData) async {
    return ApiClient().post(token, '/itineraries', {}, {}, itineraryData);
  }

  Future<Map<String, dynamic>> updateItinerary(String token, String itineraryId, Map<String, dynamic> itineraryData) async {
    return ApiClient().put(token, '/itineraries/$itineraryId', {}, {}, itineraryData);
  }

  Future<Map<String, dynamic>> deleteItinerary(String token, String itineraryId) async {
    return ApiClient().delete(token, '/itineraries/$itineraryId', {}, {}, {});
  }

  Future<Map<String, dynamic>> getAllItinerarySteps(String token, String itineraryId) async {
    return ApiClient().get(token, '/itineraries/$itineraryId/steps', {}, {}, {});
  }

  Future<Map<String, dynamic>> getItineraryStep(String token, String stepId) async {
    return ApiClient().get(token, '/itinerary_steps/$stepId', {}, {}, {});
  }




}