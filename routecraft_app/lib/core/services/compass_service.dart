import 'package:routecraft_app/core/mock/mock_repository.dart';

/// Wraps MockApiService for the RouteCraft client application.
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

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    return response.body;
  }

  // ─── Users ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUser(String token) async {
    final response = await _apiService.getUser(token);
    return response.body;
  }

  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final response = await _apiService.updateUser(token, userData);
    return response.body;
  }

  // ─── Travels ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTravel(String token, String travelId) async {
    final response = await _apiService.getTravel(token, travelId);
    return response.body;
  }

  Future<Map<String, dynamic>> getTravelsForClient(
    String token,
    String clientId,
  ) async {
    final response = await _apiService.getTravelsForClient(token, clientId);
    return response.body;
  }

  // ─── Routes ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createTravel(
    String token,
    Map<String, dynamic> travelData,
  ) async {
    final response = await _apiService.createTravel(token, travelData);
    return response.body;
  }
}
