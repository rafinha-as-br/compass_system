import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/clients/company_api_client.dart';

class CompanyDataSource {
  final AuthStorageService _authStorageService;
  final CompanyApiClient _apiClient;

  CompanyDataSource({
    AuthStorageService? authStorageService,
    CompanyApiClient? apiClient,
  })  : _authStorageService = authStorageService ?? AuthStorageService.instance,
        _apiClient = apiClient ?? CompanyApiClient.instance;

  Future<Map<String, dynamic>> getMyCompany() async {
    return _apiClient.getMyCompany(await _token());
  }

  Future<Map<String, dynamic>> getAgents() async {
    return _apiClient.getAgents(await _token());
  }

  Future<Map<String, dynamic>> inviteAgent(String name) async {
    return _apiClient.inviteAgent(await _token(), name);
  }

  Future<Map<String, dynamic>> removeAgent(String agentId) async {
    return _apiClient.removeAgent(await _token(), agentId);
  }

  Future<Map<String, dynamic>> changeRole(String agentId, String role) async {
    return _apiClient.changeRole(await _token(), agentId, role);
  }

  Future<String> _token() async {
    final token = await _authStorageService.getToken();
    if (token == null) {
      throw StateError('Not authenticated.');
    }
    return token;
  }
}
