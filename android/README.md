# ⛏️ Imperium Kopalni – Android (Google Play)

Aplikacja w Kotlinie, w której działa wspólna gra z `game-web/index.html` (ta sama co wersja testowa w przeglądarce). Natywnie obsługiwane są:

| Usługa | Do czego | Plik |
|---|---|---|
| Google Play Billing 8 | zakupy diamentów i ulepszeń | `BillingManager.kt` |
| AdMob – reklamy za nagrodę | boost x2, diamenty, podwójny dochód offline | `AdsManager.kt` |
| Google UMP | okno zgody RODO (wymagane w UE) | `AdsManager.kt` |
| Firebase Analytics | statystyki: kto gra, gdzie odpada, co kupuje | `Analytics.kt` |

## Co jest w grze

- **Kopalnie i prestiż:** po zarobieniu 💰1M można przenieść się do kolejnej kopalni (Węgiel → Miedź → Srebro → Złoto → Kryształy → Diamenty → Głębia…). Urobek jest 4× cenniejszy, a sztabki złota 🥇 dają +10% dochodu na zawsze każda.
- **Reklamy za nagrodę:** boost x2 na 30 min (do 4 h zapasu), 5 💎 za reklamę (5 razy dziennie), podwójny dochód offline.
- **Nagroda dzienna:** 7-dniowa seria, 7. dzień to 💎30, a przerwa zeruje serię.
- **Zadania dzienne:** 3 losowe zadania dziennie po 4–8 💎 i premia 💎10 za komplet.
- **Zakupy:** pakiety diamentów oraz „Podwójny dochód” i „Sejf offline” na zawsze.

## Test na telefonie (bez Android Studio)

1. Na GitHubie wejdź w **Actions → Android build →** ostatnie uruchomienie.
2. Na dole, w sekcji **Artifacts**, pobierz `imperium-kopalni-test-apk` (to plik ZIP z APK).
3. Wyślij APK na telefon i zainstaluj (Android zapyta o zgodę na instalację z nieznanych źródeł).

W wersji testowej reklamy są **testowymi reklamami Google** (napis „Test Ad”). Zakupy pokażą błąd „sklep niedostępny”, bo Google Play obsługuje płatności dopiero dla aplikacji wgranej do Play Console (patrz krok 5 niżej).

## Publikacja w Google Play – krok po kroku

### 1. Konto
- Załóż konto **Google Play Console**: <https://play.google.com/console>. To jednorazowa opłata 25 USD.
- Nowe konta osobiste muszą przejść **test zamknięty z co najmniej 12 testerami przez 14 dni**, zanim dostaną dostęp do produkcji. Zbierz znajomych z Androidem. Konto firmowe (organizacja) tego wymogu nie ma.
- Załóż **profil płatności** (Ustawienia → Profil płatności), żeby sprzedawać produkty w aplikacji.

### 2. Własny identyfikator aplikacji
Zmień `com.twojafirma.imperiumkopalni` na swój (np. `pl.jankowalski.imperiumkopalni`) w `android/app/build.gradle.kts` (`applicationId`). **Po pierwszej publikacji nie da się go zmienić.**

### 3. Klucz podpisu
```bash
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias imperium
base64 -w0 release.jks   # wynik wklej jako sekret KEYSTORE_BASE64
```
W repozytorium na GitHubie: **Settings → Secrets and variables → Actions** dodaj `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS` (`imperium`) i `KEY_PASSWORD`.
**Zrób kopię `release.jks` i haseł w bezpiecznym miejscu.** Do pliku nie commituj (jest w `.gitignore`).
Od tej chwili GitHub Actions zbuduje też `imperium-kopalni-release-aab`, czyli plik do wgrania w Google Play.

### 4. AdMob (zarabianie na reklamach)
1. <https://admob.google.com> → dodaj aplikację (Android) → skopiuj **App ID** (`ca-app-pub-…~…`).
2. Dodaj blok reklamowy **„Z nagrodą” (Rewarded)** → skopiuj jego ID (`ca-app-pub-…/…`).
3. Dodaj sekrety `ADMOB_APP_ID` i `ADMOB_REWARDED_ID`. Bez nich wersja release używa reklam testowych, które nic nie zarabiają.
4. W AdMob → **Prywatność i wiadomości** utwórz komunikat RODO (GDPR). Aplikacja wyświetli go sama.
5. Opublikuj plik `app-ads.txt` na swojej stronie (AdMob podpowie treść).

