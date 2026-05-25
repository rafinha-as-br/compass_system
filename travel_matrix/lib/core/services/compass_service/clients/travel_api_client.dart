import 'package:travel_matrix/core/services/compass_service/api_client.dart';

class TravelApiClient{
  static TravelApiClient? _instance;
  // to replace the HTTP request

  TravelApiClient._();

  static Future<TravelApiClient> init() async{
    assert(_instance == null, 'TravelApiClient instance already initialized!');
    _instance ??= TravelApiClient._();
    return _instance!;
  }

  static TravelApiClient get instance{
    assert(_instance != null, 'TravelApiClient instance not initialized!');
    return _instance!;
  }

  Future<Map<String, dynamic>> getAllTravels(String token) async{
    return ApiClient().get(token, '/travels', {}, {}, {});
  }

  Future<Map<String, dynamic>> getTravel(String token, String travelId) async{
    return ApiClient().get(token, '/travels/$travelId', {}, {}, {});
  }

  Future<Map<String, dynamic>> getTravelsForClient(String token, String clientId) async{
    return ApiClient().get(token, '/travels/client/$clientId', {}, {}, {});
  }

  Future<Map<String, dynamic>> createTravel(String token, Map<String, dynamic> travelData) async{
    return ApiClient().post(token, '/travels', {}, {}, travelData);
  }

  Future<Map<String, dynamic>> updateTravel(String token, String travelId, Map<String, dynamic> travelData) async{
    return ApiClient().put(token, '/travels/$travelId', {}, {}, travelData);
  }

  Future<Map<String, dynamic>> deleteTravel(String token, String travelId) async{
    return ApiClient().delete(token, '/travels/$travelId', {}, {}, {});
  }

  Future<Map<String, dynamic>> getPersons(String token, String travelId) async{
    return ApiClient().get(token, '/travels/$travelId/persons', {}, {}, {});
  }



}