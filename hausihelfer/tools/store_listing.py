"""Store texts for App Store and Google Play in 7 languages, written in the folder layout
that `fastlane deliver` (iOS) and `fastlane supply` (Android) upload automatically.

Run from hausihelfer/:  python3 tools/store_listing.py
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "store-listing"

T = {
    "de": dict(
        subtitle="Hausaufgaben verstehen",
        short="Foto der Hausaufgabe – Erklärung in Ihrer Sprache. Für Eltern in Deutschland.",
        keywords="hausaufgaben,eltern,mathe,deutsch,schule,grundschule,lernen,erklärung,übersetzung,nachhilfe",
        promo="Hausaufgaben fotografieren und Ihrem Kind Schritt für Schritt helfen – auch ohne perfektes Deutsch.",
        body="""Ihr Kind sitzt bei den Hausaufgaben fest und Sie wissen nicht, wie Sie helfen sollen? HausiHelfer erklärt Ihnen die Aufgabe – einfach, Schritt für Schritt und in Ihrer Sprache.

SO FUNKTIONIERT ES
1. Fotografieren Sie die Hausaufgabe.
2. Sie lesen, was die Aufgabe verlangt, und wie Sie es erklären können.
3. Sie stellen Ihrem Kind kurze Fragen auf Deutsch – Ihr Kind findet die Lösung selbst.

WARUM HAUSIHELFER
• Für Eltern gemacht: Sie bekommen Hinweise zum Erklären, nicht nur ein Ergebnis zum Abschreiben.
• Nach deutschen Lehrplänen: Rechenwege und Begriffe wie in der Schule Ihres Kindes, für alle 16 Bundesländer.
• In 7 Sprachen: Deutsch, Polnisch, Englisch, Türkisch, Ukrainisch, Russisch und Arabisch.
• Lösung prüfen: Fotografieren Sie die fertige Aufgabe – wir zeigen, wo der Fehler ist, ohne die Lösung zu verraten.
• Wichtige Wörter: Die deutschen Fachbegriffe der Aufgabe mit Übersetzung.
• Mathe, Deutsch, Englisch, Sachunterricht – Klasse 1 bis 13.

KOSTENLOS UND PREMIUM
3 Aufgaben pro Woche sind kostenlos. Mit Premium erklären Sie unbegrenzt viele Aufgaben (faire Nutzung) und prüfen Lösungen. 7 Tage kostenlos testen, jederzeit kündbar.

Die Erklärungen werden von künstlicher Intelligenz erstellt und können Fehler enthalten. Fotos werden nicht gespeichert. Kein Konto nötig.""",
    ),
    "pl": dict(
        subtitle="Niemieckie zadania domowe",
        short="Zdjęcie zadania z niemieckiej szkoły – wyjaśnienie po polsku. Dla rodziców.",
        keywords="zadania domowe,niemiecki,szkoła,rodzice,matematyka,Niemcy,tłumaczenie,nauka,korepetycje",
        promo="Zrób zdjęcie niemieckiego zadania i pomóż dziecku krok po kroku – po polsku.",
        body="""Dziecko chodzi do niemieckiej szkoły, utknęło przy zadaniu domowym, a Ty nie wiesz, jak pomóc? HausiHelfer wytłumaczy Ci zadanie po polsku – prosto i krok po kroku.

JAK TO DZIAŁA
1. Zrób zdjęcie zadania.
2. Przeczytasz po polsku, o co chodzi w zadaniu i jak to wytłumaczyć.
3. Zadajesz dziecku krótkie pytania po niemiecku – dziecko samo dochodzi do wyniku.

DLACZEGO HAUSIHELFER
• Dla rodziców: dostajesz wskazówki, jak tłumaczyć, a nie gotowy wynik do przepisania.
• Zgodnie z niemiecką szkołą: metody i pojęcia jak na lekcjach, dla wszystkich 16 krajów związkowych.
• 7 języków: polski, niemiecki, angielski, turecki, ukraiński, rosyjski i arabski.
• Sprawdzanie rozwiązań: zrób zdjęcie zrobionego zadania – pokażemy, gdzie jest błąd, bez podawania wyniku.
• Ważne słowa: niemieckie pojęcia z zadania z tłumaczeniem.
• Matematyka, niemiecki, angielski, przyroda (Sachunterricht) – klasy 1–13.

ZA DARMO I PREMIUM
3 zadania tygodniowo za darmo. Premium: nielimitowane wyjaśnienia (uczciwe korzystanie) i sprawdzanie rozwiązań. 7 dni za darmo, rezygnacja w każdej chwili.

Wyjaśnienia tworzy sztuczna inteligencja i mogą zawierać błędy. Zdjęcia nie są zapisywane. Nie trzeba zakładać konta.""",
    ),
    "en": dict(
        subtitle="German homework explained",
        short="Photo of German homework – explained in your language. For parents.",
        keywords="homework,german,school,parents,math,germany,translation,tutor,learning,help",
        promo="Take a photo of German homework and help your child step by step – in your language.",
        body="""Your child goes to a German school, is stuck on homework, and you don't know how to help? HausiHelfer explains the task to you – simply, step by step, in your language.

