import 'package:routecraft_app/core/network/api_endpoints.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/features/auth/domain/entities/client_registration.dart';

class ClientRegistrationRemoteDataSource {
  final HttpApiClient _client;

  const ClientRegistrationRemoteDataSource(this._client);

  Future<String> register(ClientRegistration registration) async {
    final response = await _client.post('', ApiEndpoints.registerClient, {
      'name': registration.name,
      'cpf': registration.cpf,
      'age': registration.age,
      'gender': registration.gender,
      'phone': registration.phone,
      'email': registration.email,
      'password': registration.password,
    });

    final data = response['data'];
    if (data is String && data.isNotEmpty) {
      return data;
    }
    return 'Cliente cadastrado com sucesso.';
  }
}
