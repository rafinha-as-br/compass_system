import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import 'api_exception.dart';

class HttpApiClient {
  static HttpApiClient? _instance;
  late final http.Client _client;

  HttpApiClient._() : _client = http.Client();

  static HttpApiClient get instance {
    _instance ??= HttpApiClient._();
    return _instance!;
  }

  Future<Map<String, dynamic>> get(String token, String path) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    final response = await _client.get(
      uri,
      headers: _buildHeaders(token),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String token, String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    final response = await _client.post(
      uri,
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String token, String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    final response = await _client.put(
      uri,
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String token, String path) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    final response = await _client.delete(
      uri,
      headers: _buildHeaders(token),
    );
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
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        return {'data': decoded}; // Handle lists if needed
      }
    } else {
      dynamic errorData;
      try {
        errorData = jsonDecode(response.body);
      } catch (_) {
        errorData = response.body;
      }
      throw ApiException.fromStatusCode(
        response.statusCode,
        errorData,
      );
    }
  }
}
