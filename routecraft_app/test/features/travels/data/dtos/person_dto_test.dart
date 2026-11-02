import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';

void main() {
  group('PersonDTO avatarIndex', () {
    test('is read from the API payload and carried to the domain', () {
      final dto = PersonDTO.fromJson({'id': 'p1', 'name': 'Ana', 'age': '30', 'sex': 'F', 'avatarIndex': 3});

      expect(dto.avatarIndex, 3);
      expect(dto.toDomain().avatarIndex, 3);
    });

    test('stays null when the API has no character for the person', () {
      expect(PersonDTO.fromJson({'id': 'p1', 'name': 'Ana'}).avatarIndex, isNull);
      expect(PersonDTO.fromJson({'id': 'p1', 'name': 'Ana', 'avatarIndex': null}).avatarIndex, isNull);
    });

    test('is sent back in the participants PUT payload', () {
      final person = Person(domainId: 'd1', backEndId: 'p1', name: 'Ana', age: '30', sex: 'F', avatarIndex: 5);

      expect(PersonDTO.fromDomain(person).toJson()['avatarIndex'], 5);
      expect(
        PersonDTO.fromDomain(Person(domainId: 'd2', backEndId: null, name: 'Bia', age: '', sex: 'F')).toJson(),
        containsPair('avatarIndex', isNull),
      );
    });
  });

  group('PersonDTO note', () {
    test('is read from the API payload and carried to the domain', () {
      final dto = PersonDTO.fromJson({'id': 'p1', 'name': 'Ana', 'note': 'Vegetariana'});

      expect(dto.note, 'Vegetariana');
      expect(dto.toDomain().note, 'Vegetariana');
    });

    test('stays null when the API has no note for the person', () {
      expect(PersonDTO.fromJson({'id': 'p1', 'name': 'Ana'}).note, isNull);
      expect(PersonDTO.fromJson({'id': 'p1', 'name': 'Ana', 'note': null}).note, isNull);
    });

    test('is sent back in the participants PUT payload, so the full-list upsert keeps the agent note', () {
      final person = Person(domainId: 'd1', backEndId: 'p1', name: 'Ana', age: '30', sex: 'F', note: 'Mobilidade reduzida');

      expect(PersonDTO.fromDomain(person).toJson()['note'], 'Mobilidade reduzida');
    });
  });
}
