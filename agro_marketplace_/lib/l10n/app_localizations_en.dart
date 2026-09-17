// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgroMarket';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get noResults => 'No results found';

  @override
  String get networkError => 'Please check your internet connection';

  @override
  String get sessionExpired => 'Session expired. Please login again';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get emailVerification => 'Email Verification';

  @override
  String verifyEmailMessage(String email) {
    return 'Please verify your email address. We\'ve sent a verification link to $email.';
  }

  @override
  String get resendVerification => 'Resend Verification Email';

  @override
  String get sellerDashboard => 'Seller Dashboard';

  @override
  String get profile => 'Profile';

  @override
  String get store => 'Store';

  @override
  String get products => 'Products';

  @override
  String get orders => 'Orders';

  @override
  String get inventory => 'Inventory';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get phoneInvalid => 'Please enter a valid phone number';
}
