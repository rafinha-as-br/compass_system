import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travel_matrix/core/services/compass_service/api_exception.dart';
import 'package:travel_matrix/core/services/compass_service/http_api_client.dart';

void main() {
  late int hookCalls;

  setUp(() {
    hookCalls = 0;
    HttpApiClient.onPasswordChangeRequired = () => hookCalls++;
  });

  tearDown(() => HttpApiClient.onPasswordChangeRequired = null);

  HttpApiClient clientReturning(int status, String body) => HttpApiClient.forTesting(
        MockClient((_) async => http.Response(body, status)),
      );

  test('403 PASSWORD_CHANGE_REQUIRED notifies the hook and still throws', () async {
    final client = clientReturning(
      403,
      '{"status":403,"error":"PASSWORD_CHANGE_REQUIRED","message":"Troque a senha."}',
    );

    await expectLater(client.get('t', '/travels'), throwsA(isA<ApiException>()));
    expect(hookCalls, 1);
  });

  test('other 403 responses do not notify the hook', () async {
    final client = clientReturning(403, '{"status":403,"message":"Forbidden"}');

    await expectLater(client.get('t', '/travels'), throwsA(isA<ApiException>()));
    expect(hookCalls, 0);
  });

  test('a non-JSON 403 body does not notify the hook', () async {
    final client = clientReturning(403, 'nope');

    await expectLater(client.get('t', '/travels'), throwsA(isA<ApiException>()));
    expect(hookCalls, 0);
  });
}
