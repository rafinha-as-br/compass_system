class Person {
  final String id;
  final String name;
  final String age;
  final String sex;

  Person({
    required this.id,
    required this.name,
    required this.age,
    required this.sex,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'sex': sex,
    };
  }
}