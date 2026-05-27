import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8081';
    if (Platform.isAndroid) return 'http://10.0.2.2:8081';
    return 'http://localhost:8081';
  }
  
  static const String travels = '/travels';
  static String travelById(String id) => '/travels/$id';

  // Users
  static const String users = '/users';
  static String userById(String id) => '/users/$id';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';


  /// TODO: REMOVE THIS ENDPOINT
  static String travelItinerary(String travelId) => '/travels/$travelId/itinerary';
}
