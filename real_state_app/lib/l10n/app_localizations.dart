import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// First, open your project's ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project's Runner folder.
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
    Locale('ar'),
    Locale('hi'),
    Locale('fil'),
  ];

  /// The title of My Applications
  ///
  /// In en, this message translates to:
  /// **'Real Estate App'**
  String get appTitle;

  /// The title of the app
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// The title of the app
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// The title of the app
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Real Estate App!'**
  String get welcome;

  String get forgotPassword;
  String get email;
  String get sendCode;
  String get emailRequired;
  String get enterValidEmail;
  // Register screen additions
  String get register;
  String get password;
  String get confirmPassword;
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
      <String>['en', 'ar', 'hi', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ar':
      return AppLocalizationsAr();
    case 'hi':
      return AppLocalizationsHi();
    case 'fil':
      return AppLocalizationsFil();
  }
  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

// Add stubs for new localization classes
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);
  @override
  String get appTitle => 'تطبيق العقارات';
  @override
  String get home => 'الرئيسية';
  @override
  String get login => 'تسجيل الدخول';
  @override
  String get welcome => 'مرحبًا بك في تطبيق العقارات!';
  @override
  String get forgotPassword => 'نسيت كلمة المرور';
  @override
  String get email => 'البريد الإلكتروني';
  @override
  String get sendCode => 'إرسال الرمز';
  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';
  @override
  String get enterValidEmail => 'أدخل بريدًا إلكترونيًا صحيحًا';
  @override
  String get register => 'تسجيل';
  @override
  String get password => 'كلمة المرور';
  @override
  String get confirmPassword => 'تأكيد كلمة المرور';
}

class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);
  @override
  String get appTitle => 'रियल एस्टेट ऐप';
  @override
  String get home => 'होम';
  @override
  String get login => 'लॉगिन';
  @override
  String get welcome => 'रियल एस्टेट ऐप में आपका स्वागत है!';
  @override
  String get forgotPassword => 'पासवर्ड भूल गए';
  @override
  String get email => 'ईमेल';
  @override
  String get sendCode => 'कोड भेजें';
  @override
  String get emailRequired => 'ईमेल आवश्यक है';
  @override
  String get enterValidEmail => 'मान्य ईमेल दर्ज करें';
  @override
  String get register => 'रजिस्टर करें';
  @override
  String get password => 'पासवर्ड';
  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';
}

class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);
  @override
  String get appTitle => 'Real Estate App';
  @override
  String get home => 'Bahay';
  @override
  String get login => 'Mag-login';
  @override
  String get welcome => 'Maligayang pagdating sa Real Estate App!';
  @override
  String get forgotPassword => 'Nakalimutan ang Password';
  @override
  String get email => 'Email';
  @override
  String get sendCode => 'Ipadala ang Code';
  @override
  String get emailRequired => 'Kinakailangan ang email';
  @override
  String get enterValidEmail => 'Maglagay ng wastong email';
  @override
  String get register => 'Magrehistro';
  @override
  String get password => 'Password';
  @override
  String get confirmPassword => 'Kumpirmahin ang Password';
}
