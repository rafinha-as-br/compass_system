import 'package:routecraft_app/core/network/clients/travel_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';

class TravelDataSource {
  final TravelApiClient _client;
  final Future<String?> Function()? _getTokenOverride;

  /// [getToken] is injectable for tests, without depending on the real
  /// `AuthService`/secure storage wiring — `AuthService.instance` is only
  /// touched when no override is given.
  TravelDataSource({TravelApiClient? client, Future<String?> Function()? getToken})
      : _client = client ?? TravelApiClient(HttpApiClient.instance),
        _getTokenOverride = getToken;

  Future<String> _token() async => await (_getTokenOverride ?? AuthService.instance.getToken)() ?? '';

  Future<TravelDTO> getTravel(String id) async {
    final result = await _client.getTravel(await _token(), id);
    return TravelDTO.fromJson(result);
  }

  Future<List<TravelDTO>> getTravelsForClient(String clientName) async {
    final data = await _client.getTravelsForClient(await _token(), clientName);
    return data.map(TravelDTO.fromJson).toList();
  }

  Future<TravelDTO> createTravel(TravelDTO travel) async {
    final result = await _client.createTravel(await _token(), travel.toJson());
    return TravelDTO.fromJson(result);
  }
}
