import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/core/services/compass_service/clients/auth_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/itinerary_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/route_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/travel_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/clients/user_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/api_exception.dart';
// MUDANÇA PARA INTEGRAÇÃO: adicionado import do AuthApiClient (login real) e UserApiClient (CRUD de usuários real).

/// Wraps [MockApiService] for the Travel Matrix application.
///
/// This singleton service provides a unified API surface for all
/// network operations. It delegates to the mock backend and will
/// be replaced by a real HTTP client when the production API arrives.
class CompassService {
  static CompassService? _instance;
  final MockApiService _mockApiService;

  // MUDANÇA PARA INTEGRAÇÃO: adicionado _authApiClient para login real
  // e _userApiClient para CRUD de usuários real (antes usava MockApiService).
  // Os demais clients (travel, route, itinerary) agora chamam a API Java via
  // ApiClient → HttpApiClient em vez do MockApiService.
  final AuthApiClient _authApiClient;
  final UserApiClient _userApiClient;
  final TravelApiClient _travelApiClient;
  final RouteApiClient _routeApiClient;
  final ItineraryApiClient _itineraryApiClient;

  CompassService._()
      : _mockApiService = MockApiService(),
        _authApiClient = AuthApiClient.instance, // MUDANÇA PARA INTEGRAÇÃO
        _userApiClient = UserApiClient.instance,  // MUDANÇA PARA INTEGRAÇÃO
        _travelApiClient = TravelApiClient.instance,
        _routeApiClient = RouteApiClient.instance,
        _itineraryApiClient = ItineraryApiClient.instance;

  static Future<CompassService> init() async {
    if (_instance != null) return _instance!;
    await AuthApiClient.init(); // MUDANÇA PARA INTEGRAÇÃO: inicializa client de auth real
    await UserApiClient.init();  // MUDANÇA PARA INTEGRAÇÃO: inicializa client de usuários real
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

  // MUDANÇA PARA INTEGRAÇÃO: login agora chama a API Java real.
  //
  // Antes: _mockApiService.login() retornava { status, data: { token, userType } }
  // Agora: AuthApiClient.loginAgente() retorna { token, id, name, email, userType }
  //        que é envolvido pelo HttpApiClient em { status, data: { token, ... }, message }
  //
  // ATUALIZADO: a API Java foi corrigida para retornar userType = "travel_agent"
  // diretamente (em AuthController.java). Não é mais necessário nenhum mapeamento.
  //
  // Usuários que NÃO são agentes recebem status 'error' para o app negar acesso.
  /// Autentica um agente e retorna payload no formato esperado pelo [LoginController].
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _authApiClient.loginAgente(email, password);

      // HttpApiClient._handleResponse envolve a resposta em {status, data, message}
      // portanto os campos do token estão em response['data'].
      final data = response['data'] as Map<String, dynamic>? ?? response;

      return {
        'status': 'success',
        'data': {
          'token': data['token'],
          'userType': data['userType'], // API retorna "travel_agent"
          'id': data['id'] ?? data['userId'], // Java serializa como "userId"
          'name': data['name'],
          'email': data['email'],
        },
        'message': null,
      };
    } on ApiException catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': e.message,
      };
    } catch (e) {
      return {
        'status': 'error',
        'data': null,
        'message': 'Erro de conexão: verifique se a API está rodando.',
      };
    }
  }


  // ─── Users ──────────────────────────────────────────────────────────

  // MUDANÇA PARA INTEGRAÇÃO: todos os métodos de usuário agora chamam
  // UserApiClient → API Java real (UserController.java) em vez do MockApiService.
  // A API retorna o ClientUser sem o campo password (removido no backend).

  /// Returns the authenticated user's data (GET /api/users/me).
  Future<Map<String, dynamic>> getUser(String token) async {
    try {
      final response = await _userApiClient.getMe(token);
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Returns all client users. Travel Agent only (GET /api/users).
  Future<Map<String, dynamic>> getAllUsers(String token) async {
    try {
      final response = await _userApiClient.getAllUsers(token);
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

  /// Creates a new client user. Travel Agent only (POST /api/users).
  Future<Map<String, dynamic>> createUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _userApiClient.createUser(token, userData);
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Updates a user's data (PUT /api/users/{id}).
  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _userApiClient.updateUser(token, userData);
      return {'status': 'success', 'data': response, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
  }

  /// Deletes a user by ID. Travel Agent only (DELETE /api/users/{id}).
  Future<Map<String, dynamic>> deleteUser(String token, String userId) async {
    try {
      await _userApiClient.deleteUser(token, userId);
      return {'status': 'success', 'data': null, 'message': null};
    } on ApiException catch (e) {
      return {'status': 'error', 'data': null, 'message': e.message};
    }
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
