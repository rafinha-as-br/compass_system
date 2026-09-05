import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8081';
    if (Platform.isAndroid) return 'http://10.0.2.2:8081';
    return 'http://localhost:8081';
  }

  // Auth
  static const String login = '/api/auth/login';
  static const String registerClient = '/api/auth/cadastrar/cliente';
  static const String forgotPassword = '/api/auth/esqueci-senha';
  static const String resetPassword = '/api/auth/redefinir-senha';

  // Travels
  static const String travels = '/travels';
  static String travelById(String id) => '/travels/$id';
  static String travelsByClient(String clientName) => '/travels/client/$clientName';
  static String travelRoute(String travelId) => '/travels/$travelId/route';
}
