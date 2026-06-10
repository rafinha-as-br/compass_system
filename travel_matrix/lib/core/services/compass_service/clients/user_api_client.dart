import 'package:travel_matrix/core/services/compass_service/mock_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';

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

  Future<Map<String, dynamic>> getUser(String token) async {
    return MockApiClient().get(token, ApiEndpoints.userMe, {}, {}, {});
  }

  Future<Map<String, dynamic>> getUserById(String token, String userId) async {
    return MockApiClient().get(token, ApiEndpoints.userById(userId), {}, {}, {});
  }

  Future<Map<String, dynamic>> getAllUsers(String token) async {
    return MockApiClient().get(token, ApiEndpoints.users, {}, {}, {});
  }

  Future<Map<String, dynamic>> createUser(String token, Map<String, dynamic> userData) async {
    return MockApiClient().post(token, ApiEndpoints.users, {}, {}, userData);
  }

  Future<Map<String, dynamic>> updateUser(String token, Map<String, dynamic> userData) async {
    final userId = userData['id'] as String;
    return MockApiClient().put(token, ApiEndpoints.userById(userId), {}, {}, userData);
  }

  Future<Map<String, dynamic>> deactivateUser(String token, String userId, String reason) async {
    return MockApiClient().post(token, ApiEndpoints.userDeactivate(userId), {}, {}, {'reason': reason});
  }

  Future<Map<String, dynamic>> resetPassword(String token, String userId) async {
    return MockApiClient().post(token, ApiEndpoints.userResetPassword(userId), {}, {}, {});
  }

  Future<Map<String, dynamic>> forceLogout(String token, String userId) async {
    return MockApiClient().post(token, ApiEndpoints.userForceLogout(userId), {}, {}, {});
  }
}
