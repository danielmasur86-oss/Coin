import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('pl'),
    Locale('ru'),
    Locale('tr'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'HausiHelfer'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Help with German homework'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the task. We explain it in your language and show you how to guide your child.'**
  String get onboardingSubtitle;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Your language'**
  String get chooseLanguage;

  /// No description provided for @chooseState.
  ///
  /// In en, this message translates to:
  /// **'Federal state (Bundesland)'**
  String get chooseState;

  /// No description provided for @chooseSchoolType.
  ///
  /// In en, this message translates to:
  /// **'School type'**
  String get chooseSchoolType;

  /// No description provided for @chooseGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade (Klasse)'**
  String get chooseGrade;

  /// No description provided for @gradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String gradeLabel(int grade);

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @schoolGrundschule.
  ///
  /// In en, this message translates to:
  /// **'Primary school (Grundschule)'**
  String get schoolGrundschule;

  /// No description provided for @schoolGymnasium.
  ///
  /// In en, this message translates to:
  /// **'Gymnasium'**
  String get schoolGymnasium;

  /// No description provided for @schoolRealschule.
  ///
  /// In en, this message translates to:
  /// **'Realschule'**
  String get schoolRealschule;

  /// No description provided for @schoolHauptschule.
  ///
  /// In en, this message translates to:
  /// **'Hauptschule / Mittelschule'**
  String get schoolHauptschule;

  /// No description provided for @schoolGesamtschule.
  ///
  /// In en, this message translates to:
  /// **'Gesamtschule'**
  String get schoolGesamtschule;

  /// No description provided for @schoolOberschule.
  ///
  /// In en, this message translates to:
  /// **'Oberschule / Sekundarschule'**
  String get schoolOberschule;

  /// No description provided for @subjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectLabel;

  /// No description provided for @subjectMathe.
  ///
  /// In en, this message translates to:
  /// **'Maths'**
  String get subjectMathe;

  /// No description provided for @subjectDeutsch.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get subjectDeutsch;

  /// No description provided for @subjectEnglisch.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get subjectEnglisch;

  /// No description provided for @subjectSachunterricht.
  ///
  /// In en, this message translates to:
  /// **'Science (Sachunterricht)'**
  String get subjectSachunterricht;

  /// No description provided for @subjectOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get subjectOther;

  /// No description provided for @modeExplain.
  ///
  /// In en, this message translates to:
  /// **'Explain task'**
  String get modeExplain;

  /// No description provided for @modeCheck.
  ///
  /// In en, this message translates to:
  /// **'Check solution'**
  String get modeCheck;

  /// No description provided for @modeExplainHint.
  ///
  /// In en, this message translates to:
  /// **'Photo of a new task: you get the translation and step-by-step hints.'**
  String get modeExplainHint;

  /// No description provided for @modeCheckHint.
  ///
  /// In en, this message translates to:
  /// **'Photo of your child\'s finished work: we look for mistakes without giving away the answer.'**
  String get modeCheckHint;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @fromGallery.
  ///
  /// In en, this message translates to:
  /// **'From gallery'**
  String get fromGallery;

  /// No description provided for @freeLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No free tasks left this week} =1{1 free task left this week} other{{count} free tasks left this week}}'**
  String freeLeft(int count);

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActive;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent tasks'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your explained tasks will appear here.'**
  String get historyEmpty;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Reading the task…'**
  String get analyzing;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorBusy.
  ///
  /// In en, this message translates to:
  /// **'The service is busy right now. Please try again in a minute.'**
  String get errorBusy;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection to the server. Check your internet.'**
  String get errorNetwork;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @unreadableTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read the task'**
  String get unreadableTitle;

  /// No description provided for @resultTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'What the task asks'**
  String get resultTaskTitle;

  /// No description provided for @resultOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original (German)'**
  String get resultOriginal;

  /// No description provided for @resultHowToExplain.
  ///
  /// In en, this message translates to:
  /// **'How to explain it'**
  String get resultHowToExplain;

  /// No description provided for @resultSteps.
  ///
  /// In en, this message translates to:
  /// **'Step by step with your child'**
  String get resultSteps;

  /// No description provided for @stepN.
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String stepN(int n);

  /// No description provided for @askChild.
  ///
  /// In en, this message translates to:
  /// **'Ask your child (in German):'**
  String get askChild;

  /// No description provided for @showNextStep.
  ///
  /// In en, this message translates to:
  /// **'Show next step'**
  String get showNextStep;

  /// No description provided for @vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Important German words'**
  String get vocabulary;

  /// No description provided for @showSolution.
  ///
  /// In en, this message translates to:
  /// **'Show solution (for you only)'**
  String get showSolution;

  /// No description provided for @hideSolution.
  ///
  /// In en, this message translates to:
  /// **'Hide solution'**
  String get hideSolution;

  /// No description provided for @solutionWarning.
  ///
  /// In en, this message translates to:
  /// **'Try the steps first – your child learns more by finding the answer.'**
  String get solutionWarning;

  /// No description provided for @checkCorrect.
  ///
  /// In en, this message translates to:
  /// **'Looks correct!'**
  String get checkCorrect;

  /// No description provided for @checkWrong.
  ///
  /// In en, this message translates to:
  /// **'There is a mistake'**
  String get checkWrong;

  /// No description provided for @lowConfidence.
  ///
  /// In en, this message translates to:
  /// **'We are not completely sure about this one. Please double-check.'**
  String get lowConfidence;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This explanation was created by AI and can contain mistakes.'**
  String get aiDisclaimer;

  /// No description provided for @reportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a mistake'**
  String get reportProblem;

  /// No description provided for @reportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you! We will look at it.'**
  String get reportThanks;

  /// No description provided for @limitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Free tasks used up'**
  String get limitReachedTitle;

  /// No description provided for @limitReachedBody.
  ///
  /// In en, this message translates to:
  /// **'You have used your free tasks for this week. With Premium you get unlimited explanations.'**
  String get limitReachedBody;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get upgrade;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'HausiHelfer Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help your child every day – in your language.'**
  String get paywallSubtitle;

  /// No description provided for @paywallBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited task explanations'**
  String get paywallBenefit1;

  /// No description provided for @paywallBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Check your child\'s solutions'**
  String get paywallBenefit2;

  /// No description provided for @paywallBenefit3.
  ///
  /// In en, this message translates to:
  /// **'All subjects and grades 1–13'**
  String get paywallBenefit3;

  /// No description provided for @paywallTrial.
  ///
  /// In en, this message translates to:
  /// **'Try free for 7 days, cancel anytime.'**
  String get paywallTrial;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get restored;

  /// No description provided for @nothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'No purchases found.'**
  String get nothingToRestore;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be completed.'**
  String get purchaseFailed;

  /// No description provided for @paywallUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are not available right now.'**
  String get paywallUnavailable;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// No description provided for @legalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalSection;

  /// No description provided for @imprint.
  ///
  /// In en, this message translates to:
  /// **'Imprint (Impressum)'**
  String get imprint;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacy;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get terms;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @errorDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached today\'s limit. Please continue tomorrow.'**
  String get errorDailyLimit;

  /// No description provided for @reportHint.
  ///
  /// In en, this message translates to:
  /// **'What is wrong? (optional)'**
  String get reportHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteData.
  ///
  /// In en, this message translates to:
  /// **'Delete my data'**
  String get deleteData;

  /// No description provided for @deleteDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This deletes your task history and settings on this device. Your subscription stays active.'**
  String get deleteDataConfirm;

  /// No description provided for @deleteDataDone.
  ///
  /// In en, this message translates to:
  /// **'Your data was deleted.'**
  String get deleteDataDone;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @paywallLegal.
  ///
  /// In en, this message translates to:
  /// **'The subscription renews automatically unless cancelled at least 24 hours before the end of the period. You can cancel anytime in your App Store or Google Play account settings.'**
  String get paywallLegal;

  /// No description provided for @solutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get solutionTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'pl',
    'ru',
    'tr',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
