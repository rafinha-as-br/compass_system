import 'package:flutter/material.dart';
import 'package:routecraft_app/app/app.dart';
import 'package:routecraft_app/app/app_injector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInjector.init();
  runApp(const RouteCraftApp());
}
