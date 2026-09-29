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

  // Participants
  static String travelParticipants(String travelId) => '/travels/$travelId/participants';

  // Places (CPS-152/CPS-154)
  static String placesAutocomplete(String query) => '/places/autocomplete?query=${Uri.encodeQueryComponent(query)}';

  // Notifications (CPS-149)
  static String notifications({required int page, required int size}) => '/notifications?page=$page&size=$size';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // Push targets (CPS-149)
  static const String pushTargets = '/push-targets';
  static const String pushTargetsVapidPublicKey = '/push-targets/vapid-public-key';
  static String pushTarget(String id) => '/push-targets/$id';
}
