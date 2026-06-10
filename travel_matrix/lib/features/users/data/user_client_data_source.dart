
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/compass_service/clients/user_api_client.dart';

class UserClientDataSource{
  final _userService = UserApiClient.instance;
  final _authService = AuthStorageService.instance;

  Future<Map<String, dynamic>> getAllUsers() async {
    final token = await _authService.getToken();
    final result = await _userService.getAllUsers(token!);
    return result;
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final token = await _authService.getToken();
    final result = await _userService.createUser(token!, userData);
    return result;
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    final token = await _authService.getToken();
    final result = await _userService.updateUser(token!, userData);
    return result;
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    final token = await _authService.getToken();
    final result = await _userService.getUserById(token!, userId);
    return result;
  }

  Future<Map<String, dynamic>> deactivateUser(String userId, String reason) async {
    final token = await _authService.getToken();
    final result = await _userService.deactivateUser(token!, userId, reason);
    return result;
  }

  Future<Map<String, dynamic>> resetPassword(String userId) async {
    final token = await _authService.getToken();
    final result = await _userService.resetPassword(token!, userId);
    return result;
  }

  Future<Map<String, dynamic>> forceLogout(String userId) async {
    final token = await _authService.getToken();
    final result = await _userService.forceLogout(token!, userId);
    return result;
  }
}