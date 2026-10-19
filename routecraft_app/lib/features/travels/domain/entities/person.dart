/// Represents a person included in a [Travel]'s participants list.
class Person {
  /// Id used for local reference
  final String domainId;

  /// Id used for API reference
  final String? backEndId;

  final String name;
  final String age;
  final String sex;

  /// 1-based index of the person's character in the avatar catalog
  /// (`assets/avatars/animal_<n>.png`); null when no character was chosen.
  final int? avatarIndex;

  Person({
    required this.domainId,
    required this.backEndId,
    required this.name,
    required this.age,
    required this.sex,
    this.avatarIndex,
  });
}
