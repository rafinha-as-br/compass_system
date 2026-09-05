/// Represents a person included in a [Travel]'s participants list.
class Person {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  final String name;
  final String age;
  final String sex;

  Person({
    required this.domainId,
    required this.backEndId,
    required this.name,
    required this.age,
    required this.sex,
  });
}
