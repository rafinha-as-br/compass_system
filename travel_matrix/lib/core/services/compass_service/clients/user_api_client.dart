// ─── MUDANÇA PARA INTEGRAÇÃO ───────────────────────────────────────────────
// Arquivo NOVO — substitui as chamadas de usuário que antes iam para
// MockApiService em CompassService (getUser, getAllUsers, createUser,
// updateUser, deleteUser).
//
// Endpoints da API Java (UserController.java):
//   GET    /api/users         → lista todos os clientes
//   GET    /api/users/me      → retorna o usuário autenticado pelo token
//   GET    /api/users/{id}    → busca um cliente por ID
//   POST   /api/users         → cria um novo cliente
//   PUT    /api/users/{id}    → atualiza dados de um cliente
//   DELETE /api/users/{id}    → remove um cliente
// ──────────────────────────────────────────────────────────────────────────

import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

class UserApiClient {
  static UserApiClient? _instance;

  UserApiClient._();

  static Future<UserApiClient> init() async {
    assert(_instance == null, 'UserApiClient instance already initialized!');
    _instance ??= UserApiClient._();
    return _instance!;
  }

  static UserApiClient get instance {
    assert(_instance != null, 'UserApiClient instance not initialized!');
    return _instance!;
  }

  /// Retorna o usuário autenticado pelo token (GET /api/users/me).
  /// Chamado por [CompassService.getUser()].
  Future<Map<String, dynamic>> getMe(String token) async {
    return HttpApiClient.instance.get(token, '/api/users/me');
  }

  /// Retorna todos os clientes (GET /api/users).
  /// Chamado por [CompassService.getAllUsers()].
  Future<Map<String, dynamic>> getAllUsers(String token) async {
    return HttpApiClient.instance.get(token, '/api/users');
  }

  /// Busca um cliente por ID (GET /api/users/{id}).
  Future<Map<String, dynamic>> getUserById(String token, String userId) async {
    return HttpApiClient.instance.get(token, '/api/users/$userId');
  }

  /// Cria um novo cliente (POST /api/users).
  /// Chamado por [CompassService.createUser()].
  Future<Map<String, dynamic>> createUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    return HttpApiClient.instance.post(token, '/api/users', userData);
  }

  /// Atualiza dados de um cliente (PUT /api/users/{id}).
  /// Chamado por [CompassService.updateUser()].
  /// O campo "id" deve estar presente em [userData].
  Future<Map<String, dynamic>> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    final id = userData['id']?.toString() ?? '';
    return HttpApiClient.instance.put(token, '/api/users/$id', userData);
  }

  /// Remove um cliente (DELETE /api/users/{id}).
  /// Chamado por [CompassService.deleteUser()].
  Future<void> deleteUser(String token, String userId) async {
    await HttpApiClient.instance.delete(token, '/api/users/$userId');
  }
}
