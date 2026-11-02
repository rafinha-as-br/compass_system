import 'package:travel_matrix/features/travels/domain/entities/travel.dart';

/// Represent a person that is included in a [Travel].
class Person {
  /// Id used for local reference
  final String domainId;
  /// Id used reference on the Compass API
  final String? backendId;
  /// Person ful name
  final String name;
  /// Person age
  final String age;
  /// Person sex
  final String sex;
  /// 1-based index of the person's character in the avatar catalog
  /// (`assets/avatars/animal_<n>.png`); null when no character was chosen
  final int? avatarIndex;
  /// Free-text observations about the person (food intolerance, mobility...);
  /// null when there is none
  final String? note;

  /// Private constructor
  Person({
    required this.domainId,
    required this.backendId,
    required this.name,
    required this.age,
    required this.sex,
    this.avatarIndex,
    this.note,
  });

}