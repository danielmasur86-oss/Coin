// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'HausiHelfer';

  @override
  String get onboardingTitle => 'Pomoc w niemieckich zadaniach domowych';

  @override
  String get onboardingSubtitle =>
      'Zrób zdjęcie zadania. Wytłumaczymy je po polsku i pokażemy, jak krok po kroku pomóc dziecku.';

  @override
  String get chooseLanguage => 'Twój język';

  @override
  String get chooseState => 'Kraj związkowy (Bundesland)';

  @override
  String get chooseSchoolType => 'Rodzaj szkoły';

  @override
  String get chooseGrade => 'Klasa (Klasse)';

  @override
  String gradeLabel(int grade) {
    return 'Klasa $grade';
  }

  @override
  String get continueButton => 'Dalej';

  @override
  String get save => 'Zapisz';

  @override
  String get schoolGrundschule => 'Szkoła podstawowa (Grundschule)';

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
  String get subjectLabel => 'Przedmiot';

  @override
  String get subjectMathe => 'Matematyka';

  @override
  String get subjectDeutsch => 'Niemiecki';

  @override
  String get subjectEnglisch => 'Angielski';

  @override
  String get subjectSachunterricht => 'Przyroda (Sachunterricht)';

  @override
  String get subjectOther => 'Inny';

  @override
  String get modeExplain => 'Wyjaśnij zadanie';

  @override
  String get modeCheck => 'Sprawdź rozwiązanie';

  @override
  String get modeExplainHint =>
      'Zdjęcie nowego zadania: dostaniesz tłumaczenie i podpowiedzi krok po kroku.';

  @override
  String get modeCheckHint =>
      'Zdjęcie zrobionego zadania dziecka: szukamy błędów, nie podając gotowego wyniku.';

  @override
  String get takePhoto => 'Zrób zdjęcie';

  @override
  String get fromGallery => 'Z galerii';

  @override
  String freeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zostało $count darmowych zadań w tym tygodniu',
      few: 'Zostały $count darmowe zadania w tym tygodniu',
      one: 'Zostało 1 darmowe zadanie w tym tygodniu',
      zero: 'W tym tygodniu nie masz już darmowych zadań',
    );
    return '$_temp0';
  }

  @override
  String get premiumActive => 'Premium aktywne';

  @override
  String get historyTitle => 'Ostatnie zadania';

  @override
  String get historyEmpty => 'Tutaj pojawią się wyjaśnione zadania.';

  @override
  String get analyzing => 'Czytam zadanie…';

  @override
  String get errorGeneric => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get errorBusy => 'Serwis jest teraz przeciążony. Spróbuj za minutę.';

  @override
  String get errorNetwork => 'Brak połączenia z serwerem. Sprawdź internet.';

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get unreadableTitle => 'Nie udało się odczytać zadania';

  @override
  String get resultTaskTitle => 'O co chodzi w zadaniu';

  @override
  String get resultOriginal => 'Oryginał (po niemiecku)';

  @override
  String get resultHowToExplain => 'Jak to wytłumaczyć';

  @override
  String get resultSteps => 'Krok po kroku z dzieckiem';

  @override
  String stepN(int n) {
    return 'Krok $n';
  }

  @override
  String get askChild => 'Zapytaj dziecko (po niemiecku):';

  @override
  String get showNextStep => 'Pokaż następny krok';

  @override
  String get vocabulary => 'Ważne niemieckie słowa';

  @override
  String get showSolution => 'Pokaż rozwiązanie (tylko dla Ciebie)';

  @override
  String get hideSolution => 'Ukryj rozwiązanie';

  @override
  String get solutionWarning =>
      'Najpierw spróbuj kroków – dziecko nauczy się więcej, gdy samo dojdzie do wyniku.';

  @override
  String get checkCorrect => 'Wygląda dobrze!';

  @override
  String get checkWrong => 'Jest błąd';

  @override
  String get lowConfidence =>
      'Nie jesteśmy tu całkiem pewni. Sprawdź to jeszcze raz.';

  @override
  String get aiDisclaimer =>
      'To wyjaśnienie przygotowała sztuczna inteligencja i może zawierać błędy.';

  @override
  String get reportProblem => 'Zgłoś błąd';

  @override
  String get reportThanks => 'Dziękujemy! Sprawdzimy to.';

  @override
  String get limitReachedTitle => 'Darmowe zadania wykorzystane';

  @override
  String get limitReachedBody =>
      'Wykorzystałeś darmowe zadania w tym tygodniu. Z Premium masz nielimitowane wyjaśnienia.';

  @override
  String get upgrade => 'Kup Premium';

  @override
  String get paywallTitle => 'HausiHelfer Premium';

  @override
  String get paywallSubtitle => 'Pomagaj dziecku codziennie – w swoim języku.';

  @override
  String get paywallBenefit1 => 'Nielimitowane wyjaśnienia zadań';

  @override
  String get paywallBenefit2 => 'Sprawdzanie rozwiązań dziecka';

  @override
  String get paywallBenefit3 => 'Wszystkie przedmioty i klasy 1–13';

  @override
  String get paywallTrial =>
      '7 dni za darmo, możesz zrezygnować w każdej chwili.';

  @override
  String get restorePurchases => 'Przywróć zakupy';

  @override
  String get restored => 'Zakupy przywrócone.';

  @override
  String get nothingToRestore => 'Nie znaleziono zakupów.';

  @override
  String get purchaseFailed => 'Nie udało się dokończyć zakupu.';

  @override
  String get paywallUnavailable => 'Subskrypcje są teraz niedostępne.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get profileSection => 'Profil';

  @override
  String get legalSection => 'Informacje prawne';

  @override
  String get imprint => 'Nota prawna (Impressum)';

  @override
  String get privacy => 'Polityka prywatności';

  @override
  String get terms => 'Regulamin';

  @override
  String get close => 'Zamknij';
}
