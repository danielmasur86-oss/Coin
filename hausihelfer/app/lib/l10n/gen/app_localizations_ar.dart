// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'HausiHelfer';

  @override
  String get onboardingTitle => 'مساعدة في الواجبات المدرسية الألمانية';

  @override
  String get onboardingSubtitle =>
      'صوّر الواجب. نشرحه لك بالعربية ونوضح لك كيف تساعد طفلك خطوة بخطوة.';

  @override
  String get chooseLanguage => 'لغتك';

  @override
  String get chooseState => 'الولاية (Bundesland)';

  @override
  String get chooseSchoolType => 'نوع المدرسة';

  @override
  String get chooseGrade => 'الصف (Klasse)';

  @override
  String gradeLabel(int grade) {
    return 'الصف $grade';
  }

  @override
  String get continueButton => 'متابعة';

  @override
  String get save => 'حفظ';

  @override
  String get schoolGrundschule => 'المدرسة الابتدائية (Grundschule)';

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
  String get subjectLabel => 'المادة';

  @override
  String get subjectMathe => 'الرياضيات';

  @override
  String get subjectDeutsch => 'اللغة الألمانية';

  @override
  String get subjectEnglisch => 'اللغة الإنجليزية';

  @override
  String get subjectSachunterricht => 'العلوم (Sachunterricht)';

  @override
  String get subjectOther => 'أخرى';

  @override
  String get modeExplain => 'اشرح الواجب';

  @override
  String get modeCheck => 'تحقق من الحل';

  @override
  String get modeExplainHint =>
      'صورة لواجب جديد: ستحصل على الترجمة وتلميحات خطوة بخطوة.';

  @override
  String get modeCheckHint =>
      'صورة لواجب أنهاه طفلك: نبحث عن الأخطاء دون إعطاء الإجابة.';

  @override
  String get takePhoto => 'التقط صورة';

  @override
  String get fromGallery => 'من المعرض';

  @override
  String freeLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تبقّى لك $count واجبًا مجانيًا هذا الأسبوع',
      few: 'تبقّى لك $count واجبات مجانية هذا الأسبوع',
      two: 'تبقّى لك واجبان مجانيان هذا الأسبوع',
      one: 'تبقّى لك واجب مجاني واحد هذا الأسبوع',
      zero: 'لم يتبقَّ لك واجبات مجانية هذا الأسبوع',
    );
    return '$_temp0';
  }

  @override
  String get premiumActive => 'Premium مفعّل';

  @override
  String get historyTitle => 'الواجبات الأخيرة';

  @override
  String get historyEmpty => 'ستظهر هنا الواجبات التي تم شرحها.';

  @override
  String get analyzing => 'جارٍ قراءة الواجب…';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorBusy => 'الخدمة مشغولة حاليًا. يرجى المحاولة بعد دقيقة.';

  @override
  String get errorNetwork => 'لا يوجد اتصال بالخادم. تحقق من الإنترنت.';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get unreadableTitle => 'تعذّرت قراءة الواجب';

  @override
  String get resultTaskTitle => 'ما المطلوب في الواجب';

  @override
  String get resultOriginal => 'النص الأصلي (بالألمانية)';

  @override
  String get resultHowToExplain => 'كيف تشرحه';

  @override
  String get resultSteps => 'خطوة بخطوة مع طفلك';

  @override
  String stepN(int n) {
    return 'الخطوة $n';
  }

  @override
  String get askChild => 'اسأل طفلك (بالألمانية):';

  @override
  String get showNextStep => 'أظهر الخطوة التالية';

  @override
  String get vocabulary => 'كلمات ألمانية مهمة';

  @override
  String get showSolution => 'أظهر الحل (لك فقط)';

  @override
  String get hideSolution => 'إخفاء الحل';

  @override
  String get solutionWarning =>
      'جرّب الخطوات أولًا – يتعلم طفلك أكثر عندما يجد الإجابة بنفسه.';

  @override
  String get checkCorrect => 'يبدو صحيحًا!';

  @override
  String get checkWrong => 'يوجد خطأ';

  @override
  String get lowConfidence => 'لسنا متأكدين تمامًا هنا. يرجى التحقق مرة أخرى.';

  @override
  String get aiDisclaimer =>
      'تم إنشاء هذا الشرح بواسطة الذكاء الاصطناعي وقد يحتوي على أخطاء.';

  @override
  String get reportProblem => 'الإبلاغ عن خطأ';

  @override
  String get reportThanks => 'شكرًا لك! سنراجع ذلك.';

  @override
  String get limitReachedTitle => 'انتهت الواجبات المجانية';

  @override
  String get limitReachedBody =>
      'لقد استخدمت واجباتك المجانية لهذا الأسبوع. مع Premium تحصل على شروح غير محدودة.';

  @override
  String get upgrade => 'احصل على Premium';

  @override
  String get paywallTitle => 'HausiHelfer Premium';

  @override
  String get paywallSubtitle => 'ساعد طفلك كل يوم – بلغتك.';

  @override
  String get paywallBenefit1 => 'شروح غير محدودة للواجبات';

  @override
  String get paywallBenefit2 => 'التحقق من حلول طفلك';

  @override
  String get paywallBenefit3 => 'جميع المواد والصفوف 1–13';

  @override
  String get paywallTrial =>
      'جرّبه مجانًا لمدة 7 أيام، ويمكنك الإلغاء في أي وقت.';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get restored => 'تمت استعادة المشتريات.';

  @override
  String get nothingToRestore => 'لم يتم العثور على مشتريات.';

  @override
  String get purchaseFailed => 'تعذّر إتمام عملية الشراء.';

  @override
  String get paywallUnavailable => 'الاشتراكات غير متاحة حاليًا.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get profileSection => 'الملف الشخصي';

  @override
  String get legalSection => 'معلومات قانونية';

  @override
  String get imprint => 'بيانات الناشر (Impressum)';

  @override
  String get privacy => 'سياسة الخصوصية';

  @override
  String get terms => 'شروط الاستخدام';

  @override
  String get close => 'إغلاق';

  @override
  String get errorDailyLimit => 'لقد وصلت إلى الحد اليومي. يرجى المتابعة غدًا.';

  @override
  String get reportHint => 'ما الخطأ؟ (اختياري)';

  @override
  String get send => 'إرسال';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deleteData => 'حذف بياناتي';

  @override
  String get deleteDataConfirm =>
      'سيؤدي هذا إلى حذف سجل الواجبات والإعدادات على هذا الجهاز. يبقى اشتراكك فعّالًا.';

  @override
  String get deleteDataDone => 'تم حذف بياناتك.';

  @override
  String get delete => 'حذف';

  @override
  String get manageSubscription => 'إدارة الاشتراك';

  @override
  String get planMonthly => 'شهريًا';

  @override
  String get planYearly => 'سنويًا';

  @override
  String get paywallLegal =>
      'يتجدد الاشتراك تلقائيًا ما لم يتم إلغاؤه قبل 24 ساعة على الأقل من نهاية الفترة. يمكنك الإلغاء في أي وقت من إعدادات حسابك في App Store أو Google Play.';

  @override
  String get solutionTitle => 'الحل';
}
