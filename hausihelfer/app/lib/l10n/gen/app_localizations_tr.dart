// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'HausiHelfer';

  @override
  String get onboardingTitle => 'Almanca ödevlerde yardım';

  @override
  String get onboardingSubtitle =>
      'Ödevin fotoğrafını çekin. Size Türkçe açıklıyor ve çocuğunuza adım adım nasıl yardım edeceğinizi gösteriyoruz.';

  @override
  String get chooseLanguage => 'Diliniz';

  @override
  String get chooseState => 'Eyalet (Bundesland)';

  @override
  String get chooseSchoolType => 'Okul türü';

  @override
  String get chooseGrade => 'Sınıf (Klasse)';

  @override
  String gradeLabel(int grade) {
    return '$grade. sınıf';
  }

  @override
  String get continueButton => 'Devam';

  @override
  String get save => 'Kaydet';

  @override
  String get schoolGrundschule => 'İlkokul (Grundschule)';

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
  String get subjectLabel => 'Ders';

  @override
  String get subjectMathe => 'Matematik';

  @override
  String get subjectDeutsch => 'Almanca';

  @override
  String get subjectEnglisch => 'İngilizce';

  @override
  String get subjectSachunterricht => 'Hayat bilgisi (Sachunterricht)';

  @override
  String get subjectOther => 'Diğer';

  @override
  String get modeExplain => 'Ödevi açıkla';

  @override
  String get modeCheck => 'Çözümü kontrol et';

  @override
  String get modeExplainHint =>
      'Yeni bir ödevin fotoğrafı: çevirisini ve adım adım ipuçlarını alırsınız.';

  @override
  String get modeCheckHint =>
      'Çocuğunuzun bitirdiği ödevin fotoğrafı: cevabı söylemeden hataları buluruz.';

  @override
  String get takePhoto => 'Fotoğraf çek';

  @override
  String get fromGallery => 'Galeriden';

  @override
  String freeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bu hafta $count ücretsiz ödev hakkınız kaldı',
      one: 'Bu hafta 1 ücretsiz ödev hakkınız kaldı',
      zero: 'Bu hafta ücretsiz ödev hakkınız kalmadı',
    );
    return '$_temp0';
  }

  @override
  String get premiumActive => 'Premium etkin';

  @override
  String get historyTitle => 'Son ödevler';

  @override
  String get historyEmpty => 'Açıklanan ödevleriniz burada görünecek.';

  @override
  String get analyzing => 'Ödev okunuyor…';

  @override
  String get errorGeneric => 'Bir sorun oluştu. Lütfen tekrar deneyin.';

  @override
  String get errorBusy =>
      'Hizmet şu anda yoğun. Lütfen bir dakika sonra tekrar deneyin.';

  @override
  String get errorNetwork =>
      'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String get unreadableTitle => 'Ödev okunamadı';

  @override
  String get resultTaskTitle => 'Ödevde ne isteniyor';

  @override
  String get resultOriginal => 'Orijinal (Almanca)';

  @override
  String get resultHowToExplain => 'Nasıl açıklanır';

  @override
  String get resultSteps => 'Çocuğunuzla adım adım';

  @override
  String stepN(int n) {
    return '$n. adım';
  }

  @override
  String get askChild => 'Çocuğunuza sorun (Almanca):';

  @override
  String get showNextStep => 'Sonraki adımı göster';

  @override
  String get vocabulary => 'Önemli Almanca kelimeler';

  @override
  String get showSolution => 'Çözümü göster (sadece sizin için)';

  @override
  String get hideSolution => 'Çözümü gizle';

  @override
  String get solutionWarning =>
      'Önce adımları deneyin – çocuğunuz cevabı kendisi bulursa daha çok öğrenir.';

  @override
  String get checkCorrect => 'Doğru görünüyor!';

  @override
  String get checkWrong => 'Bir hata var';

  @override
  String get lowConfidence =>
      'Bu konuda tam emin değiliz. Lütfen bir kez daha kontrol edin.';

  @override
  String get aiDisclaimer =>
      'Bu açıklama yapay zekâ tarafından oluşturuldu ve hata içerebilir.';

  @override
  String get reportProblem => 'Hata bildir';

  @override
  String get reportThanks => 'Teşekkürler! İnceleyeceğiz.';

  @override
  String get limitReachedTitle => 'Ücretsiz haklar bitti';

  @override
  String get limitReachedBody =>
      'Bu haftaki ücretsiz ödev haklarınızı kullandınız. Premium ile sınırsız açıklama alırsınız.';

  @override
  String get upgrade => 'Premium al';

  @override
  String get paywallTitle => 'HausiHelfer Premium';

  @override
  String get paywallSubtitle =>
      'Çocuğunuza her gün yardım edin – kendi dilinizde.';

  @override
  String get paywallBenefit1 => 'Sınırsız ödev açıklaması';

  @override
  String get paywallBenefit2 => 'Çocuğunuzun çözümlerini kontrol edin';

  @override
  String get paywallBenefit3 => 'Tüm dersler ve 1–13. sınıflar';

  @override
  String get paywallTrial =>
      '7 gün ücretsiz deneyin, istediğiniz zaman iptal edin.';

  @override
  String get restorePurchases => 'Satın alımları geri yükle';

  @override
  String get restored => 'Satın alımlar geri yüklendi.';

  @override
  String get nothingToRestore => 'Satın alım bulunamadı.';

  @override
  String get purchaseFailed => 'Satın alma tamamlanamadı.';

  @override
  String get paywallUnavailable => 'Abonelikler şu anda kullanılamıyor.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get profileSection => 'Profil';

  @override
  String get legalSection => 'Yasal bilgiler';

  @override
  String get imprint => 'Künye (Impressum)';

  @override
  String get privacy => 'Gizlilik politikası';

  @override
  String get terms => 'Kullanım koşulları';

  @override
  String get close => 'Kapat';
}
