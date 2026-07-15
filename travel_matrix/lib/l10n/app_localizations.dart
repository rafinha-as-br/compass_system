import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Matrix'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Travel Matrix'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please login to continue'**
  String get loginSubtitle;

  /// No description provided for @loginLabel.
  ///
  /// In en, this message translates to:
  /// **'Access Travel Matrix'**
  String get loginLabel;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN AS AGENT'**
  String get loginButton;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get loginEmailRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get loginPasswordRequired;

  /// No description provided for @loginAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access denied. Only Travel Agents can access Travel Matrix.'**
  String get loginAccessDenied;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login.'**
  String get loginError;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboardTitle;

  /// No description provided for @totalTravels.
  ///
  /// In en, this message translates to:
  /// **'Total Travels'**
  String get totalTravels;

  /// No description provided for @itinerariesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Itineraries Completed'**
  String get itinerariesCompleted;

  /// No description provided for @pendingItineraries.
  ///
  /// In en, this message translates to:
  /// **'Pending Itineraries'**
  String get pendingItineraries;

  /// No description provided for @activeClients.
  ///
  /// In en, this message translates to:
  /// **'Active Clients'**
  String get activeClients;

  /// No description provided for @recentTravelUpdates.
  ///
  /// In en, this message translates to:
  /// **'Recent Travel Updates'**
  String get recentTravelUpdates;

  /// No description provided for @noTravelsCreated.
  ///
  /// In en, this message translates to:
  /// **'No travels created yet.'**
  String get noTravelsCreated;

  /// No description provided for @statusComplete.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get statusComplete;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get statusPending;

  /// No description provided for @allTravels.
  ///
  /// In en, this message translates to:
  /// **'All Travels'**
  String get allTravels;

  /// No description provided for @createTravel.
  ///
  /// In en, this message translates to:
  /// **'Create Travel'**
  String get createTravel;

  /// No description provided for @itineraryReady.
  ///
  /// In en, this message translates to:
  /// **'Itinerary Ready'**
  String get itineraryReady;

  /// No description provided for @routeOnly.
  ///
  /// In en, this message translates to:
  /// **'Route Only'**
  String get routeOnly;

  /// No description provided for @clientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get clientLabel;

  /// No description provided for @createTravelTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Travel'**
  String get createTravelTitle;

  /// No description provided for @stepCreateRoute.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Create Route'**
  String get stepCreateRoute;

  /// No description provided for @stepCreateRouteHint.
  ///
  /// In en, this message translates to:
  /// **'Define the route first. An itinerary can be created after.'**
  String get stepCreateRouteHint;

  /// No description provided for @travelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel Name'**
  String get travelNameLabel;

  /// No description provided for @travelNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Travel name is required'**
  String get travelNameRequired;

  /// No description provided for @startLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Location'**
  String get startLocationLabel;

  /// No description provided for @destinationLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destinationLabel;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDateLabel;

  /// No description provided for @endDateLabel.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDateLabel;

  /// No description provided for @interestPointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Interest Points'**
  String get interestPointsTitle;

  /// No description provided for @pointNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Point Name'**
  String get pointNameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @createItineraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Itinerary'**
  String get createItineraryTitle;

  /// No description provided for @editItineraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Itinerary'**
  String get editItineraryTitle;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @finishItinerary.
  ///
  /// In en, this message translates to:
  /// **'Finish Itinerary'**
  String get finishItinerary;

  /// No description provided for @deleteStep.
  ///
  /// In en, this message translates to:
  /// **'Delete Step'**
  String get deleteStep;

  /// No description provided for @deleteStepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this step?'**
  String get deleteStepConfirm;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @addStep.
  ///
  /// In en, this message translates to:
  /// **'Add Step'**
  String get addStep;

  /// No description provided for @addFirstStepHint.
  ///
  /// In en, this message translates to:
  /// **'Add your first step to begin building the itinerary.'**
  String get addFirstStepHint;

  /// No description provided for @previousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous Step'**
  String get previousStep;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @itinerarySavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Itinerary saved.'**
  String get itinerarySavedSuccess;

  /// No description provided for @itineraryFinishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Itinerary finished successfully!'**
  String get itineraryFinishedSuccess;

  /// No description provided for @failedToCreateItinerary.
  ///
  /// In en, this message translates to:
  /// **'Failed to create itinerary.'**
  String get failedToCreateItinerary;

  /// No description provided for @routeDetails.
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get routeDetails;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @interestPointsCount.
  ///
  /// In en, this message translates to:
  /// **'Interest Points ({count})'**
  String interestPointsCount(int count);

  /// No description provided for @noInterestPoints.
  ///
  /// In en, this message translates to:
  /// **'No interest points defined.'**
  String get noInterestPoints;

  /// No description provided for @noItineraryCreated.
  ///
  /// In en, this message translates to:
  /// **'No itinerary has been created yet.'**
  String get noItineraryCreated;

  /// No description provided for @notAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated.'**
  String get notAuthenticated;

  /// No description provided for @failedToFetchTravels.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch travels: {error}'**
  String failedToFetchTravels(String error);

  /// No description provided for @failedToFetchUsers.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch users: {error}'**
  String failedToFetchUsers(String error);

  /// No description provided for @usersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTitle;

  /// No description provided for @createUser.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get createUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @viewUser.
  ///
  /// In en, this message translates to:
  /// **'View User'**
  String get viewUser;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @deleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get deleteUserConfirm;

  /// No description provided for @agentSettings.
  ///
  /// In en, this message translates to:
  /// **'Agent Settings'**
  String get agentSettings;

  /// No description provided for @systemPreferences.
  ///
  /// In en, this message translates to:
  /// **'System Preferences'**
  String get systemPreferences;

  /// No description provided for @adminDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Admin Dark Mode'**
  String get adminDarkMode;

  /// No description provided for @logOutOfMatrix.
  ///
  /// In en, this message translates to:
  /// **'Log Out of Matrix'**
  String get logOutOfMatrix;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String dashboardWelcome(String name);

  /// No description provided for @dashboardWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your desk is ready with {pending} pending itineraries and {completed} completed itinerary records.'**
  String dashboardWelcomeSubtitle(int pending, int completed);

  /// No description provided for @recentTravels.
  ///
  /// In en, this message translates to:
  /// **'Recent Travels'**
  String get recentTravels;

  /// No description provided for @activeClientsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Clients'**
  String get activeClientsListTitle;

  /// No description provided for @travelNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Travel Name'**
  String get travelNameColumn;

  /// No description provided for @clientNameColumn.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get clientNameColumn;

  /// No description provided for @routeColumn.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeColumn;

  /// No description provided for @statusColumn.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusColumn;

  /// No description provided for @datesColumn.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get datesColumn;

  /// No description provided for @actionsColumn.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsColumn;

  /// No description provided for @viewTravel.
  ///
  /// In en, this message translates to:
  /// **'View Travel'**
  String get viewTravel;

  /// No description provided for @searchTravelsHint.
  ///
  /// In en, this message translates to:
  /// **'Search travels...'**
  String get searchTravelsHint;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get allStatus;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @cpfLabel.
  ///
  /// In en, this message translates to:
  /// **'CPF'**
  String get cpfLabel;

  /// No description provided for @cnpjLabel.
  ///
  /// In en, this message translates to:
  /// **'CNPJ'**
  String get cnpjLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @editAgentData.
  ///
  /// In en, this message translates to:
  /// **'Edit Agent Data'**
  String get editAgentData;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @digitalConcierge.
  ///
  /// In en, this message translates to:
  /// **'THE DIGITAL CONCIERGE'**
  String get digitalConcierge;

  /// No description provided for @dashboardNav.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardNav;

  /// No description provided for @bookingNav.
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookingNav;

  /// No description provided for @settingsNav.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNav;

  /// No description provided for @supportNav.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportNav;

  /// No description provided for @logoutNav.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutNav;

  /// No description provided for @travelAgentRole.
  ///
  /// In en, this message translates to:
  /// **'Travel Agent'**
  String get travelAgentRole;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
