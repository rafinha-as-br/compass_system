import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/account/data/account_data_source.dart';
import 'package:travel_matrix/features/account/data/account_repository_impl.dart';

class _MockAccountDataSource extends Mock implements AccountDataSource {}

void main() {
  late _MockAccountDataSource dataSource;
  late AccountRepositoryImpl repository;

  setUp(() {
    dataSource = _MockAccountDataSource();
    repository = AccountRepositoryImpl(dataSource);
  });

  group('changePassword', () {
    test('completes when the backend answers success', () async {
      when(() => dataSource.changePassword('old', 'new-password-1'))
          .thenAnswer((_) async => {'status': 'success', 'data': null});

      await repository.changePassword('old', 'new-password-1');

      verify(() => dataSource.changePassword('old', 'new-password-1')).called(1);
    });

    test('throws StateError with the backend message when refused', () async {
      when(() => dataSource.changePassword('wrong', 'new-password-1')).thenAnswer(
        (_) async => {'status': 'error', 'message': 'A senha atual está incorreta.'},
      );

      expect(
        () => repository.changePassword('wrong', 'new-password-1'),
        throwsA(
          isA<StateError>().having((e) => e.message, 'message', 'A senha atual está incorreta.'),
        ),
      );
    });
  });
}
