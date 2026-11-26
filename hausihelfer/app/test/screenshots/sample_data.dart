/// Example explanations used only for the store screenshots (one per language).
/// The German parts (task, questions, words) are the same; the rest is in the parent's language.
const _task = 'Schreibe die Aufgabe schriftlich und rechne: 756 : 3';
const _q = ['Wie oft passt die 3 in die 7?', 'Wie viel bleibt übrig? Hol die nächste Ziffer herunter.', 'Wie oft passt die 3 in die 15?'];
const _words = ['schriftlich dividieren', 'der Rest', 'die Ziffer'];

Map<String, dynamic> _make({
  required String translation,
  required String topic,
  required String how,
  required List<String> hints,
  required List<String> qTranslations,
  required List<String> wordTranslations,
}) =>
    {
      'readable': true,
      'task_original_de': _task,
      'task_translation': translation,
      'topic': topic,
      'topic_de': 'Schriftliche Division',
      'how_to_explain': how,
      'steps': [
        for (var i = 0; i < 3; i++)
          {'parent_hint': hints[i], 'ask_child_de': _q[i], 'ask_child_translation': qTranslations[i]},
      ],
      'german_vocabulary': [
        for (var i = 0; i < 3; i++) {'de': _words[i], 'translation': wordTranslations[i]},
      ],
      'solution': '756 : 3 = 252',
      'check': {'is_correct': null, 'feedback': ''},
      'confidence': 'high',
    };

final sampleExplanations = <String, Map<String, dynamic>>{
  'de': _make(
    translation: 'Ihr Kind soll 756 durch 3 teilen, und zwar schriftlich untereinander.',
    topic: 'Schriftliche Division',
    how: 'Man teilt von links nach rechts, Ziffer für Ziffer. Lassen Sie Ihr Kind jeden Schritt laut sagen.',
    hints: ['Beginnen Sie mit der ersten Ziffer: 7.', 'Der Rest wird mit der nächsten Ziffer zusammengeschrieben.', 'Jetzt mit 15 weitermachen.'],
    qTranslations: ['', '', ''],
    wordTranslations: ['schriftlich teilen', 'was übrig bleibt', 'eine einzelne Zahl 0–9'],
  ),
  'pl': _make(
    translation: 'Dziecko ma podzielić 756 przez 3 pisemnie, czyli w słupku.',
    topic: 'Dzielenie pisemne',
    how: 'Dzielimy od lewej do prawej, cyfra po cyfrze. Niech dziecko mówi każdy krok na głos.',
    hints: ['Zacznijcie od pierwszej cyfry: 7.', 'Resztę zapisuje się razem z następną cyfrą.', 'Teraz dzielicie 15.'],
    qTranslations: ['Ile razy 3 mieści się w 7?', 'Ile zostaje? Sprowadź następną cyfrę.', 'Ile razy 3 mieści się w 15?'],
    wordTranslations: ['dzielić pisemnie', 'reszta', 'cyfra'],
  ),
  'en': _make(
    translation: 'Your child has to divide 756 by 3 using written long division.',
    topic: 'Long division',
    how: 'Divide from left to right, one digit at a time. Let your child say each step out loud.',
    hints: ['Start with the first digit: 7.', 'The remainder is written together with the next digit.', 'Now continue with 15.'],
    qTranslations: ['How many times does 3 go into 7?', 'What is left over? Bring down the next digit.', 'How many times does 3 go into 15?'],
    wordTranslations: ['to do long division', 'the remainder', 'the digit'],
  ),
  'tr': _make(
    translation: 'Çocuğunuz 756\'yı 3\'e alt alta yazarak bölmeli.',
    topic: 'Yazılı bölme',
    how: 'Soldan sağa, basamak basamak bölünür. Çocuğunuzun her adımı yüksek sesle söylemesini isteyin.',
    hints: ['İlk basamakla başlayın: 7.', 'Kalan, bir sonraki basamakla birlikte yazılır.', 'Şimdi 15 ile devam edin.'],
    qTranslations: ['3, 7\'nin içinde kaç kere var?', 'Ne kadar kaldı? Sonraki basamağı aşağı indir.', '3, 15\'in içinde kaç kere var?'],
    wordTranslations: ['yazılı bölmek', 'kalan', 'rakam'],
  ),
  'uk': _make(
    translation: 'Дитина має поділити 756 на 3 письмово, у стовпчик.',
    topic: 'Письмове ділення',
    how: 'Ділимо зліва направо, цифра за цифрою. Нехай дитина вголос називає кожен крок.',
    hints: ['Почніть з першої цифри: 7.', 'Остачу записують разом з наступною цифрою.', 'Тепер продовжуйте з 15.'],
    qTranslations: ['Скільки разів 3 вміщається в 7?', 'Скільки залишилось? Знеси наступну цифру.', 'Скільки разів 3 вміщається в 15?'],
    wordTranslations: ['ділити письмово', 'остача', 'цифра'],
  ),
  'ru': _make(
    translation: 'Ребёнку нужно разделить 756 на 3 письменно, в столбик.',
    topic: 'Деление в столбик',
    how: 'Делим слева направо, цифра за цифрой. Пусть ребёнок проговаривает каждый шаг вслух.',
    hints: ['Начните с первой цифры: 7.', 'Остаток записывают вместе со следующей цифрой.', 'Теперь продолжайте с 15.'],
    qTranslations: ['Сколько раз 3 помещается в 7?', 'Сколько осталось? Снеси следующую цифру.', 'Сколько раз 3 помещается в 15?'],
    wordTranslations: ['делить в столбик', 'остаток', 'цифра'],
  ),
  'ar': _make(
    translation: 'على طفلك أن يقسم 756 على 3 بطريقة القسمة المطوّلة المكتوبة.',
    topic: 'القسمة المطوّلة',
    how: 'نقسم من اليسار إلى اليمين، رقمًا بعد رقم. اطلب من طفلك أن يقول كل خطوة بصوت عالٍ.',
    hints: ['ابدأ بالرقم الأول: 7.', 'يُكتب الباقي مع الرقم التالي.', 'تابع الآن مع 15.'],
    qTranslations: ['كم مرة يدخل 3 في 7؟', 'كم يتبقى؟ أنزل الرقم التالي.', 'كم مرة يدخل 3 في 15؟'],
    wordTranslations: ['القسمة المكتوبة', 'الباقي', 'الرقم'],
  ),
};
