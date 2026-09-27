import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:routecraft_app/core/network/clients/push_target_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';

void main() {
  group('PushTargetApiClient.registerAndroid', () {
    test('POSTs the platform and endpoint, returning the created target', () async {
      late http.Request captured;
      final client = PushTargetApiClient(HttpApiClient.forTesting(MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode({'id': 'pt1', 'androidEndpoint': 'http://ntfy:80/up1'}), 200);
      })));

      final result = await client.registerAndroid('test-token', 'http://ntfy:80/up1');

      expect(result['id'], 'pt1');
      expect(captured.method, 'POST');
      expect(captured.url.path, '/push-targets');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['platform'], 'ANDROID');
      expect(body['androidEndpoint'], 'http://ntfy:80/up1');
    });
  });

  group('PushTargetApiClient.unregister', () {
    test('DELETEs the target by id', () async {
      late http.Request captured;
      final client = PushTargetApiClient(HttpApiClient.forTesting(MockClient((request) async {
        captured = request;
        return http.Response('', 204);
      })));

      await client.unregister('test-token', 'pt1');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/push-targets/pt1');
    });
  });
}
