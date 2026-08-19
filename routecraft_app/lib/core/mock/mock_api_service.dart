import 'mock_api_response.dart';

/// In-memory fake of the compass-api surface still consumed by
/// routecraft_app features that have not yet been migrated to the real API
/// (travel/route creation, visualization, follow travel). Auth is being
/// migrated away from this mock in CPS-43.
class MockApiService {
  Future<MockApiResponse> login(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return const MockApiResponse({
        'status': 'error',
        'message': 'E-mail ou senha incorretos.',
      });
    }

    return MockApiResponse({
      'status': 'success',
      'data': {
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      },
    });
  }

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
