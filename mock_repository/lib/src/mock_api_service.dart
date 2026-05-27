import 'dart:math';

import 'package:mock_repository/src/models/itinerary_models.dart';
import 'package:mock_repository/src/models/route_models.dart';
import 'package:mock_repository/src/models/user_models.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();

  factory MockApiService() {
    return _instance;
  }

  MockApiService._internal() {
    _seedData();
  }

  // In-memory data
  final List<User> _users = [];
  final List<RoutePlan> _routes = [];
  final List<Itinerary> _itineraries = [];

  void _seedData() {
    _users.add(Client(
        id: 'client_1',
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123',
        cpf: '000.000.000-00',
        phoneNumber: '+55 11 00000-0000',
        sex: 'M',
        birthDate: DateTime(1990, 1, 1),
        isActive: true));
    _users.add(TravelAgent(
        id: 'agent_1', name: 'Agent Smith', email: 'smith@matrix.com', password: 'password123'));

    final sampleRoute = RoutePlan(
      id: 'route_1',
      clientId: 'client_1',
      tripName: 'Summer Vacation in Paris',
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 40)),
      startLocation: 'New York',
      destination: 'Paris',
      interestsList: ['Museums', 'Food'],
      pointsOfInterest: [
        InterestPoint(
          id: 'poi_1',
          routeId: 'route_1',
          name: 'Louvre',
          description: 'Famous museum',
          geographicLocation: 'Paris Central',
        )
      ],
    );
    _routes.add(sampleRoute);

    final sampleItinerary = Itinerary(
      id: 'itinerary_1',
      routeId: 'route_1',
      createdByAgent: 'agent_1',
      listOfStops: [
        ItineraryStop(
          id: 'stop_1',
          itineraryId: 'itinerary_1',
          location: 'Charles de Gaulle Airport',
          description: 'Arrival and transfer to hotel',
          reservationInformation: 'Flight AF123',
        ),
        ItineraryStop(
          id: 'stop_2',
          itineraryId: 'itinerary_1',
          location: 'Louvre Museum',
          description: 'Morning tour',
          reservationInformation: 'Ticket #4492',
        )
      ],
    );
    _itineraries.add(sampleItinerary);
  }

  // --- Users ---
  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    return List.unmodifiable(_users);
  }

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      return _users.firstWhere((u) => u.email == email && u.password == password);
    } catch (e) {
      return null;
    }
  }

  Future<User> registerUser(User user) async {
    await Future.delayed(const Duration(seconds: 1));
    _users.add(user);
    return user;
  }

  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    _users.removeWhere((u) => u.id == id);
  }

  // --- Routes ---
  Future<List<RoutePlan>> getRoutes() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_routes);
  }

  Future<List<RoutePlan>> getRoutesForClient(String clientId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _routes.where((r) => r.clientId == clientId).toList();
  }

  Future<RoutePlan> createRoute(RoutePlan route) async {
    await Future.delayed(const Duration(seconds: 1));
    _routes.add(route);
    return route;
  }

  // --- Itineraries ---
  Future<List<Itinerary>> getItineraries() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.unmodifiable(_itineraries);
  }

  Future<Itinerary> getItineraryForRoute(String routeId) async {
    await Future.delayed(const Duration(seconds: 1));
    return _itineraries.firstWhere((i) => i.routeId == routeId);
  }

  Future<Itinerary> createItinerary(Itinerary itinerary) async {
    await Future.delayed(const Duration(seconds: 1));
    _itineraries.add(itinerary);
    return itinerary;
  }
}
