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
  String get appBrandSubtitle => 'Compass System';

  @override
  String get splashCheckingSession => 'Checking session…';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'you@email.com';

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
  String get loginNoAccountFooter =>
      'Don\'t have an account? Talk to your agent';

  @override
  String get loginShowPassword => 'Show password';

  @override
  String get loginHidePassword => 'Hide password';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a code to reset your password.';

  @override
  String get forgotPasswordSubmitButton => 'SEND CODE';

  @override
  String get forgotPasswordConfirmation =>
      'If this email is registered, you will receive a code to reset your password.';

  @override
  String get resetPasswordTitle => 'Enter your code';

  @override
  String get resetPasswordSubtitle =>
      'Enter the code you received by email and choose a new password.';

  @override
  String get resetPasswordTokenLabel => 'Code';

  @override
  String get resetPasswordTokenRequired => 'Enter the code';

  @override
  String get resetPasswordNewPasswordLabel => 'New password';

  @override
  String get resetPasswordNewPasswordRequired => 'Enter a new password';

  @override
  String get resetPasswordSubmitButton => 'RESET PASSWORD';

  @override
  String get resetPasswordSuccess =>
      'Password reset successfully. You can now log in.';

  @override
  String get homeTitle => 'RouteCraft Home';

  @override
  String get createRouteNav => 'Create a Route';

  @override
  String get visualizeRoutesNav => 'Visualize Routes & Itineraries';

  @override
  String get accountSettingsNav => 'User Account & Settings';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeSectionInProgress => 'In progress';

  @override
  String get homeSectionUpcoming => 'Upcoming';

  @override
  String get homeSectionCompleted => 'Completed';

  @override
  String get homeEmptyMessage =>
      'Describe the trip you want to take and your agent will build the itinerary.';

  @override
  String get homeEmptyCta => 'Create my first route';

  @override
  String get networkErrorTitle => 'Couldn\'t load this';

  @override
  String get networkErrorMessage => 'Check your connection and try again.';

  @override
  String get networkErrorRetryCta => 'Try again';

  @override
  String offlineBannerLabel(String date) {
    return 'Offline · data from $date';
  }

  @override
  String get homeNavLabel => 'Home';

  @override
  String get itineraryNavLabel => 'Itinerary';

  @override
  String get accountNavLabel => 'Account';

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
  String get editButton => 'Edit';

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
  String routeCreationStepIndicator(int step, int total) {
    return 'STEP $step OF $total';
  }

  @override
  String get routeCreationNameTitle => 'What should we call this trip?';

  @override
  String get routeCreationDatesTitle => 'When do you want to travel?';

  @override
  String get routeCreationDatesSubtitle => 'Dates can change later.';

  @override
  String get routeCreationStartDateLabel => 'Departure';

  @override
  String get routeCreationEndDateLabel => 'Return';

  @override
  String routeCreationNightsCount(int nights) {
    return '$nights nights';
  }

  @override
  String get routeCreationDatesCoherent => 'consistent dates';

  @override
  String get routeCreationDatesIncoherent => 'Return must be after departure.';

  @override
  String get routeCreationWeekendShortcut => 'weekend';

  @override
  String get routeCreationWeekShortcut => '1 week';

  @override
  String get routeCreationFlexibleShortcut => 'still flexible';

  @override
  String get routeCreationLocationsTitle => 'Where are you headed?';

  @override
  String get routeCreationInterestsTitle =>
      'What do you want to experience there?';

  @override
  String get routeCreationInterestNameLabel => 'Interest';

  @override
  String get routeCreationInterestDescriptionLabel => 'Description (optional)';

  @override
  String get routeCreationAddInterestButton => 'Add';

  @override
  String get routeCreationReviewHeader => 'REVIEW';

  @override
  String get routeCreationReviewTitle => 'Confirm your route';

  @override
  String get routeCreationNameBlockLabel => 'NAME';

  @override
  String routeCreationInterestsBlockLabel(int count) {
    return '$count INTERESTS';
  }

  @override
  String get routeCreationSubmitCta => 'Send to my agent';

  @override
  String get visualizationTitle => 'My Travels';

  @override
  String get noTravelsYet => 'No travels yet.';

  @override
  String get itineraryLabel => 'Itinerary';

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get noItinerary => 'No itinerary';

  @override
  String get routeLabel => 'Route';

  @override
  String get hubTitle => 'MY TRIP';

  @override
  String get hubAwaitingAgentTitle => 'Your agent is preparing your itinerary';

  @override
  String get hubWhatYouAskedLabel => 'WHAT YOU ASKED FOR';

  @override
  String get hubEditRouteLink => 'edit route';

  @override
  String hubInterestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count interests',
      one: '1 interest',
    );
    return '$_temp0';
  }

  @override
  String get hubNextStepLabel => 'NEXT STEP';

  @override
  String hubInDaysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'in $days days',
      one: 'in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get hubToday => 'today';

  @override
  String get hubViewDetailsLink => 'View details';

  @override
  String get hubStepsLabel => 'STEPS';

  @override
  String get hubNightsLabel => 'NIGHTS';

  @override
  String get hubRouteSummaryLabel => 'ROUTE SUMMARY';

  @override
  String get hubOpenFullItineraryButton => 'Open full itinerary';

  @override
  String get hubComingSoon => 'Coming soon.';

  @override
  String get hubEmptyTitle => 'No trip selected';

  @override
  String get hubEmptyMessage => 'Select a trip from Home to see its itinerary.';

  @override
  String get hubGoToHomeCta => 'Go to Home';

  @override
  String todayDayProgress(int day, int total) {
    return 'Day $day of $total';
  }

  @override
  String get todayInProgressLabel => 'Trip in progress';

  @override
  String todayStartsIn(String duration) {
    return 'Starts in $duration';
  }

  @override
  String get todayHappeningNow => 'Happening now';

  @override
  String get todayAddressLabel => 'Address';

  @override
  String get todayViewStepCta => 'View step';

  @override
  String get todayAfterThatLabel => 'AFTER THAT';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'mark all read';

  @override
  String get notificationsEmptyMessage => 'No notifications yet.';

  @override
  String notificationItineraryPublished(String travelName) {
    return 'Your itinerary for $travelName was published';
  }

  @override
  String notificationItineraryChanged(String travelName) {
    return 'The itinerary for $travelName was changed';
  }

  @override
  String notificationRouteReceived(String travelName) {
    return 'Route for $travelName received';
  }

  @override
  String get notificationViewTripLink => 'View trip';

  @override
  String get notificationOpenTripError => 'Could not open this trip.';

  @override
  String get editRouteTitle => 'Edit my route';

  @override
  String get editRouteSaveButton => 'SAVE';

  @override
  String get editRoutePublishedWarning =>
      'Your itinerary has already been built. Changing the route won\'t change its steps — your agent will be notified to review it.';

  @override
  String get editRouteChangedLabel => 'changed';

  @override
  String get editRouteUndoLink => 'undo';

  @override
  String get editRouteRemoveInterestTooltip => 'Remove';

  @override
  String editRoutePendingChangesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count PENDING CHANGES',
      one: '1 PENDING CHANGE',
    );
    return '$_temp0';
  }

  @override
  String editRouteDiffDeparture(String oldDate, String newDate) {
    return 'departure $oldDate → $newDate';
  }

  @override
  String editRouteDiffReturn(String oldDate, String newDate) {
    return 'return $oldDate → $newDate';
  }

  @override
  String editRouteDiffOrigin(String oldValue, String newValue) {
    return 'origin $oldValue → $newValue';
  }

  @override
  String editRouteDiffDestination(String oldValue, String newValue) {
    return 'destination $oldValue → $newValue';
  }

  @override
  String editRouteDiffInterestsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count interests added',
      one: '1 interest added',
    );
    return '$_temp0';
  }

  @override
  String editRouteDiffInterestsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count interests removed',
      one: '1 interest removed',
    );
    return '$_temp0';
  }

  @override
  String get editRouteSubmitCta => 'Send changes';

  @override
  String editRouteSubmitError(String error) {
    return 'Failed to update route: $error';
  }

  @override
  String get editRouteUpdateSuccess => 'Route updated successfully!';

  @override
  String timelineDayLabel(int dayNumber) {
    return 'Day $dayNumber';
  }

  @override
  String get timelineNoStepsForDay => 'No steps this day';

  @override
  String timelineFreeTimeUntil(String until) {
    return 'Free time · no step until $until';
  }

  @override
  String get timelineTomorrow => 'tomorrow';

  @override
  String get timelinePreviousDay => 'Previous day';

  @override
  String get timelineNextDay => 'Next day';

  @override
  String get timelineRentalCarLabel => 'Rental car';

  @override
  String get stepDetailTypeStop => 'Stop';

  @override
  String get stepDetailTypeHosting => 'Hosting';

  @override
  String get stepDetailTypeTravelSegment => 'Travel segment';

  @override
  String get stepDetailTypePlaceholder => 'Placeholder';

  @override
  String get stepDetailSubtypeAirplane => 'Airplane';

  @override
  String get stepDetailSubtypeBus => 'Bus';

  @override
  String get stepDetailName => 'Name';

  @override
  String get stepDetailDescription => 'Description';

  @override
  String get stepDetailExperiences => 'Experiences';

  @override
  String get stepDetailAddress => 'Address';

  @override
  String get stepDetailCheckIn => 'Check-in';

  @override
  String get stepDetailCheckOut => 'Check-out';

  @override
  String get stepDetailOrigin => 'Origin';

  @override
  String get stepDetailDestination => 'Destination';

  @override
  String get stepDetailFlight => 'Flight';

  @override
  String get stepDetailDate => 'Date';

  @override
  String get stepDetailGate => 'Gate';

  @override
  String get stepDetailAirports => 'Airports';

  @override
  String get stepDetailBusLine => 'Bus';

  @override
  String get stepDetailBusStation => 'Bus station';

  @override
  String get stepDetailDepartureTime => 'Departure';

  @override
  String get stepDetailModel => 'Model';

  @override
  String get stepDetailLicensePlate => 'License plate';

  @override
  String get stepDetailRentalCompany => 'Rental company';

  @override
  String get stepDetailPickUp => 'Pick-up';

  @override
  String get stepDetailDropOff => 'Drop-off';

  @override
  String get accountTitle => 'My Account';

  @override
  String get logoutButton => 'LOGOUT';

  @override
  String get notAuthenticated => 'Not authenticated.';

  @override
  String get accountAgentBlockLabel => 'MY AGENT';

  @override
  String get accountPersonalDataMenu => 'Personal data';

  @override
  String get accountNotificationsMenu => 'Notifications';

  @override
  String get accountHelpMenu => 'Help';

  @override
  String get accountDarkModeLabel => 'Dark Mode';

  @override
  String accountLanguageLabel(String code) {
    return 'Language ($code)';
  }

  @override
  String get comingSoonMessage => 'Coming soon.';

  @override
  String get travelStatusRouteCreated => 'Awaiting agent';

  @override
  String get travelStatusItineraryCreated => 'Itinerary published';

  @override
  String get travelStatusTravelStarted => 'In progress';

  @override
  String get travelStatusTravelFinished => 'Completed';
}
