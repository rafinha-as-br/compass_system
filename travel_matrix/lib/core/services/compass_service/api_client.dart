// ─── MUDANÇA PARA INTEGRAÇÃO ───────────────────────────────────────────────
// Esta classe foi alterada para delegar as requisições HTTP ao HttpApiClient
// em vez do MockApiService (mock_repository).
//
// O que mudou:
//   - Antes: cada método chamava MockApiService().get/post/put/delete()
//   - Agora:  cada método chama HttpApiClient.instance.get/post/put/delete()
//
// A assinatura dos métodos foi mantida igual (5 parâmetros) para não quebrar
// os clients existentes (TravelApiClient, RouteApiClient, ItineraryApiClient).
// Os parâmetros `params` e `headers` são ignorados — o HttpApiClient já
// adiciona o header Authorization: Bearer <token> automaticamente.
// ──────────────────────────────────────────────────────────────────────────

import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

/// Ponto central de execução de requisições HTTP.
///
/// Delega para [HttpApiClient] que usa o pacote `http` para fazer chamadas
/// reais à API Java (compass-api).
class ApiClient {
  Future<Map<String, dynamic>> get(
    String token,
    String path,
    Map<String, dynamic> params,
    Map<String, dynamic> headers,
    Map<String, dynamic> body,
  ) async {
    return HttpApiClient.instance.get(token, path);
  }

  Future<Map<String, dynamic>> post(
    String token,
    String path,
    Map<String, dynamic> params,
    Map<String, dynamic> headers,
    Map<String, dynamic> body,
  ) async {
    return HttpApiClient.instance.post(token, path, body);
  }

  Future<Map<String, dynamic>> put(
    String token,
    String path,
    Map<String, dynamic> params,
    Map<String, dynamic> headers,
    Map<String, dynamic> body,
  ) async {
    return HttpApiClient.instance.put(token, path, body);
  }

  Future<Map<String, dynamic>> delete(
    String token,
    String path,
    Map<String, dynamic> params,
    Map<String, dynamic> headers,
    Map<String, dynamic> body,
  ) async {
    return HttpApiClient.instance.delete(token, path);
  }
}