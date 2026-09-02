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

  /// No description provided for @loginTitlePanel.
  ///
  /// In en, this message translates to:
  /// **'Agent Login'**
  String get loginTitlePanel;

  /// No description provided for @loginSubtitlePanel.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to continue'**
  String get loginSubtitlePanel;

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

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a code to reset your password.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'SEND CODE'**
  String get forgotPasswordSubmitButton;

  /// No description provided for @forgotPasswordConfirmation.
  ///
  /// In en, this message translates to:
  /// **'If this email is registered, you will receive a code to reset your password.'**
  String get forgotPasswordConfirmation;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code you received by email and choose a new password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get resetPasswordTokenLabel;

  /// No description provided for @resetPasswordTokenRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the code'**
  String get resetPasswordTokenRequired;

  /// No description provided for @resetPasswordNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetPasswordNewPasswordLabel;

  /// No description provided for @resetPasswordNewPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password'**
  String get resetPasswordNewPasswordRequired;

  /// No description provided for @resetPasswordSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'RESET PASSWORD'**
  String get resetPasswordSubmitButton;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. You can now log in.'**
  String get resetPasswordSuccess;

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

  /// No description provided for @failedToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your dashboard right now. Please try again later.'**
  String get failedToLoadDashboard;

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

  /// No description provided for @failedToLoadTravels.
  ///
  /// In en, this message translates to:
  /// **'Unable to load travels right now. Please try again later.'**
  String get failedToLoadTravels;

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

  /// No description provided for @travelInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get travelInProgress;

  /// No description provided for @travelCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get travelCompleted;

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

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your profile right now. Please try again later.'**
  String get failedToLoadProfile;

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

  /// No description provided for @clientUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Client Users'**
  String get clientUsersTitle;

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsersHint;

  /// No description provided for @activeStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatusLabel;

  /// No description provided for @inactiveStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveStatusLabel;

  /// No description provided for @noClientUsersFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'No client users found.'**
  String get noClientUsersFoundMessage;

  /// No description provided for @failedToLoadUsers.
  ///
  /// In en, this message translates to:
  /// **'Unable to load users right now. Please try again later.'**
  String get failedToLoadUsers;

  /// No description provided for @backToUsersButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Users'**
  String get backToUsersButton;

  /// No description provided for @maleGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get maleGenderLabel;

  /// No description provided for @femaleGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get femaleGenderLabel;

  /// No description provided for @otherOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherOptionLabel;

  /// No description provided for @travelHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel History'**
  String get travelHistoryTitle;

  /// No description provided for @noTravelsForUserMessage.
  ///
  /// In en, this message translates to:
  /// **'No travels found for this user.'**
  String get noTravelsForUserMessage;

  /// No description provided for @securityActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Actions'**
  String get securityActionsTitle;

  /// No description provided for @resetPasswordActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordActionTitle;

  /// No description provided for @resetPasswordActionDescription.
  ///
  /// In en, this message translates to:
  /// **'Send a link to the user\'s email to securely reset their password.'**
  String get resetPasswordActionDescription;

  /// No description provided for @forceLogoutActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Force Logout'**
  String get forceLogoutActionTitle;

  /// No description provided for @forceLogoutActionDescription.
  ///
  /// In en, this message translates to:
  /// **'Immediately terminate all active sessions for this user.'**
  String get forceLogoutActionDescription;

  /// No description provided for @resetPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent'**
  String get resetPasswordSuccessMessage;

  /// No description provided for @resetPasswordFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link'**
  String get resetPasswordFailureMessage;

  /// No description provided for @forceLogoutSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'User sessions terminated'**
  String get forceLogoutSuccessMessage;

  /// No description provided for @forceLogoutFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to terminate sessions'**
  String get forceLogoutFailureMessage;

  /// No description provided for @travelStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Stats'**
  String get travelStatsTitle;

  /// No description provided for @uniqueDestinationsStatLabel.
  ///
  /// In en, this message translates to:
  /// **'UNIQUE DESTINATIONS'**
  String get uniqueDestinationsStatLabel;

  /// No description provided for @forceLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Force Logout?'**
  String get forceLogoutConfirmTitle;

  /// No description provided for @forceLogoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will immediately terminate all active sessions for this user. Continue?'**
  String get forceLogoutConfirmMessage;

  /// No description provided for @confirmActionButton.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirmActionButton;

  /// No description provided for @cancelActionButton.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancelActionButton;

  /// No description provided for @newClientUserFormTitle.
  ///
  /// In en, this message translates to:
  /// **'New Client User'**
  String get newClientUserFormTitle;

  /// No description provided for @fullNameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameFieldLabel;

  /// No description provided for @nameRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequiredValidation;

  /// No description provided for @cpfRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'CPF is required'**
  String get cpfRequiredValidation;

  /// No description provided for @emailRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequiredValidation;

  /// No description provided for @phoneNumberFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberFieldLabel;

  /// No description provided for @phoneRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequiredValidation;

  /// No description provided for @initialPasswordFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Initial Password'**
  String get initialPasswordFieldLabel;

  /// No description provided for @passwordRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequiredValidation;

  /// No description provided for @sexFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sexFieldLabel;

  /// No description provided for @birthDateFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDateFieldLabel;

  /// No description provided for @createUserSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE USER'**
  String get createUserSubmitButton;

  /// No description provided for @editUserPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit: {name}'**
  String editUserPageSubtitle(String name);

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChangesButton;

  /// No description provided for @deactivateUserDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate User'**
  String get deactivateUserDialogTitle;

  /// No description provided for @deactivateReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Why are you deactivating {name}?'**
  String deactivateReasonPrompt(String name);

  /// No description provided for @deactivateReasonClientRequest.
  ///
  /// In en, this message translates to:
  /// **'Client request'**
  String get deactivateReasonClientRequest;

  /// No description provided for @deactivateReasonNonPayment.
  ///
  /// In en, this message translates to:
  /// **'Non-payment'**
  String get deactivateReasonNonPayment;

  /// No description provided for @deactivateReasonTermsViolation.
  ///
  /// In en, this message translates to:
  /// **'Terms of service violation'**
  String get deactivateReasonTermsViolation;

  /// No description provided for @deactivateReasonDuplicateAccount.
  ///
  /// In en, this message translates to:
  /// **'Duplicate account'**
  String get deactivateReasonDuplicateAccount;

  /// No description provided for @specifyReasonFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Specify the reason'**
  String get specifyReasonFieldLabel;

  /// No description provided for @deactivateButtonCaps.
  ///
  /// In en, this message translates to:
  /// **'DEACTIVATE'**
  String get deactivateButtonCaps;

  /// No description provided for @userNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'User Not Found'**
  String get userNotFoundTitle;

  /// No description provided for @userNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The requested user could not be found.'**
  String get userNotFoundMessage;

  /// No description provided for @buildItineraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Itinerary'**
  String get buildItineraryTitle;

  /// No description provided for @cannotMoveStep.
  ///
  /// In en, this message translates to:
  /// **'Cannot move this step to that position.'**
  String get cannotMoveStep;

  /// No description provided for @cannotDeleteStepMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete this step.'**
  String get cannotDeleteStepMessage;

  /// No description provided for @itineraryUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Itinerary updated.'**
  String get itineraryUpdatedSuccess;

  /// No description provided for @itineraryCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Itinerary created.'**
  String get itineraryCreatedSuccess;

  /// No description provided for @couldNotSaveItinerary.
  ///
  /// In en, this message translates to:
  /// **'Could not save itinerary.'**
  String get couldNotSaveItinerary;

  /// No description provided for @editRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Route'**
  String get editRouteTitle;

  /// No description provided for @updateRouteButton.
  ///
  /// In en, this message translates to:
  /// **'UPDATE ROUTE'**
  String get updateRouteButton;

  /// No description provided for @createTravelButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE TRAVEL'**
  String get createTravelButton;

  /// No description provided for @editRoutePlanButton.
  ///
  /// In en, this message translates to:
  /// **'Edit Route Plan'**
  String get editRoutePlanButton;

  /// No description provided for @markAsReadyButton.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get markAsReadyButton;

  /// No description provided for @markAsReadyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this travel as ready?'**
  String get markAsReadyConfirm;

  /// No description provided for @confirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmButton;

  /// No description provided for @markAsReadySuccess.
  ///
  /// In en, this message translates to:
  /// **'Travel marked as ready successfully'**
  String get markAsReadySuccess;

  /// No description provided for @markAsReadyFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to mark travel as ready'**
  String get markAsReadyFailure;

  /// No description provided for @needsItineraryFirstTooltip.
  ///
  /// In en, this message translates to:
  /// **'You need to create an itinerary first'**
  String get needsItineraryFirstTooltip;

  /// No description provided for @markAsReadyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark travel as ready'**
  String get markAsReadyTooltip;

  /// No description provided for @routeViewTab.
  ///
  /// In en, this message translates to:
  /// **'Route View'**
  String get routeViewTab;

  /// No description provided for @itineraryViewTab.
  ///
  /// In en, this message translates to:
  /// **'Itinerary View'**
  String get itineraryViewTab;

  /// No description provided for @travelersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Travelers'**
  String travelersCount(int count);

  /// No description provided for @travelNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Not Found'**
  String get travelNotFoundTitle;

  /// No description provided for @travelNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The requested travel could not be found.'**
  String get travelNotFoundBody;

  /// No description provided for @changeStepTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Step Type?'**
  String get changeStepTypeTitle;

  /// No description provided for @changeStepTypeBody.
  ///
  /// In en, this message translates to:
  /// **'Changing the step type will result in the loss of specific data entered for the current step. Do you wish to proceed?'**
  String get changeStepTypeBody;

  /// No description provided for @changeTransportTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Transport Type?'**
  String get changeTransportTypeTitle;

  /// No description provided for @changeTransportTypeBody.
  ///
  /// In en, this message translates to:
  /// **'Changing the transport type will result in the loss of specific data entered for the current transport. Do you wish to proceed?'**
  String get changeTransportTypeBody;

  /// No description provided for @proceedButton.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceedButton;

  /// No description provided for @noStepsYet.
  ///
  /// In en, this message translates to:
  /// **'No steps yet'**
  String get noStepsYet;

  /// No description provided for @noItineraryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No itinerary available.'**
  String get noItineraryAvailable;

  /// No description provided for @stepDetailsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Additional details for this step are not yet available.'**
  String get stepDetailsUnavailable;

  /// No description provided for @draftStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft Step'**
  String get draftStepTitle;

  /// No description provided for @unknownStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Step'**
  String get unknownStepTitle;

  /// No description provided for @noItineraryYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Itinerary Yet'**
  String get noItineraryYetTitle;

  /// No description provided for @stepsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps ({count})'**
  String stepsCountLabel(int count);

  /// No description provided for @noInterestPointsPanel.
  ///
  /// In en, this message translates to:
  /// **'No interest points'**
  String get noInterestPointsPanel;

  /// No description provided for @selectDateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDateTooltip;

  /// No description provided for @addInterestPointTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add interest point'**
  String get addInterestPointTooltip;

  /// No description provided for @removeInterestPointTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove interest point'**
  String get removeInterestPointTooltip;

  /// No description provided for @addExperienceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add experience'**
  String get addExperienceTooltip;

  /// No description provided for @chooseStepTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose step type:'**
  String get chooseStepTypeLabel;

  /// No description provided for @placeholderStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Placeholder'**
  String get placeholderStepTitle;

  /// No description provided for @undecidedStepSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Undecided step'**
  String get undecidedStepSubtitle;

  /// No description provided for @stopStepTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopStepTypeTitle;

  /// No description provided for @placeToVisitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place to visit'**
  String get placeToVisitSubtitle;

  /// No description provided for @hostingStepTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hosting'**
  String get hostingStepTypeTitle;

  /// No description provided for @placeToStaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place to stay'**
  String get placeToStaySubtitle;

  /// No description provided for @travelSegmentStepTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Travel Segment'**
  String get travelSegmentStepTypeTitle;

  /// No description provided for @movingAroundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Moving around'**
  String get movingAroundSubtitle;

  /// No description provided for @stepTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Step Title'**
  String get stepTitleLabel;

  /// No description provided for @chooseStepTypeEmptyStateMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a step type to continue editing this itinerary step.'**
  String get chooseStepTypeEmptyStateMessage;

  /// No description provided for @defaultPlaceNameValue.
  ///
  /// In en, this message translates to:
  /// **'Place name'**
  String get defaultPlaceNameValue;

  /// No description provided for @defaultPlaceAddressValue.
  ///
  /// In en, this message translates to:
  /// **'Place address'**
  String get defaultPlaceAddressValue;

  /// No description provided for @defaultStartingPointValue.
  ///
  /// In en, this message translates to:
  /// **'Starting point'**
  String get defaultStartingPointValue;

  /// No description provided for @defaultFinishPointValue.
  ///
  /// In en, this message translates to:
  /// **'Finish point'**
  String get defaultFinishPointValue;

  /// No description provided for @newStepDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'New Step — {index}'**
  String newStepDefaultTitle(int index);

  /// No description provided for @newStepDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'New step description'**
  String get newStepDefaultDescription;

  /// No description provided for @hostingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Hosting Name'**
  String get hostingNameLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @checkInLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkInLabel;

  /// No description provided for @checkOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get checkOutLabel;

  /// No description provided for @fieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Field cannot be empty'**
  String get fieldRequiredError;

  /// No description provided for @stopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop Name'**
  String get stopNameLabel;

  /// No description provided for @addExperienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Experience'**
  String get addExperienceLabel;

  /// No description provided for @startPointLabel.
  ///
  /// In en, this message translates to:
  /// **'Start Point'**
  String get startPointLabel;

  /// No description provided for @finishPointLabel.
  ///
  /// In en, this message translates to:
  /// **'Finish Point'**
  String get finishPointLabel;

  /// No description provided for @transportTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Transport Type'**
  String get transportTypeLabel;

  /// No description provided for @airplaneTransportLabel.
  ///
  /// In en, this message translates to:
  /// **'Airplane'**
  String get airplaneTransportLabel;

  /// No description provided for @busTransportLabel.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get busTransportLabel;

  /// No description provided for @rentalCarTransportLabel.
  ///
  /// In en, this message translates to:
  /// **'Rental Car'**
  String get rentalCarTransportLabel;

  /// No description provided for @travelNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel Number'**
  String get travelNumberLabel;

  /// No description provided for @travelCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Travel Company'**
  String get travelCompanyLabel;

  /// No description provided for @departureGateLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure Gate'**
  String get departureGateLabel;

  /// No description provided for @departureDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure Date'**
  String get departureDateLabel;

  /// No description provided for @busStationLabel.
  ///
  /// In en, this message translates to:
  /// **'Bus Station'**
  String get busStationLabel;

  /// No description provided for @detailsOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Details (Optional)'**
  String get detailsOptionalLabel;

  /// No description provided for @travelNumberRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Travel number is required'**
  String get travelNumberRequiredValidation;

  /// No description provided for @travelCompanyRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Travel company is required'**
  String get travelCompanyRequiredValidation;

  /// No description provided for @departureGateRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Departure gate is required'**
  String get departureGateRequiredValidation;

  /// No description provided for @busStationRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Bus station name is required'**
  String get busStationRequiredValidation;

  /// No description provided for @descriptionRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequiredValidation;

  /// No description provided for @flightNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Flight Number'**
  String get flightNumberLabel;

  /// No description provided for @flightCompanyLabel.
  ///
  /// In en, this message translates to:
  /// **'Flight Company'**
  String get flightCompanyLabel;

  /// No description provided for @flightDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Flight Date'**
  String get flightDateLabel;

  /// No description provided for @departureAirportLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure Airport'**
  String get departureAirportLabel;

  /// No description provided for @arrivalAirportLabel.
  ///
  /// In en, this message translates to:
  /// **'Arrival Airport'**
  String get arrivalAirportLabel;

  /// No description provided for @flightNumberRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Flight number is required'**
  String get flightNumberRequiredValidation;

  /// No description provided for @flightCompanyRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Flight company is required'**
  String get flightCompanyRequiredValidation;

  /// No description provided for @departureAirportRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Departure airport is required'**
  String get departureAirportRequiredValidation;

  /// No description provided for @arrivalAirportRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Arrival airport is required'**
  String get arrivalAirportRequiredValidation;

  /// No description provided for @vehicleModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Model'**
  String get vehicleModelLabel;

  /// No description provided for @licensePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licensePlateLabel;

  /// No description provided for @companyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyNameLabel;

  /// No description provided for @checkInDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Check In Date'**
  String get checkInDateLabel;

  /// No description provided for @checkOutDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Check Out Date'**
  String get checkOutDateLabel;

  /// No description provided for @vehicleModelRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Vehicle model is required'**
  String get vehicleModelRequiredValidation;

  /// No description provided for @licensePlateRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'License plate is required'**
  String get licensePlateRequiredValidation;

  /// No description provided for @companyNameRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Company name is required'**
  String get companyNameRequiredValidation;

  /// No description provided for @checkInAfterCheckOutError.
  ///
  /// In en, this message translates to:
  /// **'Check in cannot be after check out'**
  String get checkInAfterCheckOutError;

  /// No description provided for @checkOutBeforeCheckInError.
  ///
  /// In en, this message translates to:
  /// **'Check out cannot be before check in'**
  String get checkOutBeforeCheckInError;

  /// No description provided for @deleteStepTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete step'**
  String get deleteStepTooltip;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get sessionExpiredMessage;
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
