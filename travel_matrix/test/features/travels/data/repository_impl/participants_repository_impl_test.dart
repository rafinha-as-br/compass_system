import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/travels/data/data_sources/participants_data_source.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/participants_repository_impl.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';

class _MockParticipantsDataSource extends Mock implements ParticipantsDataSource {}

Person _buildPerson({String name = 'Ana Silva'}) {
  return Person(domainId: 'p-1', backendId: 'p-1', name: name, age: '30', sex: 'F');
}

PersonDTO _buildPersonDto({String name = 'Ana Silva'}) {
  return PersonDTO.fromDomain(person: _buildPerson(name: name));
}

void main() {
  late _MockParticipantsDataSource dataSource;
  late ParticipantsRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(<PersonDTO>[]);
  });

  setUp(() {
    dataSource = _MockParticipantsDataSource();
    repository = ParticipantsRepositoryImpl(dataSource: dataSource);
  });

  test('upserts the participants list through the isolated endpoint and returns the updated list', () async {
    when(() => dataSource.updateParticipants('travel-1', any()))
        .thenAnswer((_) async => [_buildPersonDto(name: 'Bruno Costa')]);

    final result = await repository.updateParticipants('travel-1', [_buildPerson(name: 'Bruno Costa')]);

    expect(result.isSuccess, isTrue);
    expect(result.data, hasLength(1));
    expect(result.data!.first.name, 'Bruno Costa');

    final sentDtos =
        verify(() => dataSource.updateParticipants('travel-1', captureAny())).captured.single as List<PersonDTO>;
    expect(sentDtos.single.name, 'Bruno Costa');
  });

  test('returns failure without throwing when the data source fails', () async {
    when(() => dataSource.updateParticipants('travel-1', any())).thenThrow(Exception('Network error'));

    final result = await repository.updateParticipants('travel-1', [_buildPerson()]);

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Network error'));
  });
}
