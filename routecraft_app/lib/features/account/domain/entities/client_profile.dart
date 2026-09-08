/// The authenticated client's personal data, as exposed by `GET /users/me`
/// and edited via `PUT /users/{id}`.
class ClientProfile {
  final String id;
  final String name;
  final String cpf;
  final String phoneNumber;
  final String email;
  final int? age;
  final String sex;

  const ClientProfile({
    required this.id,
    required this.name,
    required this.cpf,
    required this.phoneNumber,
    required this.email,
    required this.age,
    required this.sex,
  });

  ClientProfile copyWith({
    String? name,
    String? phoneNumber,
    int? age,
    String? sex,
  }) {
    return ClientProfile(
      id: id,
      name: name ?? this.name,
      cpf: cpf,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email,
      age: age ?? this.age,
      sex: sex ?? this.sex,
    );
  }
}
