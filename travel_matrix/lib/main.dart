import 'package:flutter/material.dart';
import 'package:travel_matrix/app/app_bootstrap.dart';
import 'app/app_injector.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInjector.init();
  runApp(const AppBootstrap());
}
