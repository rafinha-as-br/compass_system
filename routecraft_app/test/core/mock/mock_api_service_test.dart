import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/mock/mock_repository.dart';

void main() {
  group('MockApiService', () {
    late MockApiService service;

    setUp(() {
      service = MockApiService();
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
