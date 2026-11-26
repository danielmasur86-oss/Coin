import '../l10n/gen/app_localizations.dart';

String subjectLabel(AppLocalizations l, String subject) => switch (subject) {
      'mathe' => l.subjectMathe,
      'deutsch' => l.subjectDeutsch,
      'englisch' => l.subjectEnglisch,
      'sachunterricht' => l.subjectSachunterricht,
      _ => l.subjectOther,
    };

String schoolTypeLabel(AppLocalizations l, String type) => switch (type) {
      'grundschule' => l.schoolGrundschule,
      'gymnasium' => l.schoolGymnasium,
      'realschule' => l.schoolRealschule,
      'hauptschule' => l.schoolHauptschule,
      'gesamtschule' => l.schoolGesamtschule,
      _ => l.schoolOberschule,
    };
