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
  Client({
    required String id,
    required String name,
    required String email,
    required String password,
  }) : super(id: id, name: name, email: email, password: password, role: UserRole.client);
}

class TravelAgent extends User {
  TravelAgent({
    required String id,
    required String name,
    required String email,
    required String password,
  }) : super(id: id, name: name, email: email, password: password, role: UserRole.travelAgent);
}
