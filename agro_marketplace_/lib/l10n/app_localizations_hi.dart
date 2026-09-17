// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'एग्रोमार्केट';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'कुछ गलत हो गया';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get search => 'खोजें';

  @override
  String get noResults => 'कोई परिणाम नहीं मिला';

  @override
  String get networkError => 'कृपया अपना इंटरनेट कनेक्शन जांचें';

  @override
  String get sessionExpired => 'सत्र समाप्त हो गया। कृपया फिर से लॉगिन करें';

  @override
  String get login => 'लॉगिन';

  @override
  String get register => 'रजिस्टर';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है?';

  @override
  String get dontHaveAccount => 'खाता नहीं है?';

  @override
  String get emailVerification => 'ईमेल सत्यापन';

  @override
  String verifyEmailMessage(String email) {
    return 'कृपया अपना ईमेल पता सत्यापित करें। हमने $email पर एक सत्यापन लिंक भेजा है।';
  }

  @override
  String get resendVerification => 'सत्यापन ईमेल पुनः भेजें';

  @override
  String get sellerDashboard => 'विक्रेता डैशबोर्ड';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get store => 'दुकान';

  @override
  String get products => 'उत्पाद';

  @override
  String get orders => 'ऑर्डर';

  @override
  String get inventory => 'इन्वेंटरी';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get requiredField => 'यह फ़ील्ड आवश्यक है';

  @override
  String get invalidEmail => 'कृपया एक वैध ईमेल दर्ज करें';

  @override
  String get passwordTooShort => 'पासवर्ड कम से कम 8 अक्षरों का होना चाहिए';

  @override
  String get phoneInvalid => 'कृपया एक वैध फ़ोन नंबर दर्ज करें';
}
