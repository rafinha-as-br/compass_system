enum UserRole { client, travelAgent }

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
    };
  }
}

class Client extends User {
  final String cpf;
  final String phoneNumber;
  final String sex;
  final DateTime birthDate;
  final bool isActive;

  Client({
    required String id,
    required String name,
    required String email,
    required String password,
    required this.cpf,
    required this.phoneNumber,
    required this.sex,
    required this.birthDate,
    this.isActive = true,
  }) : super(
          id: id,
          name: name,
          email: email,
          password: password,
          role: UserRole.client,
        );

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      cpf: (json['cpf'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
      sex: (json['sex'] ?? 'M').toString(),
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'].toString()) ?? DateTime(2000)
          : DateTime(2000),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'cpf': cpf,
      'phoneNumber': phoneNumber,
      'sex': sex,
      'birthDate': birthDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class TravelAgent extends User {
  TravelAgent({
    required String id,
    required String name,
    required String email,
    required String password,
  }) : super(id: id, name: name, email: email, password: password, role: UserRole.travelAgent);
}
