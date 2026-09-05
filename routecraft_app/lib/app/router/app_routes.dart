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

  /// Full paths for navigating to a sub-route from outside its parent.
  static const homeCreateRoute = '$home/$createRoute';
  static const homeFollowTravel = '$home/$followTravel';
  static const itineraryFollowTravel = '$itinerary/$followTravel';
}
