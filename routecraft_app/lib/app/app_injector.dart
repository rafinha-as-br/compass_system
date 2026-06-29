import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/core/services/compass_service.dart';
import 'package:routecraft_app/core/services/local_db_service.dart';

class AppInjector {
  static Future<void> init() async {
    await AuthService.init();
    await CompassService.init();
    await LocalDbService.init();
  }
}

