import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

/// Chamadas HTTP do módulo company (`/api/companies/me`). Todas as respostas
/// vêm no envelope `{status, data, message}` do backend.
class CompanyApiClient {
  static CompanyApiClient? _instance;

  CompanyApiClient._();

  static Future<CompanyApiClient> init() async {
    assert(_instance == null, 'CompanyApiClient instance already initialized!');
    _instance ??= CompanyApiClient._();
    return _instance!;
  }

  static CompanyApiClient get instance {
    assert(_instance != null, 'CompanyApiClient instance not initialized!');
    return _instance!;
  }

  Future<Map<String, dynamic>> getMyCompany(String token) {
    return HttpApiClient.instance.get(token, ApiEndpoints.companyMe);
  }

  Future<Map<String, dynamic>> getAgents(String token) {
    return HttpApiClient.instance.get(token, ApiEndpoints.companyAgents);
  }

  Future<Map<String, dynamic>> inviteAgent(String token, String name) {
    return HttpApiClient.instance
        .post(token, ApiEndpoints.companyAgentInvite, {'name': name});
  }

  Future<Map<String, dynamic>> removeAgent(String token, String agentId) {
    return HttpApiClient.instance
        .delete(token, ApiEndpoints.companyAgentById(agentId));
  }

  Future<Map<String, dynamic>> changeRole(
    String token,
    String agentId,
    String role,
  ) {
    return HttpApiClient.instance
        .put(token, ApiEndpoints.companyAgentRole(agentId), {'role': role});
  }
}
