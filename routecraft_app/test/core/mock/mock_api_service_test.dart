import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/mock/mock_repository.dart';

void main() {
  group('MockApiService', () {
    late MockApiService service;

    setUp(() {
      service = MockApiService();
    });

    test('login succeeds with non-empty credentials', () async {
      final response = await service.login('user@example.com', 'password');

      expect(response.body['status'], 'success');
      final data = response.body['data'] as Map<String, dynamic>;
      expect(data['token'], isA<String>());
      expect((data['token'] as String).isNotEmpty, isTrue);
    });

    test('login fails with empty email or password', () async {
      final response = await service.login('', 'password');

      expect(response.body['status'], 'error');
      expect(response.body['message'], 'E-mail ou senha incorretos.');
    });

    test('getTravelsForClient returns an empty success list', () async {
      final response = await service.getTravelsForClient('token', 'client_1');

      expect(response.body['status'], 'success');
      expect(response.body['data'], isEmpty);
    });

    test('createTravel echoes back the submitted travel data', () async {
      final travelData = {'travelName': 'Trip to Tokyo'};
      final response = await service.createTravel('token', travelData);

      expect(response.body['status'], 'success');
      expect(response.body['data'], travelData);
    });
  });
}
