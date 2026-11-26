// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'HausiHelfer';

  @override
  String get onboardingTitle => 'Hilfe bei den Hausaufgaben';

  @override
  String get onboardingSubtitle =>
      'Fotografieren Sie die Aufgabe. Wir erklären sie Ihnen und zeigen, wie Sie Ihr Kind Schritt für Schritt anleiten.';

  @override
  String get chooseLanguage => 'Ihre Sprache';

  @override
  String get chooseState => 'Bundesland';

  @override
  String get chooseSchoolType => 'Schulform';

  @override
  String get chooseGrade => 'Klasse';

  @override
  String gradeLabel(int grade) {
    return 'Klasse $grade';
  }

  @override
  String get continueButton => 'Weiter';

  @override
  String get save => 'Speichern';

  @override
  String get schoolGrundschule => 'Grundschule';

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
  String get subjectLabel => 'Fach';

  @override
  String get subjectMathe => 'Mathe';

  @override
  String get subjectDeutsch => 'Deutsch';

  @override
  String get subjectEnglisch => 'Englisch';

  @override
  String get subjectSachunterricht => 'Sachunterricht';

  @override
  String get subjectOther => 'Anderes';

  @override
  String get modeExplain => 'Aufgabe erklären';

  @override
  String get modeCheck => 'Lösung prüfen';

  @override
  String get modeExplainHint =>
      'Foto einer neuen Aufgabe: Sie bekommen eine einfache Erklärung und Hinweise Schritt für Schritt.';

  @override
  String get modeCheckHint =>
      'Foto der fertigen Aufgabe Ihres Kindes: Wir suchen Fehler, ohne die Lösung zu verraten.';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get fromGallery => 'Aus der Galerie';

  @override
  String freeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count kostenlose Aufgaben diese Woche',
      one: 'Noch 1 kostenlose Aufgabe diese Woche',
      zero: 'Diese Woche keine kostenlosen Aufgaben mehr',
    );
    return '$_temp0';
  }

  @override
  String get premiumActive => 'Premium aktiv';

  @override
  String get historyTitle => 'Letzte Aufgaben';

  @override
  String get historyEmpty => 'Hier erscheinen Ihre erklärten Aufgaben.';

  @override
  String get analyzing => 'Aufgabe wird gelesen…';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuchen Sie es erneut.';

  @override
  String get errorBusy =>
      'Der Dienst ist gerade ausgelastet. Bitte versuchen Sie es in einer Minute erneut.';

  @override
  String get errorNetwork =>
      'Keine Verbindung zum Server. Bitte prüfen Sie Ihr Internet.';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get unreadableTitle => 'Die Aufgabe konnte nicht gelesen werden';

  @override
  String get resultTaskTitle => 'Was die Aufgabe verlangt';

  @override
  String get resultOriginal => 'Original (Deutsch)';

  @override
  String get resultHowToExplain => 'So erklären Sie es';

  @override
  String get resultSteps => 'Schritt für Schritt mit Ihrem Kind';

  @override
  String stepN(int n) {
    return 'Schritt $n';
  }

  @override
  String get askChild => 'Fragen Sie Ihr Kind:';

  @override
  String get showNextStep => 'Nächsten Schritt zeigen';

  @override
  String get vocabulary => 'Wichtige Wörter';

  @override
  String get showSolution => 'Lösung zeigen (nur für Sie)';

  @override
  String get hideSolution => 'Lösung ausblenden';

  @override
  String get solutionWarning =>
      'Probieren Sie zuerst die Schritte – Ihr Kind lernt mehr, wenn es die Lösung selbst findet.';

  @override
  String get checkCorrect => 'Sieht richtig aus!';

  @override
  String get checkWrong => 'Hier ist ein Fehler';

  @override
  String get lowConfidence =>
      'Hier sind wir uns nicht ganz sicher. Bitte prüfen Sie es noch einmal.';

  @override
  String get aiDisclaimer =>
      'Diese Erklärung wurde von einer KI erstellt und kann Fehler enthalten.';

  @override
  String get reportProblem => 'Fehler melden';

  @override
  String get reportThanks => 'Danke! Wir sehen es uns an.';

  @override
  String get limitReachedTitle => 'Kostenlose Aufgaben aufgebraucht';

  @override
  String get limitReachedBody =>
      'Sie haben Ihre kostenlosen Aufgaben für diese Woche genutzt. Mit Premium erhalten Sie unbegrenzt viele Erklärungen.';

  @override
  String get upgrade => 'Premium holen';

  @override
  String get paywallTitle => 'HausiHelfer Premium';

  @override
  String get paywallSubtitle =>
      'Helfen Sie Ihrem Kind jeden Tag – in Ihrer Sprache.';

  @override
  String get paywallBenefit1 => 'Unbegrenzt viele Aufgaben erklären';

  @override
  String get paywallBenefit2 => 'Lösungen Ihres Kindes prüfen';

  @override
  String get paywallBenefit3 => 'Alle Fächer und Klassen 1–13';

  @override
  String get paywallTrial => '7 Tage kostenlos testen, jederzeit kündbar.';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get restored => 'Käufe wiederhergestellt.';

  @override
  String get nothingToRestore => 'Keine Käufe gefunden.';

  @override
  String get purchaseFailed => 'Der Kauf konnte nicht abgeschlossen werden.';

  @override
  String get paywallUnavailable => 'Abos sind gerade nicht verfügbar.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get profileSection => 'Profil';

  @override
  String get legalSection => 'Rechtliches';

  @override
  String get imprint => 'Impressum';

  @override
  String get privacy => 'Datenschutzerklärung';

  @override
  String get terms => 'AGB';

  @override
  String get close => 'Schließen';

  @override
  String get errorDailyLimit =>
      'Sie haben das Tageslimit erreicht. Bitte machen Sie morgen weiter.';

  @override
  String get reportHint => 'Was ist falsch? (optional)';

  @override
  String get send => 'Senden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get deleteData => 'Meine Daten löschen';

  @override
  String get deleteDataConfirm =>
      'Dadurch werden Ihr Aufgabenverlauf und Ihre Einstellungen auf diesem Gerät gelöscht. Ihr Abo bleibt aktiv.';

  @override
  String get deleteDataDone => 'Ihre Daten wurden gelöscht.';

  @override
  String get delete => 'Löschen';

  @override
  String get manageSubscription => 'Abo verwalten';

  @override
  String get planMonthly => 'Monatlich';

  @override
  String get planYearly => 'Jährlich';

  @override
  String get paywallLegal =>
      'Das Abo verlängert sich automatisch, wenn es nicht mindestens 24 Stunden vor Ablauf gekündigt wird. Sie können jederzeit in den Einstellungen Ihres App-Store- oder Google-Play-Kontos kündigen.';

  @override
  String get solutionTitle => 'Lösung';
}
