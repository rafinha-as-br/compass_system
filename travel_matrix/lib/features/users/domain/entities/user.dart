
class UserClient{
  final String id;
  final String name;
  final String cpf;
  final String sex;
  final String phoneNumber;
  final String status;
  final String email;

  UserClient({
    required this.id, required this.name,
    required this.cpf, required this.sex,
    required this.phoneNumber, required this.status,
    required this.email
  });


  /// from json method
  factory UserClient.fromJson(Map<String, dynamic> json){
    return UserClient(
      id: json['id'],
      name: json['name'],
      cpf: json['cpf'],
      sex: json['sex'],
      phoneNumber: json['phoneNumber'],
      status: json['status'],
      email: json['email'],
    );
  }

  /// to json method
  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'sex': sex,
      'phoneNumber': phoneNumber,
      'status' : status,
      'email': email,
    };
  }

}