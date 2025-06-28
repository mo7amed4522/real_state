// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Real Estate App';

  @override
  String get home => 'Home';

  @override
  String get login => 'Login';

  @override
  String get welcome => 'Welcome to the Real Estate App!';

  @override
  String get email => 'E-Mail';

  @override
  String get emailRequired => 'E-Mail required';

  @override
  String get enterValidEmail => 'E-Mail Validation';

  @override
  String get forgotPassword => 'Forget Password';

  @override
  String get sendCode => 'Send Code';

  @override
  String get register => 'Register';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Confirm Password';
}
