import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

/// Thin wrapper over [HttpApiClient] for the `/push-targets` endpoints —
/// Web-only (VAPID), see [WebPushService].
class PushTargetApiClient {
  static PushTargetApiClient? _instance;

  PushTargetApiClient._();

  static Future<PushTargetApiClient> init() async {
    assert(_instance == null, 'PushTargetApiClient instance already initialized!');
    _instance ??= PushTargetApiClient._();
    return _instance!;
  }

  static PushTargetApiClient get instance {
    assert(_instance != null, 'PushTargetApiClient instance not initialized!');
    return _instance!;
  }

  /// `/push-targets/**` requires a Bearer token (`SecurityConfig`), even for
  /// this GET — the web client always already has one by the time it calls
  /// this (see [WebPushService.registerForPush]).
  Future<Map<String, dynamic>> getVapidPublicKey(String token) {
    return HttpApiClient.instance.get(token, ApiEndpoints.pushTargetsVapidPublicKey);
  }

  Future<Map<String, dynamic>> registerWeb(
    String token, {
    required String endpoint,
    required String p256dh,
    required String auth,
  }) {
    return HttpApiClient.instance.post(token, ApiEndpoints.pushTargets, {
      'platform': 'WEB',
      'webEndpoint': endpoint,
      'webP256dh': p256dh,
      'webAuth': auth,
    });
  }

  Future<Map<String, dynamic>> unregister(String token, String id) {
    return HttpApiClient.instance.delete(token, ApiEndpoints.pushTarget(id));
  }
}
