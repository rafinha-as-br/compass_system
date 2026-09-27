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
  static const String forgotPassword = '/api/auth/esqueci-senha';
  static const String resetPassword = '/api/auth/redefinir-senha';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';

  // Itinerary
  static String travelItinerary(String travelId) => '/travels/$travelId/itinerary';

  // Route
  static String travelRoute(String travelId) => '/travels/$travelId/route';

  // Company (módulo company — tenant do agente autenticado)
  static const String companyMe = '/api/companies/me';
  static const String companyAgents = '/api/companies/me/agents';
  static const String companyAgentInvite = '/api/companies/me/agents/invite';
  static String companyAgentById(String id) => '/api/companies/me/agents/$id';
  static String companyAgentRole(String id) => '/api/companies/me/agents/$id/role';
}
