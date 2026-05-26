import '../core/services/auth_service.dart';
import '../core/services/compass_service.dart';

/// Responsible for injecting main dependencies into the app.
class AppInjector {
  static Future<void> init() async {
    await AuthService.init();
    await CompassService.init();
  }
}

