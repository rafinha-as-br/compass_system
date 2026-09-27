import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travel_matrix/core/services/compass_service/api_exception.dart';
import 'package:travel_matrix/core/services/compass_service/clients/places_api_client.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

void main() {
  group('PlacesApiClient', () {
    test("success: parses each suggestion's name and coordinate", () async {
      final client = PlacesApiClient.forTesting(HttpApiClient.forTesting(
        MockClient((request) async {
          expect(request.url.path, '/places/autocomplete');
          expect(request.url.queryParameters['query'], 'flor');
          return http.Response(
            jsonEncode([
              {'name': 'Florianópolis, SC, Brasil', 'latitude': -27.5954, 'longitude': -48.5480},
              {'name': 'Floriano, PI, Brasil', 'latitude': -6.7671, 'longitude': -43.0225},
            ]),
            200,
          );
        }),
      ));

      final results = await client.autocomplete('token', 'flor');

      expect(results, hasLength(2));
      expect(results[0].text, 'Florianópolis, SC, Brasil');
      expect(results[0].coordinate.latitude, -27.5954);
      expect(results[0].coordinate.longitude, -48.5480);
    });

    test('empty: provider found nothing', () async {
      final client = PlacesApiClient.forTesting(HttpApiClient.forTesting(
        MockClient((request) async => http.Response('[]', 200)),
      ));

      final results = await client.autocomplete('token', 'zzz');

      expect(results, isEmpty);
    });

    test('failure: 503 from the facade surfaces as ApiException', () async {
      final client = PlacesApiClient.forTesting(HttpApiClient.forTesting(
        MockClient((request) async => http.Response(
              jsonEncode({'status': 503, 'error': 'Serviço indisponível', 'message': 'Nominatim indisponível'}),
              503,
            )),
      ));

      expect(
        () => client.autocomplete('token', 'flor'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 503)),
      );
    });
  });
}
