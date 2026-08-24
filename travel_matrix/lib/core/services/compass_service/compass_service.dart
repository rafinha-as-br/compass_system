import 'package:travel_matrix/core/services/compass_service/clients/auth_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/dashboard_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/itinerary_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/route_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/travel_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/user_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/api_exception.dart';

/// Central API service for the Travel Matrix application.
///
/// This singleton service provides a unified API surface for all
/// network operations. It delegates to the real Compass API backend
/// via [HttpApiClient].
class CompassService {
  static CompassService? _instance;
  final TravelApiClient _travelApiClient;
  final ItineraryApiClient _itineraryApiClient;
  final UserApiClient _userApiClient;
  final AuthApiClient _authApiClient;
  final DashboardApiClient _dashboardApiClient;

  CompassService._()
    : _travelApiClient = TravelApiClient.instance,
      _itineraryApiClient = ItineraryApiClient.instance,
      _userApiClient = UserApiClient.instance,
      _authApiClient = AuthApiClient.instance,
      _dashboardApiClient = DashboardApiClient.instance;

  static Future<CompassService> init() async {
    if (_instance != null) return _instance!;
    await AuthApiClient.init();
    await UserApiClient.init();
    await TravelApiClient.init();
    await RouteApiClient.init();
    await ItineraryApiClient.init();
    await DashboardApiClient.init();
    _instance = CompassService._();
    return _instance!;
  }

  static CompassService get instance {
    assert(_instance != null, 'CompassService instance not initialized!');
    return _instance!;
  }

  // ─── Auth ───────────────────────────────────────────────────────────

  /// Authenticates a user and returns a response with {status, data, message}.
  /// The unified login endpoint already returns this format from the backend.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await _authApiClient.login(email, password);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    } catch (e) {
      return {'status': 'error', 'data': null, 'message': e.toString()};
    }
  }

  /// Requests a password reset email. Backend always responds with a
  /// generic success message, regardless of whether the e-mail exists.
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      return await _authApiClient.requestPasswordReset(email);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Resets the password using the token received by e-mail (self-service
  /// flow). Not to be confused with the admin-initiated [resetPassword]
  /// below, which resets a client's password to a fixed default.
  Future<Map<String, dynamic>> resetPasswordWithToken(String token, String newPassword) async {
    try {
      return await _authApiClient.resetPassword(token, newPassword);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  // ─── Users ──────────────────────────────────────────────────────────

  /// Returns the authenticated user's data.
  /// Backend returns the user object directly, we wrap it for compatibility.
  Future<Map<String, dynamic>> getUser(String token) async {
    try {
      final response = await _userApiClient.getUser(token);
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Returns the authenticated agent profile.
  Future<Map<String, dynamic>> getAuthenticatedUser(String token) async {
    return getUser(token);
  }

  /// Returns a user by ID. Backend already returns {status, data, message}.
  Future<Map<String, dynamic>> getUserById(String token, String userId) async {
    try {
      return await _userApiClient.getUserById(token, userId);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Returns all client users. Backend already returns {status, data, message}.
  Future<Map<String, dynamic>> getAllUsers(String token) async {
    try {
      return await _userApiClient.getAllUsers(token);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Creates a new client user. Backend already returns {status, data, message}.
  Future<Map<String, dynamic>> createUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    try {
      return await _userApiClient.createUser(token, userData);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Updates a user's data. Backend already returns {status, data, message}.
  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    try {
      return await _userApiClient.updateUser(token, userData);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Deactivates a user by ID. Backend already returns {status, data, message}.
  Future<Map<String, dynamic>> deactivateUser(
    String token,
    String userId,
    String reason,
  ) async {
    try {
      return await _userApiClient.deactivateUser(token, userId, reason);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Resets a user's password. Backend already returns {status, data, message}.
  Future<Map<String, dynamic>> resetPassword(
    String token,
    String userId,
  ) async {
    try {
      return await _userApiClient.resetPassword(token, userId);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Forces a user logout. Backend already returns {status, data, message}.
  Future<Map<String, dynamic>> forceLogout(String token, String userId) async {
    try {
      return await _userApiClient.forceLogout(token, userId);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  // Dashboard

  /// Returns dashboard statistics. Backend returns {status, data, message}.
  Future<Map<String, dynamic>> getDashboardStats(String token) async {
    try {
      return await _dashboardApiClient.getDashboardStats(token);
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  // ─── Travels ────────────────────────────────────────────────────────

  /// Returns all travels.
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
      return {'status': 'error', 'data': const [], 'message': e.message};
    }
  }

  /// Returns a single travel by ID.
  Future<Map<String, dynamic>> getTravel(String token, String travelId) async {
    try {
      final response = await _travelApiClient.getTravel(token, travelId);
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
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
      return {'status': 'error', 'data': const [], 'message': e.message};
    }
  }

  /// Creates a new travel.
  Future<Map<String, dynamic>> createTravel(
    String token,
    Map<String, dynamic> travelData,
  ) async {
    try {
      final response = await _travelApiClient.createTravel(token, travelData);
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Updates an existing travel.
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
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Deletes a travel by ID.
  Future<Map<String, dynamic>> deleteTravel(
    String token,
    String travelId,
  ) async {
    try {
      await _travelApiClient.deleteTravel(token, travelId);
      return {'status': 'success', 'data': null, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  // ─── Routes ─────────────────────────────────────────────────────────

  /// Updates the route of an existing travel.
  Future<Map<String, dynamic>> updateRoute(
    String token,
    String travelId,
    Map<String, dynamic> routeData,
  ) async {
    try {
      final travel = await _travelApiClient.getTravel(token, travelId);
      final currentRoute = travel['routePlan'] as Map<String, dynamic>? ?? {};
      final interestPoints =
          routeData['interestPoints'] ??
          routeData['interestsList'] ??
          currentRoute['interestPoints'];

      travel['routePlan'] = {
        'id': routeData['id'] ?? currentRoute['id'],
        'startDate': routeData['startDate'] ?? currentRoute['startDate'],
        'finishDate':
            routeData['finishDate'] ??
            routeData['endDate'] ??
            currentRoute['finishDate'],
        'startLocation':
            routeData['startLocation'] ?? currentRoute['startLocation'],
        'destination': routeData['destination'] ?? currentRoute['destination'],
        'interestPoints': _normalizeInterestPoints(interestPoints),
      };

      final response = await _travelApiClient.updateTravel(
        token,
        travelId,
        travel,
      );
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  List<Map<String, dynamic>> _normalizeInterestPoints(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((point) {
      final id = point['id']?.toString();
      return {
        'id': id == null || id.startsWith('poi_') ? null : id,
        'name': point['name']?.toString() ?? '',
        'description': point['description']?.toString() ?? '',
      };
    }).toList();
  }

  // ─── Itineraries ────────────────────────────────────────────────────

  /// Creates an itinerary for a travel.
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
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Updates the itinerary for a travel.
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
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }
}
