import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';

class AuthApiClient {
  static AuthApiClient? _instance;

  AuthApiClient._();

  static Future<AuthApiClient> init() async {
    assert(_instance == null, 'AuthApiClient instance already initialized!');
    _instance ??= AuthApiClient._();
    return _instance!;
  }

  static AuthApiClient get instance {
    assert(_instance != null, 'AuthApiClient instance not initialized!');
    return _instance!;
  }

  /// Travel Matrix só é usado por Agentes — o backend rejeita o login de um
  /// Cliente com credenciais válidas através do parâmetro `expectedUserType`.
  Future<Map<String, dynamic>> login(String email, String password) async {
    return HttpApiClient.instance.post('', ApiEndpoints.login, {
      'email': email,
      'password': password,
      'expectedUserType': 'AGENTE',
    });
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return HttpApiClient.instance.post('', ApiEndpoints.register, userData);
  }
}