import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';

void main() {
  group('Result', () {
    test('success carries data and isSuccess is true', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result, isA<Success<int>>());
      expect((result as Success<int>).data, 42);
    });

    test('failure carries message and isSuccess is false', () {
      const result = Result<int>.failure('deu ruim');

      expect(result.isSuccess, isFalse);
      expect(result, isA<Failure<int>>());
      expect((result as Failure<int>).message, 'deu ruim');
    });

    test('fold invokes onSuccess for a Success', () {
      const result = Result<String>.success('token123');

      final output = result.fold(
        onSuccess: (data) => 'ok:$data',
        onFailure: (message) => 'err:$message',
      );

      expect(output, 'ok:token123');
    });

    test('fold invokes onFailure for a Failure', () {
      const result = Result<String>.failure('E-mail ou senha incorretos.');

      final output = result.fold(
        onSuccess: (data) => 'ok:$data',
        onFailure: (message) => 'err:$message',
      );

      expect(output, 'err:E-mail ou senha incorretos.');
    });
  });
}
