import 'package:mock_repository/mock_repository.dart';

/// Wraps MockApiService for the Travel Matrix application.
/// All methods pass through the bearer token for authentication.
class CompassService {
  static CompassService? _instance;
  final MockApiService _apiService;

  CompassService._() : _apiService = MockApiService();

  static Future<CompassService> init() async {
    _instance ??= CompassService._();
    return _instance!;
  }

  static CompassService get instance {
    assert(_instance != null, 'CompassService instance not initialized!');
    return _instance!;
  }

  // ─── Auth ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) {
    return _apiService.login(email, password);
  }

  // ─── Users ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUser(String token) {
    return _apiService.getUser(token);
  }

  Future<Map<String, dynamic>> getAllUsers(String token) {
    return _apiService.getAllUsers(token);
  }

  Future<Map<String, dynamic>> createUser(
    String token,
    Map<String, dynamic> userData,
  ) {
    return _apiService.createUser(token, userData);
  }

  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) {
    return _apiService.updateUser(token, userData);
  }

  Future<Map<String, dynamic>> deleteUser(String token, String userId) {
    return _apiService.deleteUser(token, userId);
  }

  // ─── Travels ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getAllTravels(String token) {
    return _apiService.getAllTravels(token);
  }

  Future<Map<String, dynamic>> getTravel(String token, String travelId) {
    return _apiService.getTravel(token, travelId);
  }

  Future<Map<String, dynamic>> getTravelsForClient(
    String token,
    String clientId,
  ) {
    return _apiService.getTravelsForClient(token, clientId);
  }

  Future<Map<String, dynamic>> createTravel(
    String token,
    Map<String, dynamic> travelData,
  ) {
    return _apiService.createTravel(token, travelData);
  }

  Future<Map<String, dynamic>> updateTravel(
    String token,
    String travelId,
    Map<String, dynamic> travelData,
  ) {
    return _apiService.updateTravel(token, travelId, travelData);
  }

  Future<Map<String, dynamic>> deleteTravel(
    String token,
    String travelId,
  ) {
    return _apiService.deleteTravel(token, travelId);
  }

  // ─── Routes (within Travel) ─────────────────────────────────────────

  Future<Map<String, dynamic>> updateRoute(
    String token,
    String travelId,
    Map<String, dynamic> routeData,
  ) {
    return _apiService.updateRoute(token, travelId, routeData);
  }

  // ─── Itineraries (within Travel) ────────────────────────────────────

  Future<Map<String, dynamic>> createItinerary(
    String token,
    String travelId,
    Map<String, dynamic> itineraryData,
  ) {
    return _apiService.createItinerary(token, travelId, itineraryData);
  }

  Future<Map<String, dynamic>> updateItinerary(
    String token,
    String travelId,
    Map<String, dynamic> itineraryData,
  ) {
    return _apiService.updateItinerary(token, travelId, itineraryData);
  }
}
