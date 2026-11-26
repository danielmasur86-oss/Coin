// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'HausiHelfer';

  @override
  String get onboardingTitle => 'Допомога з німецькими домашніми завданнями';

  @override
  String get onboardingSubtitle =>
      'Сфотографуйте завдання. Ми пояснимо його українською і покажемо, як крок за кроком допомогти дитині.';

  @override
  String get chooseLanguage => 'Ваша мова';

  @override
  String get chooseState => 'Федеральна земля (Bundesland)';

  @override
  String get chooseSchoolType => 'Тип школи';

  @override
  String get chooseGrade => 'Клас (Klasse)';

  @override
  String gradeLabel(int grade) {
    return '$grade клас';
  }

  @override
  String get continueButton => 'Далі';

  @override
  String get save => 'Зберегти';

  @override
  String get schoolGrundschule => 'Початкова школа (Grundschule)';

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
  String get subjectLabel => 'Предмет';

  @override
  String get subjectMathe => 'Математика';

  @override
  String get subjectDeutsch => 'Німецька';

  @override
  String get subjectEnglisch => 'Англійська';

  @override
  String get subjectSachunterricht => 'Природознавство (Sachunterricht)';

  @override
  String get subjectOther => 'Інше';

  @override
  String get modeExplain => 'Пояснити завдання';

  @override
  String get modeCheck => 'Перевірити розв\'язок';

  @override
  String get modeExplainHint =>
      'Фото нового завдання: ви отримаєте переклад і підказки крок за кроком.';

  @override
  String get modeCheckHint =>
      'Фото виконаного завдання дитини: шукаємо помилки, не підказуючи готової відповіді.';

  @override
  String get takePhoto => 'Зробити фото';

  @override
  String get fromGallery => 'З галереї';

  @override
  String freeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Цього тижня залишилось $count безкоштовних завдань',
      few: 'Цього тижня залишилось $count безкоштовні завдання',
      one: 'Цього тижня залишилось $count безкоштовне завдання',
      zero: 'Цього тижня безкоштовних завдань більше немає',
    );
    return '$_temp0';
  }

  @override
  String get premiumActive => 'Premium активний';

  @override
  String get historyTitle => 'Останні завдання';

  @override
  String get historyEmpty => 'Тут з\'являться пояснені завдання.';

  @override
  String get analyzing => 'Читаю завдання…';

  @override
  String get errorGeneric => 'Щось пішло не так. Спробуйте ще раз.';

  @override
  String get errorBusy => 'Сервіс зараз перевантажений. Спробуйте за хвилину.';

  @override
  String get errorNetwork => 'Немає з\'єднання з сервером. Перевірте інтернет.';

  @override
  String get tryAgain => 'Спробувати ще раз';

  @override
  String get unreadableTitle => 'Не вдалося прочитати завдання';

  @override
  String get resultTaskTitle => 'Що потрібно зробити';

  @override
  String get resultOriginal => 'Оригінал (німецькою)';

  @override
  String get resultHowToExplain => 'Як це пояснити';

  @override
  String get resultSteps => 'Крок за кроком з дитиною';

  @override
  String stepN(int n) {
    return 'Крок $n';
  }

  @override
  String get askChild => 'Запитайте дитину (німецькою):';

  @override
  String get showNextStep => 'Показати наступний крок';

  @override
  String get vocabulary => 'Важливі німецькі слова';

  @override
  String get showSolution => 'Показати розв\'язок (лише для вас)';

  @override
  String get hideSolution => 'Сховати розв\'язок';

  @override
  String get solutionWarning =>
      'Спершу спробуйте кроки – дитина навчиться більше, якщо сама знайде відповідь.';

  @override
  String get checkCorrect => 'Виглядає правильно!';

  @override
  String get checkWrong => 'Є помилка';

  @override
  String get lowConfidence =>
      'Тут ми не зовсім впевнені. Будь ласка, перевірте ще раз.';

  @override
  String get aiDisclaimer =>
      'Це пояснення створив штучний інтелект, і воно може містити помилки.';

  @override
  String get reportProblem => 'Повідомити про помилку';

  @override
  String get reportThanks => 'Дякуємо! Ми це перевіримо.';

  @override
  String get limitReachedTitle => 'Безкоштовні завдання закінчились';

  @override
  String get limitReachedBody =>
      'Ви використали безкоштовні завдання цього тижня. З Premium пояснення без обмежень.';

  @override
  String get upgrade => 'Отримати Premium';

  @override
  String get paywallTitle => 'HausiHelfer Premium';

  @override
  String get paywallSubtitle => 'Допомагайте дитині щодня – своєю мовою.';

  @override
  String get paywallBenefit1 => 'Необмежені пояснення завдань';

  @override
  String get paywallBenefit2 => 'Перевірка розв\'язків дитини';

  @override
  String get paywallBenefit3 => 'Усі предмети та класи 1–13';

  @override
  String get paywallTrial => '7 днів безкоштовно, скасувати можна будь-коли.';

  @override
  String get restorePurchases => 'Відновити покупки';

  @override
  String get restored => 'Покупки відновлено.';

  @override
  String get nothingToRestore => 'Покупок не знайдено.';

  @override
  String get purchaseFailed => 'Не вдалося завершити покупку.';

  @override
  String get paywallUnavailable => 'Підписки зараз недоступні.';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get profileSection => 'Профіль';

  @override
  String get legalSection => 'Правова інформація';

  @override
  String get imprint => 'Вихідні дані (Impressum)';

  @override
  String get privacy => 'Політика конфіденційності';

  @override
  String get terms => 'Умови використання';

  @override
  String get close => 'Закрити';
}
