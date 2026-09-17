// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'એગ્રોમાર્કેટ';

  @override
  String get loading => 'લોડ થઈ રહ્યું છે...';

  @override
  String get error => 'કંઈક ખોટું થયું';

  @override
  String get retry => 'ફરી પ્રયાસ કરો';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get save => 'સાચવો';

  @override
  String get confirm => 'ખાતરી કરો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get edit => 'ફેરફાર કરો';

  @override
  String get search => 'શોધો';

  @override
  String get noResults => 'કોઈ પરિણામ મળ્યું નથી';

  @override
  String get networkError => 'કૃપા કરીને તમારું ઇન્ટરનેટ કનેક્શન તપાસો';

  @override
  String get sessionExpired => 'સત્ર સમાપ્ત થયું. કૃપા કરીને ફરીથી લોગિન કરો';

  @override
  String get login => 'લોગિન';

  @override
  String get register => 'રજિસ્ટર';

  @override
  String get email => 'ઈમેઇલ';

  @override
  String get password => 'પાસવર્ડ';

  @override
  String get forgotPassword => 'પાસવર્ડ ભૂલી ગયા?';

  @override
  String get createAccount => 'એકાઉન્ટ બનાવો';

  @override
  String get alreadyHaveAccount => 'પહેલેથી એકાઉન્ટ છે?';

  @override
  String get dontHaveAccount => 'એકાઉન્ટ નથી?';

  @override
  String get emailVerification => 'ઈમેઇલ ચકાસણી';

  @override
  String verifyEmailMessage(String email) {
    return 'કૃપા કરીને તમારું ઈમેઇલ સરનામું ચકાસો. અમે $email પર ચકાસણી લિંક મોકલ્યો છે.';
  }

  @override
  String get resendVerification => 'ચકાસણી ઈમેઇલ ફરીથી મોકલો';

  @override
  String get sellerDashboard => 'વિક્રેતા ડેશબોર્ડ';

  @override
  String get profile => 'પ્રોફાઇલ';

  @override
  String get store => 'દુકાન';

  @override
  String get products => 'ઉત્પાદનો';

  @override
  String get orders => 'ઓર્ડર';

  @override
  String get inventory => 'ઇન્વેન્ટરી';

  @override
  String get settings => 'સેટિંગ્સ';

  @override
  String get logout => 'લોગઆઉટ';

  @override
  String get requiredField => 'આ ફીલ્ડ જરૂરી છે';

  @override
  String get invalidEmail => 'કૃપા કરીને માન્ય ઈમેઇલ દાખલ કરો';

  @override
  String get passwordTooShort => 'પાસવર્ડ ઓછામાં ઓછા 8 અક્ષરોનો હોવો જોઈએ';

  @override
  String get phoneInvalid => 'કૃપા કરીને માન્ય ફોન નંબર દાખલ કરો';
}
