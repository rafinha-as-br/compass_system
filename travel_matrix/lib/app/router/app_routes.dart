/// Route names centralization
abstract class AppRoutes {
  /// Public
  static const landing = '/';

  /// Private — shell branches
  static const dashboard = '/dashboard';
  static const travels = '/travels';
  static const users = '/users';
  static const account = '/account';

  /// Private — outside the sidebar's 3 fixed nav branches (opened from the
  /// sidebar header's bell icon, CPS-149).
  static const notifications = '/notifications';

  /// Travels Sub-Routes
  static const travelView = ':id';
  static const routeCreate = 'route';
  static const itineraryCreate = 'itinerary';

  /// Users Sub-Routes
  static const userCreate = 'create';
  static const userView = ':id';
  static const userEdit = 'edit';
  static const userTravelCreate = 'create-travel';
}