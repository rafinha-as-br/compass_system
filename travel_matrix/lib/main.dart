import 'package:flutter/material.dart';
import 'package:travel_matrix/app/app.dart';
import 'package:travel_matrix/core/services/auth_service.dart';
import 'package:travel_matrix/core/services/compass_service.dart';

class AppInjector {
  static Future<void> init() async {
    await AuthService.init();
    await CompassService.init();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInjector.init();
  runApp(const TravelMatrixApp());
}
