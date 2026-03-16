import 'package:mock_repository/mock_repository.dart';

class CompassService {
  static CompassService? _instance;
  final MockApiService _apiService;

  CompassService._() : _apiService = MockApiService();

  static Future<CompassService> init() async {
    _instance ??= CompassService._();
    return _instance!;
  }

  static CompassService get instance {
    assert(_instance != null, 'CompassService instance not initialized!');
    return _instance!;
  }

  // Wrappers around MockApiService
  Future<User?> login(String email, String password) {
    return _apiService.login(email, password);
  }

  Future<User> registerUser(User user) {
    return _apiService.registerUser(user);
  }

  Future<List<User>> getUsers() {
    return _apiService.getUsers();
  }

  Future<RoutePlan> createRoute(RoutePlan route) {
    return _apiService.createRoute(route);
  }

  Future<List<RoutePlan>> getRoutes() {
    return _apiService.getRoutes();
  }

  Future<List<Itinerary>> getItineraries() {
    return _apiService.getItineraries();
  }

  Future<Itinerary> getItineraryForRoute(String routeId) {
    return _apiService.getItineraryForRoute(routeId);
  }

  Future<Itinerary> createItinerary(Itinerary itinerary) {
    return _apiService.createItinerary(itinerary);
  }
}
