
import 'package:mock_repository/mock_repository.dart';

import 'api_exception.dart';
/// Execute and handle HTTP requests
/// the [response] on this class is from the mock repository and replaces the HTTP request
class ApiClient{

  Future<Map<String, dynamic>> get(String token, String path, Map<String, dynamic> params, Map<String, dynamic> headers, Map<String, dynamic> body) async{
    final response = await MockApiService().get(token, path, params, headers, body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String token, String path, Map<String, dynamic> params, Map<String, dynamic> headers, Map<String, dynamic> body) async{
    final response = await MockApiService().post(token, path, params, headers, body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String token, String path, Map<String, dynamic> params, Map<String, dynamic> headers, Map<String, dynamic> body) async{
    final response =  await MockApiService().put(token, path, params, headers, body);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String token, String path, Map<String, dynamic> params, Map<String, dynamic> headers, Map<String, dynamic> body) async {
    final response = await MockApiService().delete(token, path, params, headers, body);
    return _handleResponse(response);
  }


  Map<String, dynamic> _handleResponse(FakeResponse response) {
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw ApiException.fromStatusCode(
        response.statusCode,
        response.body,
      );
    }
  }

}