HOW IT WORKS
1. Take a photo of the homework.
2. Read what the task asks and how to explain it.
3. Ask your child short questions in German – your child finds the answer on their own.

WHY HAUSIHELFER
• Made for parents: you get guidance for explaining, not just an answer to copy.
• Follows German schools: the same methods and terms as in class, for all 16 federal states.
• 7 languages: English, German, Polish, Turkish, Ukrainian, Russian and Arabic.
• Check solutions: photograph finished work – we show where the mistake is without giving away the answer.
• Key words: the German terms from the task with translations.
• Maths, German, English, science (Sachunterricht) – grades 1 to 13.

FREE AND PREMIUM
3 tasks per week are free. Premium gives unlimited explanations (fair use) and solution checks. Try 7 days free, cancel anytime.

Explanations are created by AI and can contain mistakes. Photos are not stored. No account needed.""",
    ),
    "tr": dict(
        subtitle="Almanca ödevler anlaşılır",
        short="Alman okulundan ödevin fotoğrafı – Türkçe açıklama. Veliler için.",
        keywords="ödev,almanca,okul,veli,matematik,almanya,çeviri,ders,öğrenme,yardım",
        promo="Almanca ödevin fotoğrafını çekin ve çocuğunuza adım adım yardım edin – Türkçe.",
        body="""Çocuğunuz Alman okuluna gidiyor, ödevde takıldı ve nasıl yardım edeceğinizi bilmiyor musunuz? HausiHelfer ödevi size Türkçe, basitçe ve adım adım açıklar.

NASIL ÇALIŞIR
1. Ödevin fotoğrafını çekin.
2. Ödevde ne istendiğini ve nasıl açıklayacağınızı okuyun.
3. Çocuğunuza Almanca kısa sorular sorun – çocuğunuz cevabı kendisi bulur.

NEDEN HAUSIHELFER
• Veliler için: kopyalanacak bir cevap değil, nasıl açıklayacağınıza dair ipuçları alırsınız.
• Alman okullarına uygun: derste olduğu gibi yöntemler ve terimler, 16 eyaletin tamamı için.
• 7 dil: Türkçe, Almanca, Lehçe, İngilizce, Ukraynaca, Rusça ve Arapça.
• Çözümü kontrol edin: bitmiş ödevin fotoğrafını çekin – cevabı söylemeden hatanın yerini gösteririz.
• Önemli kelimeler: ödevdeki Almanca terimler ve çevirileri.
• Matematik, Almanca, İngilizce, hayat bilgisi (Sachunterricht) – 1. ile 13. sınıf arası.

ÜCRETSİZ VE PREMIUM
Haftada 3 ödev ücretsiz. Premium: sınırsız açıklama (adil kullanım) ve çözüm kontrolü. 7 gün ücretsiz deneyin, istediğiniz zaman iptal edin.

Açıklamalar yapay zekâ tarafından oluşturulur ve hata içerebilir. Fotoğraflar saklanmaz. Hesap gerekmez.""",
    ),
    "uk": dict(
        subtitle="Німецькі домашні завдання",
        short="Фото завдання з німецької школи – пояснення українською. Для батьків.",
        keywords="домашнє завдання,німецька,школа,батьки,математика,Німеччина,переклад,навчання",
        promo="Сфотографуйте німецьке завдання й допоможіть дитині крок за кроком – українською.",
        body="""Дитина ходить до німецької школи, застрягла на домашньому завданні, а ви не знаєте, як допомогти? HausiHelfer пояснить вам завдання українською – просто й крок за кроком.

ЯК ЦЕ ПРАЦЮЄ
1. Сфотографуйте завдання.
2. Прочитайте, що потрібно зробити і як це пояснити.
3. Ставте дитині короткі запитання німецькою – дитина сама знаходить відповідь.

ЧОМУ HAUSIHELFER
• Для батьків: ви отримуєте підказки, як пояснювати, а не готову відповідь для списування.
• За німецькою шкільною програмою: методи й терміни як на уроках, для всіх 16 федеральних земель.
• 7 мов: українська, німецька, польська, англійська, турецька, російська та арабська.
• Перевірка розв'язку: сфотографуйте виконане завдання – покажемо, де помилка, не підказуючи відповіді.
• Важливі слова: німецькі терміни із завдання з перекладом.
• Математика, німецька, англійська, природознавство (Sachunterricht) – 1–13 класи.

БЕЗКОШТОВНО ТА PREMIUM
3 завдання на тиждень безкоштовно. Premium: необмежені пояснення (чесне використання) і перевірка розв'язків. 7 днів безкоштовно, скасувати можна будь-коли.

Пояснення створює штучний інтелект, і вони можуть містити помилки. Фото не зберігаються. Обліковий запис не потрібен.""",
    ),
    "ru": dict(
        subtitle="Немецкие домашние задания",
        short="Фото задания из немецкой школы – объяснение по-русски. Для родителей.",
        keywords="домашнее задание,немецкий,школа,родители,математика,Германия,перевод,учеба",
        promo="Сфотографируйте немецкое задание и помогите ребёнку шаг за шагом – по-русски.",
        body="""Ребёнок ходит в немецкую школу, застрял на домашнем задании, а вы не знаете, как помочь? HausiHelfer объяснит вам задание по-русски – просто и шаг за шагом.

