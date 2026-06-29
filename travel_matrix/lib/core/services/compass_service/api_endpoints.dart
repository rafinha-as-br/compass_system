import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8081';
    if (Platform.isAndroid) return 'http://10.0.2.2:8081';
    return 'http://localhost:8081';
  }
  
  // Travels
  static const String travels = '/travels';
  static String travelById(String id) => '/travels/$id';
  static String travelsByClient(String clientName) => '/travels/client/$clientName';

  // Users
  static const String users = '/users';
  static const String userMe = '/users/me';
  static String userById(String id) => '/users/$id';

  // Users - Security
  static String userResetPassword(String id) => '/users/$id/reset-password';
  static String userForceLogout(String id) => '/users/$id/force-logout';
  static String userDeactivate(String id) => '/users/$id/deactivate';

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/cadastrar/cliente';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';

  // Itinerary
  static String travelItinerary(String travelId) => '/travels/$travelId/itinerary';
}
