# 📚 HausiHelfer – pomoc w niemieckich zadaniach domowych (Android + iOS)

Aplikacja dla rodziców w Niemczech, szczególnie tych, którzy słabo znają niemiecki.
Rodzic robi zdjęcie zadania, a aplikacja:

1. tłumaczy polecenie na język rodzica,
2. podpowiada, **jak wytłumaczyć** zadanie dziecku,
3. daje **kroki z pytaniami po niemiecku**, które rodzic zadaje dziecku (z tłumaczeniem),
4. pokazuje ważne niemieckie słówka,
5. trzyma **rozwiązanie ukryte** pod przyciskiem (tylko dla rodzica),
6. w trybie **„Sprawdź rozwiązanie”** szuka błędu w zrobionym zadaniu, ale nie podaje gotowego wyniku.

Języki interfejsu i wyjaśnień: 🇩🇪 niemiecki, 🇵🇱 polski, 🇬🇧 angielski, 🇹🇷 turecki,
🇺🇦 ukraiński, 🇷🇺 rosyjski, 🇸🇦 arabski (układ od prawej do lewej).

> Nazwa „HausiHelfer” jest robocza. Przed publikacją sprawdź ją w rejestrze znaków
> towarowych (DPMA, EUIPO) oraz w App Store i Google Play.

## Jak to działa

```
Telefon (Flutter)  ──zdjęcie──▶  Twój backend (Node.js)  ──▶  Claude API (AI)
     │                               │
     └── zakupy: RevenueCat ◀────────┘ (backend sprawdza, czy użytkownik ma Premium)
```

Klucz do AI jest **tylko na serwerze**. Gdyby był w aplikacji, ktoś mógłby go wyciągnąć
i korzystać z AI na Twój koszt.

## Struktura

```
hausihelfer/
├── app/                      – aplikacja Flutter (Android + iOS)
│   ├── lib/main.dart         – start aplikacji, języki, motyw
│   ├── lib/screens/          – ekrany: start, główny, wynik, paywall, ustawienia
│   ├── lib/services/         – połączenie z backendem, zakupy, pamięć lokalna
│   ├── lib/l10n/app_*.arb    – teksty w 7 językach
│   └── test/                 – testy
└── backend/                  – serwer (Node.js + TypeScript)
    ├── src/server.ts         – endpointy /v1/explain i /v1/quota
    ├── src/explain.ts        – zapytanie do AI (zdjęcie → wyjaśnienie w formacie JSON)
    ├── src/prompt.ts         – instrukcje dla AI (niemieckie metody szkolne, nie zdradzaj wyniku)
    ├── src/quota.ts          – darmowy limit (3 zadania tygodniowo)
    └── src/premium.ts        – sprawdzanie abonamentu w RevenueCat
```

## Uruchomienie lokalne

### Backend
```bash
cd hausihelfer/backend
npm install
cp .env.example .env          # wpisz ANTHROPIC_API_KEY
npm test                      # testy (nie kosztują nic, nie wołają AI)
npm run dev                   # serwer na http://localhost:8080
```
Na produkcji: `docker build -t hausihelfer-backend .` i hosting w UE (np. Hetzner, Scaleway,
Google Cloud Run w regionie europe-west3 Frankfurt). To ważne ze względu na RODO.

### Aplikacja
Potrzebujesz Fluttera 3.50+, Android Studio (dla Androida) i Maca z Xcode (dla iOS).
```bash
cd hausihelfer/app
flutter pub get
flutter test
# emulator Androida (10.0.2.2 = Twój komputer):
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
# symulator iOS:
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```
Wersja do sklepów:
```bash
flutter build appbundle --dart-define=API_BASE_URL=https://api.twojadomena.de \
  --dart-define=RC_API_KEY_ANDROID=goog_xxx --dart-define=LEGAL_BASE_URL=https://twojadomena.de
flutter build ipa --dart-define=API_BASE_URL=https://api.twojadomena.de \
  --dart-define=RC_API_KEY_IOS=appl_xxx --dart-define=LEGAL_BASE_URL=https://twojadomena.de
```

## Zarabianie

| Plan | Cena (propozycja) | Co daje |
|---|---|---|
| Darmowy | 0 € | 3 zadania tygodniowo |
| Premium miesięczny | 7,99 € | bez limitu, sprawdzanie rozwiązań |
| Premium roczny | 59,99 € (zaznaczony domyślnie) | to samo, ok. 37% taniej |

