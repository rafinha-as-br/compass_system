import '../core/services/auth_storage_service.dart';
import '../core/services/compass_service/compass_service.dart';
import '../core/services/settings_storage_service.dart';

/// Responsible for injecting main dependencies into the app.
class AppInjector {
  static Future<void> init() async {
    await AuthStorageService.init();
    await SettingsStorageService.init();
    await CompassService.init();
  }
}

