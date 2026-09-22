import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('mr')
  ];

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT SETTINGS'**
  String get profileAccountSettings;

  /// No description provided for @profileManageDevices.
  ///
  /// In en, this message translates to:
  /// **'Manage Devices'**
  String get profileManageDevices;

  /// No description provided for @profileSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get profileSelectLanguage;

  /// No description provided for @profileNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get profileNotificationSettings;

  /// No description provided for @profilePrivacyCenter.
  ///
  /// In en, this message translates to:
  /// **'Privacy Center'**
  String get profilePrivacyCenter;

  /// No description provided for @profileMyActivity.
  ///
  /// In en, this message translates to:
  /// **'MY ACTIVITY'**
  String get profileMyActivity;

  /// No description provided for @profileReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get profileReviews;

  /// No description provided for @profileMyEnquiries.
  ///
  /// In en, this message translates to:
  /// **'My Enquiries'**
  String get profileMyEnquiries;

  /// No description provided for @profileSellProperties.
  ///
  /// In en, this message translates to:
  /// **'SELL PROPERTIES'**
  String get profileSellProperties;

  /// No description provided for @profileBecomeSeller.
  ///
  /// In en, this message translates to:
  /// **'Become a Seller'**
  String get profileBecomeSeller;

  /// No description provided for @profileSupportInfo.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT & INFORMATION'**
  String get profileSupportInfo;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get profileTermsConditions;

  /// No description provided for @profileRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'RECENTLY VIEWED'**
  String get profileRecentlyViewed;

  /// No description provided for @profileViewedToday.
  ///
  /// In en, this message translates to:
  /// **'You viewed 3 projects today'**
  String get profileViewedToday;

  /// No description provided for @profileFollowUs.
  ///
  /// In en, this message translates to:
  /// **'FOLLOW US ON'**
  String get profileFollowUs;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileLogoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogoutConfirmTitle;

  /// No description provided for @profileLogoutConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get profileLogoutConfirmDesc;

  /// No description provided for @profileYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get profileYes;

  /// No description provided for @profileNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get profileNo;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get profileNoEmail;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageTitle;

  /// No description provided for @languageHeading.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageHeading;

  /// No description provided for @languageSubheading.
  ///
  /// In en, this message translates to:
  /// **'Select the language you want to use throughout the MECO Real Estate app.'**
  String get languageSubheading;

  /// No description provided for @languageApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Language'**
  String get languageApply;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageEnSub.
  ///
  /// In en, this message translates to:
  /// **'Default language'**
  String get languageEnSub;

  /// No description provided for @languageHi.
  ///
  /// In en, this message translates to:
  /// **'Hindi (हिन्दी)'**
  String get languageHi;

  /// No description provided for @languageHiSub.
  ///
  /// In en, this message translates to:
  /// **'National regional language'**
  String get languageHiSub;

  /// No description provided for @languageBn.
  ///
  /// In en, this message translates to:
  /// **'Bengali (বাংলা)'**
  String get languageBn;

  /// No description provided for @languageBnSub.
  ///
  /// In en, this message translates to:
  /// **'Regional language support'**
  String get languageBnSub;

  /// No description provided for @languageMr.
  ///
  /// In en, this message translates to:
  /// **'Marathi (मराठी)'**
  String get languageMr;

  /// No description provided for @languageMrSub.
  ///
  /// In en, this message translates to:
  /// **'Regional language support'**
  String get languageMrSub;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Discover Your Next Property'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Desc.
  ///
  /// In en, this message translates to:
  /// **'Explore verified properties across locations, budgets and property types—all in one place.'**
  String get onboardingPage1Desc;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Compare Before You Decide'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Desc.
  ///
  /// In en, this message translates to:
  /// **'Compare properties, prices, amenities and key details to make a confident decision.'**
  String get onboardingPage2Desc;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Connect. Visit. Decide.'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Desc.
  ///
  /// In en, this message translates to:
  /// **'Contact sellers and agents, schedule property visits and move closer to your next property.'**
  String get onboardingPage3Desc;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginLogInAccount.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get loginLogInAccount;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or Phone Number'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or phone number'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginLoginBtn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginLoginBtn;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email / Mobile Number doesn\'t exist'**
  String get loginInvalidCredentials;

  /// No description provided for @loginLoginError.
  ///
  /// In en, this message translates to:
  /// **'invalid login credentials'**
  String get loginLoginError;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get loginOrContinueWith;

  /// No description provided for @loginGoogleBtn.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get loginGoogleBtn;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUp;

  /// No description provided for @loginPleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number'**
  String get loginPleaseEnterEmail;

  /// No description provided for @loginPleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginPleaseEnterPassword;

  /// No description provided for @loginGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get loginGoogleFailed;

  /// No description provided for @loginNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get loginNoInternet;

  /// No description provided for @loginGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured yet.'**
  String get loginGoogleNotConfigured;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get loginRememberMe;

  /// No description provided for @loginDoItLater.
  ///
  /// In en, this message translates to:
  /// **'Do it Later'**
  String get loginDoItLater;

  /// No description provided for @loginAppleId.
  ///
  /// In en, this message translates to:
  /// **'Apple ID'**
  String get loginAppleId;

  /// No description provided for @loginEmailValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number.'**
  String get loginEmailValidation;

  /// No description provided for @loginMobileValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number.'**
  String get loginMobileValidation;

  /// No description provided for @loginValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get loginValidEmail;

  /// No description provided for @loginIncorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get loginIncorrectPassword;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpTitle;

  /// No description provided for @otpDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to'**
  String get otpDesc;

  /// No description provided for @otpVerifyBtn.
  ///
  /// In en, this message translates to:
  /// **'Verify & Proceed'**
  String get otpVerifyBtn;

  /// No description provided for @otpDidntReceive.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive code?'**
  String get otpDidntReceive;

  /// No description provided for @otpResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get otpResendOtp;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get otpResendIn;

  /// No description provided for @otpSec.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get otpSec;

  /// No description provided for @otpInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Please try again.'**
  String get otpInvalidOtp;

  /// No description provided for @otpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Phone verified successfully!'**
  String get otpSuccess;

  /// No description provided for @otpPleaseEnter6Digits.
  ///
  /// In en, this message translates to:
  /// **'Please enter all 6 digits.'**
  String get otpPleaseEnter6Digits;

  /// No description provided for @otpVerifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify with Email'**
  String get otpVerifyEmail;

  /// No description provided for @otpVerifyNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get otpVerifyNumber;

  /// No description provided for @otpEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get otpEnterOtp;

  /// No description provided for @otpOtpSentMail.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to mail'**
  String get otpOtpSentMail;

  /// No description provided for @otpWeSentCodeTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to '**
  String get otpWeSentCodeTo;

  /// No description provided for @otpResendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in '**
  String get otpResendCodeIn;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get otpResend;

  /// No description provided for @homeNavHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavHome;

  /// No description provided for @homeNavVisits.
  ///
  /// In en, this message translates to:
  /// **'My Visits'**
  String get homeNavVisits;

  /// No description provided for @homeNavWishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get homeNavWishlist;

  /// No description provided for @homeNavAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get homeNavAccount;

  /// No description provided for @homeLeaveAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave App?'**
  String get homeLeaveAppTitle;

  /// No description provided for @homeLeaveAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to leave the app?'**
  String get homeLeaveAppDesc;

  /// No description provided for @homeYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get homeYes;

  /// No description provided for @homeNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get homeNo;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search properties, projects, localities...'**
  String get homeSearchHint;

  /// No description provided for @homeExploreCategory.
  ///
  /// In en, this message translates to:
  /// **'Explore by Category'**
  String get homeExploreCategory;

  /// No description provided for @homePromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your dream property today'**
  String get homePromoTitle;

  /// No description provided for @homePromoDesc.
  ///
  /// In en, this message translates to:
  /// **'Over 15,000+ verified listings across top cities with expert consultancy.'**
  String get homePromoDesc;

  /// No description provided for @homeStartSearching.
  ///
  /// In en, this message translates to:
  /// **'Start Searching'**
  String get homeStartSearching;

  /// No description provided for @homeFeatComm.
  ///
  /// In en, this message translates to:
  /// **'Featured Commercial'**
  String get homeFeatComm;

  /// No description provided for @homeNewOffice.
  ///
  /// In en, this message translates to:
  /// **'New Office Spaces'**
  String get homeNewOffice;

  /// No description provided for @homePopLocations.
  ///
  /// In en, this message translates to:
  /// **'Popular Locations'**
  String get homePopLocations;

  /// No description provided for @homeRecentView.
  ///
  /// In en, this message translates to:
  /// **'Recently Viewed'**
  String get homeRecentView;

  /// No description provided for @homeFeatPlots.
  ///
  /// In en, this message translates to:
  /// **'Featured Plots'**
  String get homeFeatPlots;

  /// No description provided for @homeNewPlots.
  ///
  /// In en, this message translates to:
  /// **'New Plot Projects'**
  String get homeNewPlots;

  /// No description provided for @homeFeatPg.
  ///
  /// In en, this message translates to:
  /// **'Featured PG & Co-living'**
  String get homeFeatPg;

  /// No description provided for @homeNewPg.
  ///
  /// In en, this message translates to:
  /// **'New Co-living Spaces'**
  String get homeNewPg;

  /// No description provided for @homeFeatProp.
  ///
  /// In en, this message translates to:
  /// **'Featured Properties'**
  String get homeFeatProp;

  /// No description provided for @homeNewProp.
  ///
  /// In en, this message translates to:
  /// **'New Projects'**
  String get homeNewProp;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get homeViewAll;

  /// No description provided for @searchVoiceSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice Search'**
  String get searchVoiceSearchTitle;

  /// No description provided for @searchVoiceSearchDesc.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get searchVoiceSearchDesc;

  /// No description provided for @searchVoiceSearchNew.
  ///
  /// In en, this message translates to:
  /// **'Search new'**
  String get searchVoiceSearchNew;

  /// No description provided for @searchVoiceSearchContinue.
  ///
  /// In en, this message translates to:
  /// **'Want to continue'**
  String get searchVoiceSearchContinue;

  /// No description provided for @searchMicPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission not granted or speech recognition unavailable.'**
  String get searchMicPermissionError;

  /// No description provided for @searchSearchProperties.
  ///
  /// In en, this message translates to:
  /// **'Search Properties'**
  String get searchSearchProperties;

  /// No description provided for @searchSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search location, project, or pr...'**
  String get searchSearchHint;

  /// No description provided for @searchLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get searchLoading;

  /// No description provided for @searchPopularCities.
  ///
  /// In en, this message translates to:
  /// **'POPULAR CITIES'**
  String get searchPopularCities;

  /// No description provided for @searchListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get searchListening;

  /// No description provided for @locationSelectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get locationSelectLocation;

  /// No description provided for @locationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search city, locality...'**
  String get locationSearchHint;

  /// No description provided for @locationChooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose a location'**
  String get locationChooseLocation;

  /// No description provided for @locationUsingDeviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Using your device location'**
  String get locationUsingDeviceLocation;

  /// No description provided for @locationCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'CURRENT LOCATION'**
  String get locationCurrentLocation;

  /// No description provided for @locationRecentLocations.
  ///
  /// In en, this message translates to:
  /// **'RECENT LOCATIONS'**
  String get locationRecentLocations;

  /// No description provided for @visitsMyVisits.
  ///
  /// In en, this message translates to:
  /// **'My Visits'**
  String get visitsMyVisits;

  /// No description provided for @visitsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get visitsUpcoming;

  /// No description provided for @visitsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get visitsCompleted;

  /// No description provided for @visitsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get visitsCancelled;

  /// No description provided for @visitsInPersonVisit.
  ///
  /// In en, this message translates to:
  /// **'In-Person Visit'**
  String get visitsInPersonVisit;

  /// No description provided for @visitsVirtualVisit.
  ///
  /// In en, this message translates to:
  /// **'Virtual Visit'**
  String get visitsVirtualVisit;

  /// No description provided for @visitsViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details '**
  String get visitsViewDetails;

  /// No description provided for @savedShortlistedProperties.
  ///
  /// In en, this message translates to:
  /// **'Shortlisted Properties'**
  String get savedShortlistedProperties;

  /// No description provided for @savedSaveToShortlist.
  ///
  /// In en, this message translates to:
  /// **'Save to Shortlist'**
  String get savedSaveToShortlist;

  /// No description provided for @savedSignInDesc.
  ///
  /// In en, this message translates to:
  /// **'Please sign in or create an account to save properties to your shortlist and monitor price drops.'**
  String get savedSignInDesc;

  /// No description provided for @savedSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get savedSignIn;

  /// No description provided for @savedCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get savedCreateAccount;

  /// No description provided for @savedNoShortlisted.
  ///
  /// In en, this message translates to:
  /// **'No Shortlisted Properties'**
  String get savedNoShortlisted;

  /// No description provided for @savedTapHeartDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any property to save it here.'**
  String get savedTapHeartDesc;

  /// No description provided for @savedRemoveAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove All?'**
  String get savedRemoveAllTitle;

  /// No description provided for @savedRemoveAllDesc.
  ///
  /// In en, this message translates to:
  /// **'This will remove all {count} shortlisted properties from your shortlist.'**
  String savedRemoveAllDesc(Object count);

  /// No description provided for @savedCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get savedCancel;

  /// No description provided for @savedRemoveAll.
  ///
  /// In en, this message translates to:
  /// **'Remove All'**
  String get savedRemoveAll;

  /// No description provided for @savedSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String savedSelectedCount(Object count);

  /// No description provided for @savedDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get savedDeselectAll;

  /// No description provided for @savedSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get savedSelectAll;

  /// No description provided for @savedRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get savedRemove;

  /// No description provided for @savedRemoveCount.
  ///
  /// In en, this message translates to:
  /// **'Remove ({count})'**
  String savedRemoveCount(Object count);

  /// No description provided for @savedCompareProperties.
  ///
  /// In en, this message translates to:
  /// **'Compare Properties'**
  String get savedCompareProperties;

  /// No description provided for @devicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Devices'**
  String get devicesTitle;

  /// No description provided for @devicesDesc.
  ///
  /// In en, this message translates to:
  /// **'Secured devices authorized to access your MECO seller and buyer dashboard.'**
  String get devicesDesc;

  /// No description provided for @devicesThisDevice.
  ///
  /// In en, this message translates to:
  /// **'THIS DEVICE'**
  String get devicesThisDevice;

  /// No description provided for @devicesOtherDevices.
  ///
  /// In en, this message translates to:
  /// **'OTHER DEVICES'**
  String get devicesOtherDevices;

  /// No description provided for @devicesLogoutAll.
  ///
  /// In en, this message translates to:
  /// **'Log out from all other devices'**
  String get devicesLogoutAll;

  /// No description provided for @devicesLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get devicesLogOut;

  /// No description provided for @devicesLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used on {time}'**
  String devicesLastUsed(Object time);

  /// No description provided for @devicesRegisteredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered on {time}'**
  String devicesRegisteredOn(Object time);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsAll;

  /// No description provided for @notificationsEnquiries.
  ///
  /// In en, this message translates to:
  /// **'Enquiries'**
  String get notificationsEnquiries;

  /// No description provided for @notificationsVisits.
  ///
  /// In en, this message translates to:
  /// **'Visits'**
  String get notificationsVisits;

  /// No description provided for @notificationsProperties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get notificationsProperties;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsStayUpdated.
  ///
  /// In en, this message translates to:
  /// **'Stay updated on your property activity'**
  String get notificationSettingsStayUpdated;

  /// No description provided for @notificationSettingsChooseDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications you want to receive from MECO Real Estate.'**
  String get notificationSettingsChooseDesc;

  /// No description provided for @notificationSettingsPropertyUpdates.
  ///
  /// In en, this message translates to:
  /// **'PROPERTY UPDATES'**
  String get notificationSettingsPropertyUpdates;

  /// No description provided for @notificationSettingsNewPropertyMatches.
  ///
  /// In en, this message translates to:
  /// **'New Property Matches'**
  String get notificationSettingsNewPropertyMatches;

  /// No description provided for @notificationSettingsNewPropertyMatchesDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified when properties match your saved searches.'**
  String get notificationSettingsNewPropertyMatchesDesc;

  /// No description provided for @notificationSettingsPriceDropAlerts.
  ///
  /// In en, this message translates to:
  /// **'Price Drop Alerts'**
  String get notificationSettingsPriceDropAlerts;

  /// No description provided for @notificationSettingsPriceDropAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Know when a shortlisted property changes price.'**
  String get notificationSettingsPriceDropAlertsDesc;

  /// No description provided for @notificationSettingsPropertyAvailability.
  ///
  /// In en, this message translates to:
  /// **'Property Availability'**
  String get notificationSettingsPropertyAvailability;

  /// No description provided for @notificationSettingsPropertyAvailabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Get updates when a property becomes available or unavailable.'**
  String get notificationSettingsPropertyAvailabilityDesc;

  /// No description provided for @notificationSettingsMyActivity.
  ///
  /// In en, this message translates to:
  /// **'MY ACTIVITY'**
  String get notificationSettingsMyActivity;

  /// No description provided for @notificationSettingsEnquiryUpdates.
  ///
  /// In en, this message translates to:
  /// **'Enquiry Updates'**
  String get notificationSettingsEnquiryUpdates;

  /// No description provided for @notificationSettingsEnquiryUpdatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Updates about your property enquiries.'**
  String get notificationSettingsEnquiryUpdatesDesc;

  /// No description provided for @notificationSettingsVisitReminders.
  ///
  /// In en, this message translates to:
  /// **'Visit Reminders'**
  String get notificationSettingsVisitReminders;

  /// No description provided for @notificationSettingsVisitRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Reminders for upcoming property visits and virtual tours.'**
  String get notificationSettingsVisitRemindersDesc;

  /// No description provided for @notificationSettingsScheduleChanges.
  ///
  /// In en, this message translates to:
  /// **'Schedule Changes'**
  String get notificationSettingsScheduleChanges;

  /// No description provided for @notificationSettingsScheduleChangesDesc.
  ///
  /// In en, this message translates to:
  /// **'Updates when a scheduled visit changes.'**
  String get notificationSettingsScheduleChangesDesc;

  /// No description provided for @notificationSettingsMessagesAccount.
  ///
  /// In en, this message translates to:
  /// **'MESSAGES & ACCOUNT'**
  String get notificationSettingsMessagesAccount;

  /// No description provided for @notificationSettingsMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notificationSettingsMessages;

  /// No description provided for @notificationSettingsMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications from property owners, sellers or developers.'**
  String get notificationSettingsMessagesDesc;

  /// No description provided for @notificationSettingsSecurityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Security Alerts'**
  String get notificationSettingsSecurityAlerts;

  /// No description provided for @notificationSettingsSecurityAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Important account and security notifications.'**
  String get notificationSettingsSecurityAlertsDesc;

  /// No description provided for @notificationSettingsPromotional.
  ///
  /// In en, this message translates to:
  /// **'PROMOTIONAL'**
  String get notificationSettingsPromotional;

  /// No description provided for @notificationSettingsOffersRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Offers & Recommendations'**
  String get notificationSettingsOffersRecommendations;

  /// No description provided for @notificationSettingsOffersRecommendationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive property recommendations and promotional updates.'**
  String get notificationSettingsOffersRecommendationsDesc;

  /// No description provided for @notificationSettingsSavedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences are saved automatically.'**
  String get notificationSettingsSavedAutomatically;

  /// No description provided for @reviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviewsTitle;

  /// No description provided for @reviewsMyReviewsSummary.
  ///
  /// In en, this message translates to:
  /// **'MY REVIEWS SUMMARY'**
  String get reviewsMyReviewsSummary;

  /// No description provided for @reviewsTotalReviewsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Total Reviews Submitted'**
  String get reviewsTotalReviewsSubmitted;

  /// No description provided for @reviewsAverageRating.
  ///
  /// In en, this message translates to:
  /// **'Average Rating'**
  String get reviewsAverageRating;

  /// No description provided for @reviewsYourReviews.
  ///
  /// In en, this message translates to:
  /// **'Your Reviews'**
  String get reviewsYourReviews;

  /// No description provided for @reviewsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get reviewsEdit;

  /// No description provided for @reviewsViewProperty.
  ///
  /// In en, this message translates to:
  /// **'View Property'**
  String get reviewsViewProperty;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['bn', 'en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
    case 'mr': return AppLocalizationsMr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
