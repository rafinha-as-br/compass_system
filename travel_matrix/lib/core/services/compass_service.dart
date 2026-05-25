import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/core/services/compass_service/clients/itinerary_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/route_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/travel_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/api_exception.dart';

/// Wraps [MockApiService] for the Travel Matrix application.
///
/// This singleton service provides a unified API surface for all
/// network operations. It delegates to the mock backend and will
/// be replaced by a real HTTP client when the production API arrives.
class CompassService {
  static CompassService? _instance;
  final MockApiService _mockApiService;
  final TravelApiClient _travelApiClient;
  final RouteApiClient _routeApiClient;
  final ItineraryApiClient _itineraryApiClient;

  CompassService._()
      : _mockApiService = MockApiService(),
        _travelApiClient = TravelApiClient.instance,
        _routeApiClient = RouteApiClient.instance,
        _itineraryApiClient = ItineraryApiClient.instance;

  static Future<CompassService> init() async {
    if (_instance != null) return _instance!;
    await TravelApiClient.init();
    await RouteApiClient.init();
    await ItineraryApiClient.init();
    _instance = CompassService._();
    return _instance!;
  }

  static CompassService get instance {
    assert(_instance != null, 'CompassService instance not initialized!');
    return _instance!;
  }

  // ─── Auth ───────────────────────────────────────────────────────────

  /// Authenticates a user and returns a bearer token payload.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _mockApiService.login(email, password);
    return response.body;
  }

  // ─── Users ──────────────────────────────────────────────────────────

  /// Returns the authenticated user's data.
  Future<Map<String, dynamic>> getUser(String token) async {
    final response = await _mockApiService.getUser(token);
    return response.body;
  }

  /// Returns all client users. Travel Agent only.
  Future<Map<String, dynamic>> getAllUsers(String token) async {
    final response = await _mockApiService.getAllUsers(token);
    return response.body;
  }

  /// Creates a new client user. Travel Agent only.
  Future<Map<String, dynamic>> createUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final response = await _mockApiService.createUser(token, userData);
    return response.body;
  }

  /// Updates a user's data.
  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final response = await _mockApiService.updateUser(token, userData);
    return response.body;
  }

  /// Deletes a user by ID. Travel Agent only.
  Future<Map<String, dynamic>> deleteUser(String token, String userId) async {
    final response = await _mockApiService.deleteUser(token, userId);
    return response.body;
  }

  // ─── Travels ────────────────────────────────────────────────────────

  /// Returns all travels. Travel Agent only.
  Future<Map<String, dynamic>> getAllTravels(String token) async {
    try {
      final response = await _travelApiClient.getAllTravels(token);
      final data = response['data'];
      return {
        'status': 'success',
        'data': data is List ? data : (data == null ? [] : [data]),
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': const [],
        'message': e.message,
      };
    }
  }

  /// Returns a single travel by ID.
  Future<Map<String, dynamic>> getTravel(
    String token,
    String travelId,
  ) async {
    try {
      final response = await _travelApiClient.getTravel(token, travelId);
      return {
        'status': 'success',
        'data': response,
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': e.message,
      };
    }
  }

  /// Returns all travels for a specific client.
  Future<Map<String, dynamic>> getTravelsForClient(
    String token,
    String clientId,
  ) async {
    try {
      final response = await _travelApiClient.getTravelsForClient(
        token,
        clientId,
      );
      final data = response['data'];
      return {
        'status': 'success',
        'data': data is List ? data : (data == null ? [] : [data]),
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': const [],
        'message': e.message,
      };
    }
  }

  /// Creates a new travel. Travel Agent only.
  Future<Map<String, dynamic>> createTravel(
    String token,
    Map<String, dynamic> travelData,
  ) async {
    try {
      final response = await _travelApiClient.createTravel(token, travelData);
      return {
        'status': 'success',
        'data': response,
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': e.message,
      };
    }
  }

  /// Updates an existing travel. Travel Agent only.
  Future<Map<String, dynamic>> updateTravel(
    String token,
    String travelId,
    Map<String, dynamic> travelData,
  ) async {
    try {
      final response = await _travelApiClient.updateTravel(
        token,
        travelId,
        travelData,
      );
      return {
        'status': 'success',
        'data': response,
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': e.message,
      };
    }
  }

  /// Deletes a travel by ID. Travel Agent only.
  Future<Map<String, dynamic>> deleteTravel(
    String token,
    String travelId,
  ) async {
    try {
      await _travelApiClient.deleteTravel(token, travelId);
      return {
        'status': 'success',
        'data': null,
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': e.message,
      };
    }
  }

  // ─── Routes ─────────────────────────────────────────────────────────

  /// Updates the route of an existing travel. Travel Agent only.
  Future<Map<String, dynamic>> updateRoute(
    String token,
    String travelId,
    Map<String, dynamic> routeData,
  ) async {
    try {
      final response =
          await _routeApiClient.updateRoute(token, travelId, routeData);
      return {
        'status': 'success',
        'data': response,
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': e.message,
      };
    }
  }

  // ─── Itineraries ────────────────────────────────────────────────────

  /// Creates an itinerary for a travel. Travel Agent only.
  Future<Map<String, dynamic>> createItinerary(
    String token,
    String travelId,
    Map<String, dynamic> itineraryData,
  ) async {
    try {
      final response = await _itineraryApiClient.upsertItinerary(
        token,
        travelId,
        itineraryData,
      );
      return {
        'status': 'success',
        'data': response,
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': e.message,
      };
    }
  }

  /// Updates the itinerary for a travel. Travel Agent only.
  Future<Map<String, dynamic>> updateItinerary(
    String token,
    String travelId,
    Map<String, dynamic> itineraryData,
  ) async {
    try {
      final response = await _itineraryApiClient.upsertItinerary(
        token,
        travelId,
        itineraryData,
      );
      return {
        'status': 'success',
        'data': response,
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': e.message,
      };
    }
  }
}
