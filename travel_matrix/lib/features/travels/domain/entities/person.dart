import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:uuid/uuid.dart';

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

  /// Private constructor
  Person({
    required this.domainId,
    required this.backendId,
    required this.name,
    required this.age,
    required this.sex,
  });

}