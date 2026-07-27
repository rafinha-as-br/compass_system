import 'package:travel_matrix/core/services/compass_service/compass_service.dart';

class AuthDataSource {
  final CompassService _compassService;

  AuthDataSource({CompassService? compassService})
      : _compassService = compassService ?? CompassService.instance;

  Future<Map<String, dynamic>> login(String email, String password) {
    return _compassService.login(email, password);
  }
}
