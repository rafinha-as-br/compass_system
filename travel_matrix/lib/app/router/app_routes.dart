/// Route names centralization
abstract class AppRoutes {
  /// Public
  static const landing = '/';

  /// Private — shell branches
  static const dashboard = '/dashboard';
  static const travels = '/travels';
  static const users = '/users';
  static const account = '/account';
  static const settings = '/settings';

  /// Travels Sub-Routes
  static const travelCreate = 'create';
  static const travelView = ':id';
  static const routeCreate = 'route';
  static const itineraryCreate = 'itinerary';

  /// Users Sub-Routes
  static const userCreate = 'create';
  static const userView = ':id';
  static const userEdit = 'edit';
}