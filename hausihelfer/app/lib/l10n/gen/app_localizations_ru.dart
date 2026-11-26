// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'HausiHelfer';

  @override
  String get onboardingTitle => 'Помощь с немецкими домашними заданиями';

  @override
  String get onboardingSubtitle =>
      'Сфотографируйте задание. Мы объясним его по-русски и покажем, как шаг за шагом помочь ребёнку.';

  @override
  String get chooseLanguage => 'Ваш язык';

  @override
  String get chooseState => 'Федеральная земля (Bundesland)';

  @override
  String get chooseSchoolType => 'Тип школы';

  @override
  String get chooseGrade => 'Класс (Klasse)';

  @override
  String gradeLabel(int grade) {
    return '$grade класс';
  }

  @override
  String get continueButton => 'Далее';

  @override
  String get save => 'Сохранить';

  @override
  String get schoolGrundschule => 'Начальная школа (Grundschule)';

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
  String get subjectDeutsch => 'Немецкий';

  @override
  String get subjectEnglisch => 'Английский';

  @override
  String get subjectSachunterricht => 'Окружающий мир (Sachunterricht)';

  @override
  String get subjectOther => 'Другое';

  @override
  String get modeExplain => 'Объяснить задание';

  @override
  String get modeCheck => 'Проверить решение';

  @override
  String get modeExplainHint =>
      'Фото нового задания: вы получите перевод и подсказки шаг за шагом.';

  @override
  String get modeCheckHint =>
      'Фото выполненного задания ребёнка: ищем ошибки, не подсказывая готовый ответ.';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get fromGallery => 'Из галереи';

  @override
  String freeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'На этой неделе осталось $count бесплатных заданий',
      few: 'На этой неделе осталось $count бесплатных задания',
      one: 'На этой неделе осталось $count бесплатное задание',
      zero: 'На этой неделе бесплатных заданий больше нет',
    );
    return '$_temp0';
  }

  @override
  String get premiumActive => 'Premium активен';

  @override
  String get historyTitle => 'Последние задания';

  @override
  String get historyEmpty => 'Здесь появятся объяснённые задания.';

  @override
  String get analyzing => 'Читаю задание…';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorBusy => 'Сервис сейчас перегружен. Попробуйте через минуту.';

  @override
  String get errorNetwork => 'Нет соединения с сервером. Проверьте интернет.';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get unreadableTitle => 'Не удалось прочитать задание';

  @override
  String get resultTaskTitle => 'Что нужно сделать';

  @override
  String get resultOriginal => 'Оригинал (на немецком)';

  @override
  String get resultHowToExplain => 'Как это объяснить';

  @override
  String get resultSteps => 'Шаг за шагом с ребёнком';

  @override
  String stepN(int n) {
    return 'Шаг $n';
  }

  @override
  String get askChild => 'Спросите ребёнка (по-немецки):';

  @override
  String get showNextStep => 'Показать следующий шаг';

  @override
  String get vocabulary => 'Важные немецкие слова';

  @override
  String get showSolution => 'Показать решение (только для вас)';

  @override
  String get hideSolution => 'Скрыть решение';

  @override
  String get solutionWarning =>
      'Сначала попробуйте шаги – ребёнок научится большему, если сам найдёт ответ.';

  @override
  String get checkCorrect => 'Похоже, всё верно!';

  @override
  String get checkWrong => 'Есть ошибка';

  @override
  String get lowConfidence =>
      'Здесь мы не совсем уверены. Пожалуйста, проверьте ещё раз.';

  @override
  String get aiDisclaimer =>
      'Это объяснение создано искусственным интеллектом и может содержать ошибки.';

  @override
  String get reportProblem => 'Сообщить об ошибке';

  @override
  String get reportThanks => 'Спасибо! Мы это проверим.';

  @override
  String get limitReachedTitle => 'Бесплатные задания закончились';

  @override
  String get limitReachedBody =>
      'Вы использовали бесплатные задания на этой неделе. С Premium объяснения без ограничений.';

  @override
  String get upgrade => 'Получить Premium';

  @override
  String get paywallTitle => 'HausiHelfer Premium';

  @override
  String get paywallSubtitle =>
      'Помогайте ребёнку каждый день – на своём языке.';

  @override
  String get paywallBenefit1 => 'Неограниченные объяснения заданий';

  @override
  String get paywallBenefit2 => 'Проверка решений ребёнка';

  @override
  String get paywallBenefit3 => 'Все предметы и классы 1–13';

  @override
  String get paywallTrial => '7 дней бесплатно, отменить можно в любой момент.';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get restored => 'Покупки восстановлены.';

  @override
  String get nothingToRestore => 'Покупки не найдены.';

  @override
  String get purchaseFailed => 'Не удалось завершить покупку.';

  @override
  String get paywallUnavailable => 'Подписки сейчас недоступны.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get profileSection => 'Профиль';

  @override
  String get legalSection => 'Правовая информация';

  @override
  String get imprint => 'Выходные данные (Impressum)';

  @override
  String get privacy => 'Политика конфиденциальности';

  @override
  String get terms => 'Условия использования';

  @override
  String get close => 'Закрыть';

  @override
  String get errorDailyLimit =>
      'Вы достигли дневного лимита. Продолжите завтра.';

  @override
  String get reportHint => 'Что не так? (необязательно)';

  @override
  String get send => 'Отправить';

  @override
  String get cancel => 'Отмена';

  @override
  String get deleteData => 'Удалить мои данные';

  @override
  String get deleteDataConfirm =>
      'Будут удалены история заданий и настройки на этом устройстве. Подписка останется активной.';

  @override
  String get deleteDataDone => 'Ваши данные удалены.';

  @override
  String get delete => 'Удалить';

  @override
  String get manageSubscription => 'Управлять подпиской';

  @override
  String get planMonthly => 'Ежемесячно';

  @override
  String get planYearly => 'Ежегодно';

  @override
  String get paywallLegal =>
      'Подписка продлевается автоматически, если её не отменить как минимум за 24 часа до конца периода. Отменить можно в любой момент в настройках аккаунта App Store или Google Play.';

  @override
  String get solutionTitle => 'Решение';
}
