import 'package:travel_matrix/core/services/compass_service/api_endpoints.dart';
import 'package:travel_matrix/core/services/compass_service/mock_api_client.dart';

class DashboardApiClient {
  static DashboardApiClient? _instance;

  DashboardApiClient._();

  static Future<DashboardApiClient> init() async {
    assert(_instance == null, 'DashboardApiClient instance already initialized!');
    _instance ??= DashboardApiClient._();
    return _instance!;
  }

  static DashboardApiClient get instance {
    assert(_instance != null, 'DashboardApiClient instance not initialized!');
    return _instance!;
  }

  Future<Map<String, dynamic>> getDashboardStats(String token) async {
    return MockApiClient().get(
      token,
      ApiEndpoints.dashboardStats,
      {},
      {},
      {},
    );
  }
}
