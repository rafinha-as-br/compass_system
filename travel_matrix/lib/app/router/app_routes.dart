/// Route names centralization
abstract class AppRoutes {
  /// Public
  static const landing = '/';

  /// Private — forced first-login password change. Outside the shell so a
  /// pending agent reaches no other screen (CPS-197).
  static const changePassword = '/change-password';

  /// Private — shown instead of any authenticated screen while the stored
  /// session's agent data can't be loaded (API unreachable, CPS-190).
  static const connectionError = '/connection-error';

  /// Private — shell branches
  static const dashboard = '/dashboard';
  static const travels = '/travels';
  static const users = '/users';
  static const company = '/company';
  static const account = '/account';

  /// Private — outside the sidebar's fixed nav branches (opened from the
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

  /// Company Sub-Routes
  static const companyInvite = 'invite';
}