// ─── MUDANÇA PARA INTEGRAÇÃO ───────────────────────────────────────────────
// Este arquivo estava VAZIO. Foi implementado para autenticar o agente
// diretamente na API Java (compass-api), usando o endpoint:
//   POST /api/auth/login/agente
//
// A resposta da API Java tem o formato:
//   { "token": "...", "id": "...", "name": "...", "email": "...", "userType": "AGENTE" }
//
// O mapeamento para o formato esperado pelo LoginController é feito em
// CompassService.login() — veja os comentários lá.
// ──────────────────────────────────────────────────────────────────────────

import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

/// Client de autenticação real contra a API Java.
///
/// Chamado por [CompassService.login()] em substituição ao MockApiService.
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

  /// Autentica um agente de viagem na API Java.
  ///
  /// Retorna o JSON cru da API: `{ token, id, name, email, userType }`.
  /// O [CompassService] é responsável por mapear esse retorno para o
  /// formato esperado pelo restante do app.
  Future<Map<String, dynamic>> loginAgente(
    String email,
    String password,
  ) async {
    // Token vazio: login ainda não tem token, usa endpoint público /api/auth/**
    return HttpApiClient.instance.post(
      '',
      ApiEndpoints.loginAgente,
      {'email': email, 'password': password},
    );
  }
}
