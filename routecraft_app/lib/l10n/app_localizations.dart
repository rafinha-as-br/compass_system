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
  /// **'RouteCraft'**
  String get appTitle;

  /// No description provided for @appBrandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compass System'**
  String get appBrandSubtitle;

  /// No description provided for @splashCheckingSession.
  ///
  /// In en, this message translates to:
  /// **'Checking session…'**
  String get splashCheckingSession;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
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
  /// **'Access denied. Only Clients can access RouteCraft.'**
  String get loginAccessDenied;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login.'**
  String get loginError;

  /// No description provided for @loginNoAccountFooter.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Talk to your agent'**
  String get loginNoAccountFooter;

  /// No description provided for @loginShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get loginHidePassword;

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

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'RouteCraft Home'**
  String get homeTitle;

  /// No description provided for @createRouteNav.
  ///
  /// In en, this message translates to:
  /// **'Create a Route'**
  String get createRouteNav;

  /// No description provided for @visualizeRoutesNav.
  ///
  /// In en, this message translates to:
  /// **'Visualize Routes & Itineraries'**
  String get visualizeRoutesNav;

  /// No description provided for @accountSettingsNav.
  ///
  /// In en, this message translates to:
  /// **'User Account & Settings'**
  String get accountSettingsNav;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeSectionInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get homeSectionInProgress;

  /// No description provided for @homeSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get homeSectionUpcoming;

  /// No description provided for @homeSectionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get homeSectionCompleted;

  /// No description provided for @homeEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Describe the trip you want to take and your agent will build the itinerary.'**
  String get homeEmptyMessage;

  /// No description provided for @homeEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Create my first route'**
  String get homeEmptyCta;

  /// No description provided for @homeNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavLabel;

  /// No description provided for @itineraryNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get itineraryNavLabel;

  /// No description provided for @accountNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountNavLabel;

  /// No description provided for @createRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a Route'**
  String get createRouteTitle;

  /// No description provided for @tripInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Trip Info'**
  String get tripInfoStep;

  /// No description provided for @tripNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip Name'**
  String get tripNameLabel;

  /// No description provided for @locationsStep.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get locationsStep;

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

  /// No description provided for @interestsStep.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interestsStep;

  /// No description provided for @submitRoute.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT ROUTE'**
  String get submitRoute;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get nextButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get backButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @routeCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Route created successfully!'**
  String get routeCreatedSuccess;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @failedToCreateRoute.
  ///
  /// In en, this message translates to:
  /// **'Failed to create route: {error}'**
  String failedToCreateRoute(String error);

  /// No description provided for @successTitle.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successTitle;

  /// No description provided for @routeCreationStepIndicator.
  ///
  /// In en, this message translates to:
  /// **'STEP {step} OF {total}'**
  String routeCreationStepIndicator(int step, int total);

  /// No description provided for @routeCreationNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call this trip?'**
  String get routeCreationNameTitle;

  /// No description provided for @routeCreationDatesTitle.
  ///
  /// In en, this message translates to:
  /// **'When do you want to travel?'**
  String get routeCreationDatesTitle;

  /// No description provided for @routeCreationDatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dates can change later.'**
  String get routeCreationDatesSubtitle;

  /// No description provided for @routeCreationStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get routeCreationStartDateLabel;

  /// No description provided for @routeCreationEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get routeCreationEndDateLabel;

  /// No description provided for @routeCreationNightsCount.
  ///
  /// In en, this message translates to:
  /// **'{nights} nights'**
  String routeCreationNightsCount(int nights);

  /// No description provided for @routeCreationDatesCoherent.
  ///
  /// In en, this message translates to:
  /// **'consistent dates'**
  String get routeCreationDatesCoherent;

  /// No description provided for @routeCreationDatesIncoherent.
  ///
  /// In en, this message translates to:
  /// **'Return must be after departure.'**
  String get routeCreationDatesIncoherent;

  /// No description provided for @routeCreationWeekendShortcut.
  ///
  /// In en, this message translates to:
  /// **'weekend'**
  String get routeCreationWeekendShortcut;

  /// No description provided for @routeCreationWeekShortcut.
  ///
  /// In en, this message translates to:
  /// **'1 week'**
  String get routeCreationWeekShortcut;

  /// No description provided for @routeCreationFlexibleShortcut.
  ///
  /// In en, this message translates to:
  /// **'still flexible'**
  String get routeCreationFlexibleShortcut;

  /// No description provided for @routeCreationLocationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you headed?'**
  String get routeCreationLocationsTitle;

  /// No description provided for @routeCreationInterestsTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to experience there?'**
  String get routeCreationInterestsTitle;

  /// No description provided for @routeCreationInterestNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get routeCreationInterestNameLabel;

  /// No description provided for @routeCreationInterestDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get routeCreationInterestDescriptionLabel;

  /// No description provided for @routeCreationAddInterestButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get routeCreationAddInterestButton;

  /// No description provided for @routeCreationReviewHeader.
  ///
  /// In en, this message translates to:
  /// **'REVIEW'**
  String get routeCreationReviewHeader;

  /// No description provided for @routeCreationReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your route'**
  String get routeCreationReviewTitle;

  /// No description provided for @routeCreationNameBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get routeCreationNameBlockLabel;

  /// No description provided for @routeCreationInterestsBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} INTERESTS'**
  String routeCreationInterestsBlockLabel(int count);

  /// No description provided for @routeCreationSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Send to my agent'**
  String get routeCreationSubmitCta;

  /// No description provided for @visualizationTitle.
  ///
  /// In en, this message translates to:
  /// **'My Travels'**
  String get visualizationTitle;

  /// No description provided for @noTravelsYet.
  ///
  /// In en, this message translates to:
  /// **'No travels yet.'**
  String get noTravelsYet;

  /// No description provided for @itineraryLabel.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get itineraryLabel;

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String stepsCount(int count);

  /// No description provided for @noItinerary.
  ///
  /// In en, this message translates to:
  /// **'No itinerary'**
  String get noItinerary;

  /// No description provided for @routeLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeLabel;

  /// No description provided for @hubTitle.
  ///
  /// In en, this message translates to:
  /// **'MY TRIP'**
  String get hubTitle;

  /// No description provided for @hubAwaitingAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Your agent is preparing your itinerary'**
  String get hubAwaitingAgentTitle;

  /// No description provided for @hubWhatYouAskedLabel.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU ASKED FOR'**
  String get hubWhatYouAskedLabel;

  /// No description provided for @hubEditRouteLink.
  ///
  /// In en, this message translates to:
  /// **'edit route'**
  String get hubEditRouteLink;

  /// No description provided for @hubInterestsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 interest} other{{count} interests}}'**
  String hubInterestsCount(int count);

  /// No description provided for @hubNextStepLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT STEP'**
  String get hubNextStepLabel;

  /// No description provided for @hubInDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, one{in 1 day} other{in {days} days}}'**
  String hubInDaysCount(int days);

  /// No description provided for @hubToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get hubToday;

  /// No description provided for @hubViewDetailsLink.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get hubViewDetailsLink;

  /// No description provided for @hubStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'STEPS'**
  String get hubStepsLabel;

  /// No description provided for @hubNightsLabel.
  ///
  /// In en, this message translates to:
  /// **'NIGHTS'**
  String get hubNightsLabel;

  /// No description provided for @hubRouteSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'ROUTE SUMMARY'**
  String get hubRouteSummaryLabel;

  /// No description provided for @hubOpenFullItineraryButton.
  ///
  /// In en, this message translates to:
  /// **'Open full itinerary'**
  String get hubOpenFullItineraryButton;

  /// No description provided for @hubComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get hubComingSoon;

  /// No description provided for @hubEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No trip selected'**
  String get hubEmptyTitle;

  /// No description provided for @hubEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Select a trip from Home to see its itinerary.'**
  String get hubEmptyMessage;

  /// No description provided for @hubGoToHomeCta.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get hubGoToHomeCta;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationItineraryPublished.
  ///
  /// In en, this message translates to:
  /// **'Your itinerary for {travelName} was published'**
  String notificationItineraryPublished(String travelName);

  /// No description provided for @notificationItineraryChanged.
  ///
  /// In en, this message translates to:
  /// **'The itinerary for {travelName} was changed'**
  String notificationItineraryChanged(String travelName);

  /// No description provided for @notificationRouteReceived.
  ///
  /// In en, this message translates to:
  /// **'Route for {travelName} received'**
  String notificationRouteReceived(String travelName);

  /// No description provided for @notificationViewTripLink.
  ///
  /// In en, this message translates to:
  /// **'View trip'**
  String get notificationViewTripLink;

  /// No description provided for @notificationOpenTripError.
  ///
  /// In en, this message translates to:
  /// **'Could not open this trip.'**
  String get notificationOpenTripError;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'My Account'**
  String get accountTitle;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'LOGOUT'**
  String get logoutButton;

  /// No description provided for @notAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated.'**
  String get notAuthenticated;

  /// No description provided for @accountAgentBlockLabel.
  ///
  /// In en, this message translates to:
  /// **'MY AGENT'**
  String get accountAgentBlockLabel;

  /// No description provided for @accountPersonalDataMenu.
  ///
  /// In en, this message translates to:
  /// **'Personal data'**
  String get accountPersonalDataMenu;

  /// No description provided for @accountNotificationsMenu.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accountNotificationsMenu;

  /// No description provided for @accountHelpMenu.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get accountHelpMenu;

  /// No description provided for @accountDarkModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get accountDarkModeLabel;

  /// No description provided for @accountLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language ({code})'**
  String accountLanguageLabel(String code);

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get comingSoonMessage;

  /// No description provided for @travelStatusRouteCreated.
  ///
  /// In en, this message translates to:
  /// **'Awaiting agent'**
  String get travelStatusRouteCreated;

  /// No description provided for @travelStatusItineraryCreated.
  ///
  /// In en, this message translates to:
  /// **'Itinerary published'**
  String get travelStatusItineraryCreated;

  /// No description provided for @travelStatusTravelStarted.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get travelStatusTravelStarted;

  /// No description provided for @travelStatusTravelFinished.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get travelStatusTravelFinished;
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
