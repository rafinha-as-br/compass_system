// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Travel Matrix';

  @override
  String get loginTitle => 'Welcome to Travel Matrix';

  @override
  String get loginSubtitle => 'Please login to continue';

  @override
  String get loginLabel => 'Access Travel Matrix';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginTitlePanel => 'Agent Login';

  @override
  String get loginSubtitlePanel => 'Please authenticate to continue';

  @override
  String get loginButton => 'LOGIN AS AGENT';

  @override
  String get loginEmailRequired => 'Enter email';

  @override
  String get loginPasswordRequired => 'Enter password';

  @override
  String get loginAccessDenied =>
      'Access denied. Only Travel Agents can access Travel Matrix.';

  @override
  String get loginError => 'An error occurred during login.';

  @override
  String get dashboardTitle => 'Dashboard Overview';

  @override
  String get totalTravels => 'Total Travels';

  @override
  String get itinerariesCompleted => 'Itineraries Completed';

  @override
  String get pendingItineraries => 'Pending Itineraries';

  @override
  String get activeClients => 'Active Clients';

  @override
  String get recentTravelUpdates => 'Recent Travel Updates';

  @override
  String get noTravelsCreated => 'No travels created yet.';

  @override
  String get failedToLoadDashboard =>
      'Unable to load your dashboard right now. Please try again later.';

  @override
  String get statusComplete => 'COMPLETE';

  @override
  String get statusPending => 'PENDING';

  @override
  String get allTravels => 'All Travels';

  @override
  String get createTravel => 'Create Travel';

  @override
  String get itineraryReady => 'Itinerary Ready';

  @override
  String get routeOnly => 'Route Only';

  @override
  String get travelInProgress => 'In Progress';

  @override
  String get travelCompleted => 'Completed';

  @override
  String get clientLabel => 'Client';

  @override
  String get createTravelTitle => 'Create Travel';

  @override
  String get stepCreateRoute => 'Step 1: Create Route';

  @override
  String get stepCreateRouteHint =>
      'Define the route first. An itinerary can be created after.';

  @override
  String get travelNameLabel => 'Travel Name';

  @override
  String get travelNameRequired => 'Travel name is required';

  @override
  String get startLocationLabel => 'Start Location';

  @override
  String get destinationLabel => 'Destination';

  @override
  String get requiredField => 'Required';

  @override
  String get startDateLabel => 'Start Date';

  @override
  String get endDateLabel => 'End Date';

  @override
  String get interestPointsTitle => 'Interest Points';

  @override
  String get pointNameLabel => 'Point Name';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get createItineraryTitle => 'Create Itinerary';

  @override
  String get editItineraryTitle => 'Edit Itinerary';

  @override
  String get saveButton => 'Save';

  @override
  String get updateButton => 'Update';

  @override
  String get createButton => 'Create';

  @override
  String get finishItinerary => 'Finish Itinerary';

  @override
  String get deleteStep => 'Delete Step';

  @override
  String get deleteStepConfirm => 'Are you sure you want to delete this step?';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get addStep => 'Add Step';

  @override
  String get addFirstStepHint =>
      'Add your first step to begin building the itinerary.';

  @override
  String get previousStep => 'Previous Step';

  @override
  String get nextStep => 'Next Step';

  @override
  String get itinerarySavedSuccess => 'Itinerary saved.';

  @override
  String get itineraryFinishedSuccess => 'Itinerary finished successfully!';

  @override
  String get failedToCreateItinerary => 'Failed to create itinerary.';

  @override
  String get routeDetails => 'Route Details';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String interestPointsCount(int count) {
    return 'Interest Points ($count)';
  }

  @override
  String get noInterestPoints => 'No interest points defined.';

  @override
  String get noItineraryCreated => 'No itinerary has been created yet.';

  @override
  String get notAuthenticated => 'Not authenticated.';

  @override
  String failedToFetchTravels(String error) {
    return 'Failed to fetch travels: $error';
  }

  @override
  String failedToFetchUsers(String error) {
    return 'Failed to fetch users: $error';
  }

  @override
  String get usersTitle => 'Users';

  @override
  String get createUser => 'Create User';

  @override
  String get editUser => 'Edit User';

  @override
  String get viewUser => 'View User';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get deleteUserConfirm => 'Are you sure you want to delete this user?';

  @override
  String get agentSettings => 'Agent Settings';

  @override
  String get systemPreferences => 'System Preferences';

  @override
  String get adminDarkMode => 'Admin Dark Mode';

  @override
  String get logOutOfMatrix => 'Log Out of Matrix';

  @override
  String get languageLabel => 'Language';

  @override
  String dashboardWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String dashboardWelcomeSubtitle(int pending, int completed) {
    return 'Your desk is ready with $pending pending itineraries and $completed completed itinerary records.';
  }

  @override
  String get recentTravels => 'Recent Travels';

  @override
  String get activeClientsListTitle => 'Active Clients';

  @override
  String get travelNameColumn => 'Travel Name';

  @override
  String get clientNameColumn => 'Name';

  @override
  String get routeColumn => 'Route';

  @override
  String get statusColumn => 'Status';

  @override
  String get datesColumn => 'Dates';

  @override
  String get actionsColumn => 'Actions';

  @override
  String get viewTravel => 'View Travel';

  @override
  String get searchTravelsHint => 'Search travels...';

  @override
  String get allStatus => 'All Status';

  @override
  String get profileSection => 'Profile';

  @override
  String get cpfLabel => 'CPF';

  @override
  String get cnpjLabel => 'CNPJ';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get editAgentData => 'Edit Agent Data';

  @override
  String get changePassword => 'Change Password';

  @override
  String get failedToLoadProfile =>
      'Unable to load your profile right now. Please try again later.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get digitalConcierge => 'THE DIGITAL CONCIERGE';

  @override
  String get dashboardNav => 'Dashboard';

  @override
  String get bookingNav => 'Booking';

  @override
  String get settingsNav => 'Settings';

  @override
  String get supportNav => 'Support';

  @override
  String get logoutNav => 'Logout';

  @override
  String get travelAgentRole => 'Travel Agent';

  @override
  String get clientUsersTitle => 'Client Users';

  @override
  String get searchUsersHint => 'Search users...';

  @override
  String get activeStatusLabel => 'Active';

  @override
  String get inactiveStatusLabel => 'Inactive';

  @override
  String get noClientUsersFoundMessage => 'No client users found.';

  @override
  String get backToUsersButton => 'Back to Users';

  @override
  String get maleGenderLabel => 'Male';

  @override
  String get femaleGenderLabel => 'Female';

  @override
  String get otherOptionLabel => 'Other';

  @override
  String get travelHistoryTitle => 'Travel History';

  @override
  String get noTravelsForUserMessage => 'No travels found for this user.';

  @override
  String get securityActionsTitle => 'Security Actions';

  @override
  String get resetPasswordActionTitle => 'Reset Password';

  @override
  String get resetPasswordActionDescription =>
      'Send a link to the user\'s email to securely reset their password.';

  @override
  String get forceLogoutActionTitle => 'Force Logout';

  @override
  String get forceLogoutActionDescription =>
      'Immediately terminate all active sessions for this user.';

  @override
  String get resetPasswordSuccessMessage => 'Password reset link sent';

  @override
  String get resetPasswordFailureMessage => 'Failed to send reset link';

  @override
  String get forceLogoutSuccessMessage => 'User sessions terminated';

  @override
  String get forceLogoutFailureMessage => 'Failed to terminate sessions';

  @override
  String get travelStatsTitle => 'Travel Stats';

  @override
  String get uniqueDestinationsStatLabel => 'UNIQUE DESTINATIONS';

  @override
  String get forceLogoutConfirmTitle => 'Force Logout?';

  @override
  String get forceLogoutConfirmMessage =>
      'This will immediately terminate all active sessions for this user. Continue?';

  @override
  String get confirmActionButton => 'CONFIRM';

  @override
  String get cancelActionButton => 'CANCEL';

  @override
  String get newClientUserFormTitle => 'New Client User';

  @override
  String get fullNameFieldLabel => 'Full Name';

  @override
  String get nameRequiredValidation => 'Name is required';

  @override
  String get cpfRequiredValidation => 'CPF is required';

  @override
  String get emailRequiredValidation => 'Email is required';

  @override
  String get phoneNumberFieldLabel => 'Phone Number';

  @override
  String get phoneRequiredValidation => 'Phone is required';

  @override
  String get initialPasswordFieldLabel => 'Initial Password';

  @override
  String get passwordRequiredValidation => 'Password is required';

  @override
  String get sexFieldLabel => 'Sex';

  @override
  String get birthDateFieldLabel => 'Birth Date';

  @override
  String get createUserSubmitButton => 'CREATE USER';

  @override
  String editUserPageSubtitle(String name) {
    return 'Edit: $name';
  }

  @override
  String get saveChangesButton => 'SAVE CHANGES';

  @override
  String get deactivateUserDialogTitle => 'Deactivate User';

  @override
  String deactivateReasonPrompt(String name) {
    return 'Why are you deactivating $name?';
  }

  @override
  String get deactivateReasonClientRequest => 'Client request';

  @override
  String get deactivateReasonNonPayment => 'Non-payment';

  @override
  String get deactivateReasonTermsViolation => 'Terms of service violation';

  @override
  String get deactivateReasonDuplicateAccount => 'Duplicate account';

  @override
  String get specifyReasonFieldLabel => 'Specify the reason';

  @override
  String get deactivateButtonCaps => 'DEACTIVATE';

  @override
  String get userNotFoundTitle => 'User Not Found';

  @override
  String get userNotFoundMessage => 'The requested user could not be found.';
}
