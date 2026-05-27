import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8081';
    if (Platform.isAndroid) return 'http://10.0.2.2:8081';
    return 'http://localhost:8081';
  }

  // ─── MUDANÇA PARA INTEGRAÇÃO ──────────────────────────────────────────────
  // Endpoint de autenticação real da API Java (compass-api).
  // Antes: o login era feito pelo MockApiService em CompassService.login().
  // Agora: AuthApiClient chama este endpoint diretamente.
  static const String loginAgente = '/api/auth/login/agente';
  // ─────────────────────────────────────────────────────────────────────────

  // Travels
  static const String travels = '/travels';
  static String travelById(String id) => '/travels/$id';
  static String travelItinerary(String travelId) => '/travels/$travelId/itinerary';
  static String travelsByClient(String clientId) => '/travels/client/$clientId';
}
