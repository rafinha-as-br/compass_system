import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/core/services/push_service.dart';

class AppInjector {
  static Future<void> init() async {
    await AuthService.init();
    await PushService.init();
  }
}
