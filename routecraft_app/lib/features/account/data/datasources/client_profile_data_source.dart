import 'package:routecraft_app/core/network/clients/client_user_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/account/data/dtos/client_profile_dto.dart';

class ClientProfileDataSource {
  final ClientUserApiClient _client;
  final Future<String?> Function()? _getTokenOverride;

  /// [getToken] is injectable for tests, without depending on the real
  /// `AuthService`/secure storage wiring — `AuthService.instance` is only
  /// touched when no override is given.
  ClientProfileDataSource({ClientUserApiClient? client, Future<String?> Function()? getToken})
      : _client = client ?? ClientUserApiClient(HttpApiClient.instance),
        _getTokenOverride = getToken;

  Future<String> _token() async => await (_getTokenOverride ?? AuthService.instance.getToken)() ?? '';

  Future<ClientProfileDTO> getCurrentUser() async {
    final result = await _client.getCurrentUser(await _token());
    return ClientProfileDTO.fromJson(result);
  }

  Future<ClientProfileDTO> updateUser(ClientProfileDTO profile) async {
    final result = await _client.updateUser(await _token(), profile.id, profile.toJson());
    return ClientProfileDTO.fromJson(result);
  }

  Future<void> resetPassword(String id) async {
    await _client.resetPassword(await _token(), id);
  }
}
