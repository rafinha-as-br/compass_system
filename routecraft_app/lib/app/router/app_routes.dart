/// Route path centralization.
abstract class AppRoutes {
  /// Public
  static const login = '/login';
  static const forgotPasswordSegment = 'forgot-password';
  static const resetPasswordSegment = 'reset-password';
  static const forgotPassword = '$login/$forgotPasswordSegment';
  static const resetPassword = '$login/$resetPasswordSegment';

  /// Private — shell branches
  static const home = '/home';
  static const itinerary = '/itinerary';
  static const account = '/account';

  /// Sub-routes (relative), reused under more than one branch
  static const createRoute = 'create-route';
  static const followTravel = 'follow';
  static const notifications = 'notifications';
  static const editRoute = 'edit-route';
  static const itineraryTimeline = 'timeline';

  /// Full paths for navigating to a sub-route from outside its parent.
  static const homeCreateRoute = '$home/$createRoute';
  static const homeFollowTravel = '$home/$followTravel';
  static const itineraryFollowTravel = '$itinerary/$followTravel';
  static const accountNotifications = '$account/$notifications';

  /// Query param carrying the travel's backend id on every route that also
  /// receives the `Travel` object via `extra` — `extra` doesn't survive a
  /// deep link or OS-level state restoration, but the URL does, so the id
  /// stays recoverable even when `extra` doesn't make it.
  static const travelIdParam = 'travelId';

  static String travelIdQuery(String travelId) => '$travelIdParam=$travelId';
}
