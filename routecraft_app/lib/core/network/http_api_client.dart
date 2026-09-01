import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'api_exception.dart';

/// Shared HTTP client for talking to the compass-api backend.
class HttpApiClient {
  static const _timeout = Duration(seconds: 15);

  static HttpApiClient? _instance;
  final http.Client _client;

  HttpApiClient._({http.Client? client}) : _client = client ?? http.Client();

  static HttpApiClient get instance {
    _instance ??= HttpApiClient._();
    return _instance!;
  }

  @visibleForTesting
  factory HttpApiClient.forTesting(http.Client client) =>
      HttpApiClient._(client: client);

  Future<Map<String, dynamic>> get(String token, String path) {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    return _send(() => _client.get(uri, headers: _buildHeaders(token)));
  }

  Future<Map<String, dynamic>> post(
    String token,
    String path,
    Map<String, dynamic> body,
  ) {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    return _send(() => _client.post(
          uri,
          headers: _buildHeaders(token),
          body: jsonEncode(body),
        ));
  }

  Future<Map<String, dynamic>> put(
    String token,
    String path,
    Map<String, dynamic> body,
  ) {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    return _send(() => _client.put(
          uri,
          headers: _buildHeaders(token),
          body: jsonEncode(body),
        ));
  }

  Future<Map<String, dynamic>> delete(String token, String path) {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    return _send(() => _client.delete(uri, headers: _buildHeaders(token)));
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Tempo de conexão esgotado. Tente novamente.', null, true);
    } catch (_) {
      throw ApiException('Não foi possível conectar ao servidor.', null, true);
    }
    return _handleResponse(response);
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'data': decoded};
      } on FormatException {
        return {'data': response.body};
      }
    }

    dynamic errorData;
    try {
      errorData = jsonDecode(response.body);
    } catch (_) {
      errorData = response.body;
    }
    throw ApiException.fromStatusCode(response.statusCode, errorData);
  }
}
