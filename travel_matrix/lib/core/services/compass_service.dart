import 'package:mock_repository/mock_repository.dart';

/// Wraps [MockApiService] for the Travel Matrix application.
///
/// This singleton service provides a unified API surface for all
/// network operations. It delegates to the mock backend and will
/// be replaced by a real HTTP client when the production API arrives.
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

  /// Authenticates a user and returns a bearer token payload.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    return response.body;
  }

  // ─── Users ──────────────────────────────────────────────────────────

  /// Returns the authenticated user's data.
  Future<Map<String, dynamic>> getUser(String token) async {
    final response = await _apiService.getUser(token);
    return response.body;
  }

  /// Returns all client users. Travel Agent only.
  Future<Map<String, dynamic>> getAllUsers(String token) async {
    final response = await _apiService.getAllUsers(token);
    return response.body;
  }

  /// Creates a new client user. Travel Agent only.
  Future<Map<String, dynamic>> createUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final response = await _apiService.createUser(token, userData);
    return response.body;
  }

  /// Updates a user's data.
  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final response = await _apiService.updateUser(token, userData);
    return response.body;
  }

  /// Deletes a user by ID. Travel Agent only.
  Future<Map<String, dynamic>> deleteUser(String token, String userId) async {
    final response = await _apiService.deleteUser(token, userId);
    return response.body;
  }

  // ─── Travels ────────────────────────────────────────────────────────

  /// Returns all travels. Travel Agent only.
  Future<Map<String, dynamic>> getAllTravels(String token) async {
    final response = await _apiService.getAllTravels(token);
    return response.body;
  }

  /// Returns a single travel by ID.
  Future<Map<String, dynamic>> getTravel(
    String token,
    String travelId,
  ) async {
    final response = await _apiService.getTravel(token, travelId);
    return response.body;
  }

  /// Returns all travels for a specific client.
  Future<Map<String, dynamic>> getTravelsForClient(
    String token,
    String clientId,
  ) async {
    final response = await _apiService.getTravelsForClient(token, clientId);
    return response.body;
  }

  /// Creates a new travel. Travel Agent only.
  Future<Map<String, dynamic>> createTravel(
    String token,
    Map<String, dynamic> travelData,
  ) async {
    final response = await _apiService.createTravel(token, travelData);
    return response.body;
  }

  /// Updates an existing travel. Travel Agent only.
  Future<Map<String, dynamic>> updateTravel(
    String token,
    String travelId,
    Map<String, dynamic> travelData,
  ) async {
    final response =
        await _apiService.updateTravel(token, travelId, travelData);
    return response.body;
  }

  /// Deletes a travel by ID. Travel Agent only.
  Future<Map<String, dynamic>> deleteTravel(
    String token,
    String travelId,
  ) async {
    final response = await _apiService.deleteTravel(token, travelId);
    return response.body;
  }

  // ─── Routes ─────────────────────────────────────────────────────────

  /// Updates the route of an existing travel. Travel Agent only.
  Future<Map<String, dynamic>> updateRoute(
    String token,
    String travelId,
    Map<String, dynamic> routeData,
  ) async {
    final response =
        await _apiService.updateRoute(token, travelId, routeData);
    return response.body;
  }

  // ─── Itineraries ────────────────────────────────────────────────────

  /// Creates an itinerary for a travel. Travel Agent only.
  Future<Map<String, dynamic>> createItinerary(
    String token,
    String travelId,
    Map<String, dynamic> itineraryData,
  ) async {
    final response =
        await _apiService.createItinerary(token, travelId, itineraryData);
    return response.body;
  }

  /// Updates the itinerary for a travel. Travel Agent only.
  Future<Map<String, dynamic>> updateItinerary(
    String token,
    String travelId,
    Map<String, dynamic> itineraryData,
  ) async {
    final response =
        await _apiService.updateItinerary(token, travelId, itineraryData);
    return response.body;
  }
}
