// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RouteCraft';

  @override
  String get loginTitle => 'RouteCraft Login';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'LOGIN';

  @override
  String get loginEmailRequired => 'Enter email';

  @override
  String get loginPasswordRequired => 'Enter password';

  @override
  String get loginAccessDenied =>
      'Access denied. Only Clients can access RouteCraft.';

  @override
  String get loginError => 'An error occurred during login.';

  @override
  String get homeTitle => 'RouteCraft Home';

  @override
  String get createRouteNav => 'Create a Route';

  @override
  String get visualizeRoutesNav => 'Visualize Routes & Itineraries';

  @override
  String get accountSettingsNav => 'User Account & Settings';

  @override
  String get createRouteTitle => 'Create a Route';

  @override
  String get tripInfoStep => 'Trip Info';

  @override
  String get tripNameLabel => 'Trip Name';

  @override
  String get locationsStep => 'Locations';

  @override
  String get startLocationLabel => 'Start Location';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get interestsStep => 'Interests';

  @override
  String get submitRoute => 'SUBMIT ROUTE';

  @override
  String get nextButton => 'NEXT';

  @override
  String get backButton => 'BACK';

  @override
  String get routeCreatedSuccess => 'Route created successfully!';

  @override
  String get backToHome => 'Back to Home';

  @override
  String failedToCreateRoute(String error) {
    return 'Failed to create route: $error';
  }

  @override
  String get successTitle => 'Success';

  @override
  String get visualizationTitle => 'My Travels';

  @override
  String get noTravelsYet => 'No travels yet.';

  @override
  String get itineraryLabel => 'Itinerary';

  @override
  String stepsCount(int count) {
    return '$count steps';
  }

  @override
  String get noItinerary => 'No itinerary';

  @override
  String get routeLabel => 'Route';

  @override
  String get accountTitle => 'My Account';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get logoutButton => 'LOGOUT';

  @override
  String get notAuthenticated => 'Not authenticated.';
}
