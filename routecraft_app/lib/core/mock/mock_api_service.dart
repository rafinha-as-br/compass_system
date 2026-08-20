import 'mock_api_response.dart';

/// In-memory fake of the compass-api surface still consumed by
/// routecraft_app features that have not yet been migrated to the real API
/// (travel/route creation, visualization, follow travel). Login was migrated
/// to the real API in CPS-43 and no longer uses this mock.
class MockApiService {
  Future<MockApiResponse> getUser(String token) async {
    return const MockApiResponse({
      'status': 'success',
      'data': {'id': 'client_1', 'name': 'Mock User'},
    });
  }

  Future<MockApiResponse> updateUser(
    String token,
    Map<String, dynamic> userData,
  ) async {
    return MockApiResponse({'status': 'success', 'data': userData});
  }

  Future<MockApiResponse> getTravel(String token, String travelId) async {
    return const MockApiResponse({
      'status': 'error',
      'message': 'Travel not found.',
    });
  }

  Future<MockApiResponse> getTravelsForClient(
    String token,
    String clientId,
  ) async {
    return const MockApiResponse({'status': 'success', 'data': []});
  }

  Future<MockApiResponse> createTravel(
    String token,
    Map<String, dynamic> travelData,
  ) async {
    return MockApiResponse({'status': 'success', 'data': travelData});
  }
}
