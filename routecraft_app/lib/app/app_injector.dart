import 'package:routecraft_app/core/services/auth_service.dart';

class AppInjector {
  static Future<void> init() async {
    await AuthService.init();
  }
}