КАК ЭТО РАБОТАЕТ
1. Сфотографируйте задание.
2. Прочитайте, что нужно сделать и как это объяснить.
3. Задавайте ребёнку короткие вопросы по-немецки – ребёнок сам находит ответ.

ПОЧЕМУ HAUSIHELFER
• Для родителей: вы получаете подсказки, как объяснять, а не готовый ответ для списывания.
• По немецкой школьной программе: методы и термины как на уроках, для всех 16 федеральных земель.
• 7 языков: русский, немецкий, польский, английский, турецкий, украинский и арабский.
• Проверка решения: сфотографируйте выполненное задание – покажем, где ошибка, не подсказывая ответ.
• Важные слова: немецкие термины из задания с переводом.
• Математика, немецкий, английский, окружающий мир (Sachunterricht) – 1–13 классы.

БЕСПЛАТНО И PREMIUM
3 задания в неделю бесплатно. Premium: неограниченные объяснения (честное использование) и проверка решений. 7 дней бесплатно, отменить можно в любой момент.

Объяснения создаёт искусственный интеллект, и они могут содержать ошибки. Фото не сохраняются. Аккаунт не нужен.""",
    ),
    "ar": dict(
        subtitle="شرح الواجبات الألمانية",
        short="صوّر واجب المدرسة الألمانية – واحصل على شرح بالعربية. للآباء والأمهات.",
        keywords="واجبات,ألماني,مدرسة,أهل,رياضيات,ألمانيا,ترجمة,تعليم,مساعدة",
        promo="صوّر الواجب الألماني وساعد طفلك خطوة بخطوة – بالعربية.",
        body="""طفلك يذهب إلى مدرسة ألمانية وتوقف عند واجب منزلي ولا تعرف كيف تساعده؟ يشرح لك HausiHelfer الواجب بالعربية – ببساطة وخطوة بخطوة.

كيف يعمل
1. صوّر الواجب.
2. اقرأ ما المطلوب في الواجب وكيف تشرحه.
3. اطرح على طفلك أسئلة قصيرة بالألمانية – ويجد طفلك الإجابة بنفسه.

لماذا HausiHelfer
• مصمم للأهل: تحصل على إرشادات للشرح، وليس مجرد إجابة للنسخ.
• وفق المدارس الألمانية: نفس الطرق والمصطلحات كما في الصف، لجميع الولايات الـ16.
• 7 لغات: العربية والألمانية والبولندية والإنجليزية والتركية والأوكرانية والروسية.
• التحقق من الحل: صوّر الواجب المنجز – نوضح مكان الخطأ دون إعطاء الإجابة.
• كلمات مهمة: المصطلحات الألمانية من الواجب مع ترجمتها.
• الرياضيات والألمانية والإنجليزية والعلوم (Sachunterricht) – من الصف 1 إلى 13.

مجاني و Premium
3 واجبات أسبوعيًا مجانًا. مع Premium شروح غير محدودة (استخدام عادل) والتحقق من الحلول. جرّبه مجانًا لمدة 7 أيام، ويمكنك الإلغاء في أي وقت.

يتم إنشاء الشروح بواسطة الذكاء الاصطناعي وقد تحتوي على أخطاء. لا يتم حفظ الصور. لا حاجة لإنشاء حساب.""",
    ),
}

APPLE_LOCALE = {"de": "de-DE", "pl": "pl", "en": "en-US", "tr": "tr", "uk": "uk", "ru": "ru", "ar": "ar-SA"}
PLAY_LOCALE = {"de": "de-DE", "pl": "pl-PL", "en": "en-US", "tr": "tr-TR", "uk": "uk", "ru": "ru-RU", "ar": "ar"}
NAME = "HausiHelfer"


def check(lang: str, field: str, value: str, limit: int) -> None:
    if len(value) > limit:
        raise SystemExit(f"{lang}.{field} is {len(value)} chars, limit {limit}: {value!r}")


def write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.strip() + "\n", encoding="utf-8")


def main() -> None:
    for lang, t in T.items():
        check(lang, "subtitle", t["subtitle"], 30)
        check(lang, "short", t["short"], 80)
        check(lang, "keywords", t["keywords"], 100)
        check(lang, "promo", t["promo"], 170)
        check(lang, "body", t["body"], 4000)

        ios = ROOT / "ios/metadata" / APPLE_LOCALE[lang]
        write(ios / "name.txt", NAME)
        write(ios / "subtitle.txt", t["subtitle"])
        write(ios / "description.txt", t["body"])
        write(ios / "keywords.txt", t["keywords"])
        write(ios / "promotional_text.txt", t["promo"])

        play = ROOT / "android/metadata" / PLAY_LOCALE[lang]
        write(play / "title.txt", NAME)
        write(play / "short_description.txt", t["short"])
        write(play / "full_description.txt", t["body"])
    print(f"store texts written to {ROOT}")


if __name__ == "__main__":
    main()
