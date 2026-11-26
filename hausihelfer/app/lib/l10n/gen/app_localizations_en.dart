// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HausiHelfer';

  @override
  String get onboardingTitle => 'Help with German homework';

  @override
  String get onboardingSubtitle =>
      'Take a photo of the task. We explain it in your language and show you how to guide your child.';

  @override
  String get chooseLanguage => 'Your language';

  @override
  String get chooseState => 'Federal state (Bundesland)';

  @override
  String get chooseSchoolType => 'School type';

  @override
  String get chooseGrade => 'Grade (Klasse)';

  @override
  String gradeLabel(int grade) {
    return 'Grade $grade';
  }

  @override
  String get continueButton => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get schoolGrundschule => 'Primary school (Grundschule)';

  @override
  String get schoolGymnasium => 'Gymnasium';

  @override
  String get schoolRealschule => 'Realschule';

  @override
  String get schoolHauptschule => 'Hauptschule / Mittelschule';

  @override
  String get schoolGesamtschule => 'Gesamtschule';

  @override
  String get schoolOberschule => 'Oberschule / Sekundarschule';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get subjectMathe => 'Maths';

  @override
  String get subjectDeutsch => 'German';

  @override
  String get subjectEnglisch => 'English';

  @override
  String get subjectSachunterricht => 'Science (Sachunterricht)';

  @override
  String get subjectOther => 'Other';

  @override
  String get modeExplain => 'Explain task';

  @override
  String get modeCheck => 'Check solution';

  @override
  String get modeExplainHint =>
      'Photo of a new task: you get the translation and step-by-step hints.';

  @override
  String get modeCheckHint =>
      'Photo of your child\'s finished work: we look for mistakes without giving away the answer.';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get fromGallery => 'From gallery';

  @override
  String freeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free tasks left this week',
      one: '1 free task left this week',
      zero: 'No free tasks left this week',
    );
    return '$_temp0';
  }

  @override
  String get premiumActive => 'Premium active';

  @override
  String get historyTitle => 'Recent tasks';

  @override
  String get historyEmpty => 'Your explained tasks will appear here.';

  @override
  String get analyzing => 'Reading the task…';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorBusy =>
      'The service is busy right now. Please try again in a minute.';

  @override
  String get errorNetwork =>
      'No connection to the server. Check your internet.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get unreadableTitle => 'We couldn\'t read the task';

  @override
  String get resultTaskTitle => 'What the task asks';

  @override
  String get resultOriginal => 'Original (German)';

  @override
  String get resultHowToExplain => 'How to explain it';

  @override
  String get resultSteps => 'Step by step with your child';

  @override
  String stepN(int n) {
    return 'Step $n';
  }

  @override
  String get askChild => 'Ask your child (in German):';

  @override
  String get showNextStep => 'Show next step';

  @override
  String get vocabulary => 'Important German words';

  @override
  String get showSolution => 'Show solution (for you only)';

  @override
  String get hideSolution => 'Hide solution';

  @override
  String get solutionWarning =>
      'Try the steps first – your child learns more by finding the answer.';

  @override
  String get checkCorrect => 'Looks correct!';

  @override
  String get checkWrong => 'There is a mistake';

  @override
  String get lowConfidence =>
      'We are not completely sure about this one. Please double-check.';

  @override
  String get aiDisclaimer =>
      'This explanation was created by AI and can contain mistakes.';

  @override
  String get reportProblem => 'Report a mistake';

  @override
  String get reportThanks => 'Thank you! We will look at it.';

  @override
  String get limitReachedTitle => 'Free tasks used up';

  @override
  String get limitReachedBody =>
      'You have used your free tasks for this week. With Premium you get unlimited explanations.';

  @override
  String get upgrade => 'Get Premium';

  @override
  String get paywallTitle => 'HausiHelfer Premium';

  @override
  String get paywallSubtitle => 'Help your child every day – in your language.';

  @override
  String get paywallBenefit1 => 'Unlimited task explanations';

  @override
  String get paywallBenefit2 => 'Check your child\'s solutions';

  @override
  String get paywallBenefit3 => 'All subjects and grades 1–13';

  @override
  String get paywallTrial => 'Try free for 7 days, cancel anytime.';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get restored => 'Purchases restored.';

  @override
  String get nothingToRestore => 'No purchases found.';

  @override
  String get purchaseFailed => 'The purchase could not be completed.';

  @override
  String get paywallUnavailable => 'Subscriptions are not available right now.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileSection => 'Profile';

  @override
  String get legalSection => 'Legal';

  @override
  String get imprint => 'Imprint (Impressum)';

  @override
  String get privacy => 'Privacy policy';

  @override
  String get terms => 'Terms of use';

  @override
  String get close => 'Close';
}
