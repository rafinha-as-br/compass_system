import 'package:mock_repository/mock_repository.dart';

/// Wraps MockApiService for the Travel Matrix application.
/// All methods pass through the bearer token for authentication.
///
/// IN FUTURE, THE HTTP REQUESTS WILL COME HERE!!
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

  Future<FakeResponse> login(String email, String password) {
    return _apiService.login(email, password);
  }

  // ─── Users ──────────────────────────────────────────────────────────

  Future<FakeResponse> getUser(String token) {
    return _apiService.getUser(token);
  }

  Future<FakeResponse> getAllUsers(String token) {
    return _apiService.getAllUsers(token);
  }

  Future<FakeResponse> createUser(
    String token,
    Map<String, dynamic> userData,
  ) {
    return _apiService.createUser(token, userData);
  }

  Future<FakeResponse> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) {
    return _apiService.updateUser(token, userData);
  }

  Future<FakeResponse> deleteUser(String token, String userId) {
    return _apiService.deleteUser(token, userId);
  }

  // ─── Travels ────────────────────────────────────────────────────────

  Future<FakeResponse> getAllTravels(String token) {
    return _apiService.getAllTravels(token);
  }

  Future<FakeResponse> getTravel(String token, String travelId) {
    return _apiService.getTravel(token, travelId);
  }

  Future<FakeResponse> getTravelsForClient(
    String token,
    String clientId,
  ) {
    return _apiService.getTravelsForClient(token, clientId);
  }

  Future<FakeResponse> createTravel(
    String token,
    Map<String, dynamic> travelData,
  ) {
    return _apiService.createTravel(token, travelData);
  }

  Future<FakeResponse> updateTravel(
    String token,
    String travelId,
    Map<String, dynamic> travelData,
  ) {
    return _apiService.updateTravel(token, travelId, travelData);
  }

  Future<FakeResponse> deleteTravel(
    String token,
    String travelId,
  ) {
    return _apiService.deleteTravel(token, travelId);
  }

  // ─── Routes (within Travel) ─────────────────────────────────────────

  Future<FakeResponse> updateRoute(
    String token,
    String travelId,
    Map<String, dynamic> routeData,
  ) {
    return _apiService.updateRoute(token, travelId, routeData);
  }

  // ─── Itineraries (within Travel) ────────────────────────────────────

  Future<FakeResponse> createItinerary(
    String token,
    String travelId,
    Map<String, dynamic> itineraryData,
  ) {
    return _apiService.createItinerary(token, travelId, itineraryData);
  }

  Future<FakeResponse> updateItinerary(
    String token,
    String travelId,
    Map<String, dynamic> itineraryData,
  ) {
    return _apiService.updateItinerary(token, travelId, itineraryData);
  }
}
