import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:uuid/uuid.dart';

/// Represent a person that is included in a [Travel].
class Person {
  /// Id used for local reference
  final String domainId;
  /// Id used reference on the Compass API
  final String? id;
  /// Person ful name
  final String name;
  /// Person age
  final String age;
  /// Person sex
  final String sex;

  /// Private constructor
  Person._({
    required this.domainId,
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
  });

  /// Creates a new [Person] on local data
  factory Person.newLocal({
    required String name,
    required String age,
    required String sex,
  }) {
    return Person._(
      domainId: Uuid().v4(),
      id: null,
      name: name,
      age: age,
      sex: sex,
    );
  }

  /// Creates a new [Person] from API data
  factory Person.fromApi({
    required String id,
    required String name,
    required String age,
    required String sex,
  }) {
    return Person._(
      domainId: Uuid().v4(),
      id: id,
      name: name,
      age: age,
      sex: sex,
    );
  }


  /// To Json method, returns a [Map] with the person data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'sex': sex,
    };
  }

  /// From Json method, returns a [Person] from a [Map]
  Person fromJson(Map<String, dynamic> json) {
    return Person._(
      domainId: json['domainId'],
      id: json['id'],
      name: json['name'],
      age: json['age'],
      sex: json['sex'],
    );
  }

}