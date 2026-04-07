import 'package:mock_repository/mock_repository.dart';

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

  Future<Map<String, dynamic>> login(String email, String password) {
    return _apiService.login(email, password);
  }

  // ─── Users ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUser(String token) {
    return _apiService.getUser(token);
  }

  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) {
    return _apiService.updateUser(token, userData);
  }

  // ─── Travels ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTravel(String token, String travelId) {
    return _apiService.getTravel(token, travelId);
  }

  Future<Map<String, dynamic>> getTravelsForClient(
    String token,
    String clientId,
  ) {
    return _apiService.getTravelsForClient(token, clientId);
  }

  // ─── Routes ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> createTravel(
    String token,
    Map<String, dynamic> travelData,
  ) {
    return _apiService.createTravel(token, travelData);
  }
}