### 5. Produkty w aplikacji
Play Console → Twoja aplikacja → **Zarabianie → Produkty → Produkty w aplikacji**. Utwórz 5 produktów o **dokładnie takich ID**:

| ID produktu | Nazwa | Cena bazowa (USD) |
|---|---|---|
| `diamonds80` | 80 diamentów | $0.99 |
| `diamonds500` | 500 diamentów | $4.99 |
| `diamonds1200` | 1200 diamentów | $9.99 |
| `doubleincome` | Podwójny dochód | $6.99 |
| `offlinevault` | Sejf offline | $2.99 |

Google przeliczy ceny na inne waluty, a gra pokazuje ceny pobrane z Google Play. Żeby kupować bez płacenia, dodaj swoje konto Google w **Ustawienia → Testowanie licencji**.

> Uwaga: produkty w aplikacji da się utworzyć dopiero po wgraniu pierwszej wersji z biblioteką Billing (np. na ścieżkę testów wewnętrznych).

### 6. Firebase Analytics (opcjonalnie, zalecane)
1. <https://console.firebase.google.com> → nowy projekt → dodaj aplikację Android z tym samym `applicationId`.
2. Pobierz `google-services.json` i wstaw go do `android/app/`. Build sam włączy Firebase.
   Pliku nie ma w repozytorium. Jeśli budujesz w GitHub Actions, dodaj go jako sekret albo commituj świadomie: nie zawiera haseł, ale identyfikuje projekt.
3. Zdarzenia z gry: `app_open`, `level_up`, `manager_hire`, `shaft_unlock`, `prestige`, `shop_open`, `iap_click`, `purchase`, `ad_reward`, `daily_claim`, `quest_claim`, `spend_diamonds`.

### 7. Karta w sklepie
- Ikona 512×512: `android/store/icon-512.png`.
- Grafika promocyjna 1024×500 i co najmniej 2 zrzuty ekranu z telefonu.
- **Polityka prywatności (wymagana):** wzór jest w `android/store/privacy-policy.html`. Uzupełnij dane i opublikuj, np. przez GitHub Pages.
- **Bezpieczeństwo danych:** zaznacz, że aplikacja zbiera identyfikator urządzenia do reklam (AdMob), dane o interakcjach z aplikacją (Firebase) i historię zakupów (Google Play). Dane są szyfrowane w transmisji i nie są sprzedawane.
- **Reklamy:** „Tak, aplikacja zawiera reklamy”.
- **Ocena treści:** wypełnij ankietę (gra bez przemocy). Zaznacz, że są zakupy w aplikacji.
- **Grupa docelowa:** 13+ albo 18+. Nie zaznaczaj dzieci, bo wtedy obowiązują ostrzejsze zasady reklam.

### 8. Miękki start (soft launch)
1. **Test wewnętrzny:** wgraj `.aab`, dodaj swoje konto i sprawdź zakupy i reklamy.
2. **Test zamknięty:** 12+ testerów przez 14 dni (wymóg dla nowych kont osobistych). Zbieraj uwagi.
3. **Produkcja tylko w 1–3 krajach** (Play Console → Produkcja → Kraje), np. Polska, Czechy, Filipiny. Tańsze kraje dają tańsze testy.
4. Po 2–4 tygodniach sprawdź w Firebase i Play Console:
   - **D1 retention**, czyli ilu graczy wraca następnego dnia (cel: 35%+),
   - **D7 retention** (cel: 10%+),
   - średni czas gry,
   - % płacących i przychód z reklam na gracza.
5. Popraw balans w jednym miejscu: stałe na górze `game-web/index.html` (koszty, nagrody, limity reklam). Wypuść aktualizację i dopiero przy dobrych liczbach otwórz kolejne kraje i włącz promocję.

### Aktualizacje
Przy każdej nowej wersji zwiększ `versionCode` (o 1) i `versionName` w `android/app/build.gradle.kts`.

## Bezpieczeństwo zakupów
Zakupy są sprawdzane na urządzeniu: każdy token jest naliczany raz, a diamenty są „konsumowane” dopiero po zapisaniu w grze. Przy większej skali warto dodać serwer weryfikujący zakupy (Google Play Developer API), bo zapis gry leży na telefonie.