Oba plany z 7-dniowym darmowym okresem próbnym.

**Konfiguracja zakupów (RevenueCat):**
1. Załóż konto na revenuecat.com i dodaj aplikację iOS oraz Android.
2. W App Store Connect i Google Play Console utwórz dwie subskrypcje (miesięczną i roczną) z okresem próbnym.
3. W RevenueCat utwórz uprawnienie (*entitlement*) `premium`, podepnij do niego obie subskrypcje i ułóż je w *Offering* „default”.
4. Publiczne klucze SDK przekaż do aplikacji (`RC_API_KEY_IOS`, `RC_API_KEY_ANDROID`), a klucz *secret* do backendu (`REVENUECAT_SECRET_KEY`).

**Prowizja sklepów:** Apple i Google pobierają 15% w programie dla małych firm (do 1 mln USD rocznie).
W UE sklepy rozliczają VAT za Ciebie.

## Koszt AI – przeczytaj przed ustaleniem cen

Każde zdjęcie to jedno zapytanie do AI. Domyślnie używany jest najmocniejszy model
`claude-opus-5-5` ($4 / $20 za milion tokenów wejścia / wyjścia) z wysiłkiem `medium`.
Szacunkowo to **kilka centów za zadanie**: zdjęcie i instrukcje to ok. 2–3 tys. tokenów,
a odpowiedź z rozumowaniem to kilka tysięcy. Dokładny koszt sprawdź na kilkudziesięciu
prawdziwych zadaniach w panelu console.anthropic.com.

Model zmienisz bez zmiany kodu, zmienną `CLAUDE_MODEL`:
- `claude-sonnet-5-5` – ok. 2 razy tańszy,
- `claude-haiku-5-5` – kilkadziesiąt razy tańszy.

Przed zmianą sprawdź jakość na prawdziwych zdjęciach, szczególnie przy matematyce
i pisanych ręcznie zadaniach. Rozważ też limit „fair use” w Premium (np. 15 zadań dziennie),
żeby jeden użytkownik nie przekroczył kosztami swojego abonamentu.

## Prawo w Niemczech – lista przed publikacją

- [ ] **Impressum** – dane firmy na stronie (`/impressum`) i w aplikacji (Ustawienia). W Niemczech to obowiązek.
- [ ] **Datenschutzerklärung** (polityka prywatności, RODO/DSGVO) po niemiecku: zdjęcia są wysyłane do przetworzenia przez AI (Anthropic, USA, umowa DPA i standardowe klauzule umowne), a backend jest w UE.
- [ ] **AGB** (regulamin) po niemiecku.
- [ ] Informacja, że wyjaśnienia tworzy AI (jest w aplikacji; wymaga tego unijny AI Act).
- [ ] Konto i zakupy tylko dla dorosłego rodzica. **Nie** zgłaszaj aplikacji do kategorii „dla dzieci” (Kids), bo tam obowiązują dużo ostrzejsze zasady.
- [ ] Ankiety o prywatności w sklepach: App Privacy w App Store oraz Data safety w Google Play.
- [ ] Opis aplikacji w sklepach w każdym obsługiwanym języku.
- [ ] Podatki i forma firmy: porozmawiaj z księgowym (np. polska JDG sprzedająca przez sklepy).

Linki do stron prawnych ustawiasz zmienną `LEGAL_BASE_URL`. Aplikacja otwiera
`/impressum`, `/datenschutz` i `/agb`.

## Co jeszcze zrobić przed startem

1. **Licznik darmowych zadań w bazie danych.** Teraz jest w pamięci serwera i zeruje się po restarcie, co wystarczy na testy. Na produkcję potrzebny jest Redis albo baza danych.
2. **Ochrona przed nadużyciami.** Identyfikator użytkownika generuje aplikacja. Dla lepszej ochrony dodaj Firebase App Check albo Apple App Attest i Google Play Integrity.
3. **Ikona, ekran startowy, zrzuty ekranu do sklepów.**
4. **Testy z prawdziwymi rodzicami** (np. z grup na Facebooku „Polacy w Niemczech”): czy wyjaśnienia są zrozumiałe i zgodne z tym, czego uczą w szkole.
5. **Teksty uprawnień iOS** (aparat, zdjęcia) są teraz tylko po niemiecku. Można dodać `InfoPlist.strings` dla pozostałych języków.
