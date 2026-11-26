/// Settings chosen during onboarding. Contains no personal data about the child.
class Profile {
  const Profile({
    required this.language,
    required this.bundesland,
    required this.schoolType,
    required this.grade,
  });

  final String language; // de, pl, en, tr, uk, ru, ar
  final String bundesland; // BW, BY, ...
  final String schoolType; // grundschule, gymnasium, ...
  final int grade; // 1-13

  Map<String, dynamic> toJson() => {
        'language': language,
        'bundesland': bundesland,
        'schoolType': schoolType,
        'grade': grade,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        language: j['language'] as String,
        bundesland: j['bundesland'] as String,
        schoolType: j['schoolType'] as String,
        grade: j['grade'] as int,
      );

  Profile copyWith({String? language, String? bundesland, String? schoolType, int? grade}) =>
      Profile(
        language: language ?? this.language,
        bundesland: bundesland ?? this.bundesland,
        schoolType: schoolType ?? this.schoolType,
        grade: grade ?? this.grade,
      );
}

const supportedLanguages = {
  'de': 'Deutsch',
  'pl': 'Polski',
  'en': 'English',
  'tr': 'Türkçe',
  'uk': 'Українська',
  'ru': 'Русский',
  'ar': 'العربية',
};

/// Bundesland names are proper nouns and stay in German in every language.
const bundeslaender = {
  'BW': 'Baden-Württemberg',
  'BY': 'Bayern',
  'BE': 'Berlin',
  'BB': 'Brandenburg',
  'HB': 'Bremen',
  'HH': 'Hamburg',
  'HE': 'Hessen',
  'MV': 'Mecklenburg-Vorpommern',
  'NI': 'Niedersachsen',
  'NW': 'Nordrhein-Westfalen',
  'RP': 'Rheinland-Pfalz',
  'SL': 'Saarland',
  'SN': 'Sachsen',
  'ST': 'Sachsen-Anhalt',
  'SH': 'Schleswig-Holstein',
  'TH': 'Thüringen',
};

const schoolTypes = [
  'grundschule',
  'gymnasium',
  'realschule',
  'hauptschule',
  'gesamtschule',
  'oberschule',
];

const subjects = ['mathe', 'deutsch', 'englisch', 'sachunterricht', 'other'];
