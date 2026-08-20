import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/auth/data/models/auth_session_dto.dart';

class AuthRemoteDataSource {
  final HttpApiClient _client;

  const AuthRemoteDataSource(this._client);

  Future<AuthSessionDto> login(String email, String password) async {
    final response = await _client.post('', ApiEndpoints.login, {
      'email': email,
      'password': password,
    });

    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('E-mail ou senha incorretos.');
    }
    return AuthSessionDto.fromJson(data);
  }
}
