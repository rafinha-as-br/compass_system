import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';

class AccountDataSource {
  final AuthStorageService _authStorageService;
  final CompassService _compassService;

  AccountDataSource({
    AuthStorageService? authStorageService,
    CompassService? compassService,
  })  : _authStorageService = authStorageService ?? AuthStorageService.instance,
        _compassService = compassService ?? CompassService.instance;

  Future<Map<String, dynamic>> getAgentProfile() async {
    final token = await _authStorageService.getToken();
    if (token == null) {
      throw StateError('Not authenticated.');
    }

    return _compassService.getAuthenticatedUser(token);
  }

  Future<Map<String, dynamic>> updateAgentProfile(
    Map<String, dynamic> profileData,
  ) async {
    final token = await _authStorageService.getToken();
    if (token == null) {
      throw StateError('Not authenticated.');
    }

    return _compassService.updateUser(token, profileData);
  }

  /// Reaproveita o endpoint de login como verificação de senha atual,
  /// já que não existe um endpoint dedicado de reautenticação no backend.
  Future<Map<String, dynamic>> verifyPassword(
    String email,
    String password,
  ) {
    return _compassService.login(email, password);
  }
}
