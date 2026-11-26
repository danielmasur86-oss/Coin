# Test na telefonie z Androidem (bez instalowania czegokolwiek na komputerze)

## 1. Klucz do AI (5 minut)
1. Wejdź na **console.anthropic.com** i załóż konto.
2. *Billing*: doładuj np. 5–10 $ (wystarczy na setki testów). Ustaw limit wydatków.
3. *API Keys* → *Create Key*. Skopiuj klucz (zaczyna się od `sk-ant-`). **Nikomu go nie wysyłaj i nie wklejaj w czat.**

## 2. Serwer na Render.com (10 minut, za darmo)
1. Wejdź na **render.com** i zaloguj się kontem GitHub. Pozwól na dostęp do repozytorium `Coin`.
2. **New → Web Service** i wybierz repozytorium `Coin`, a potem ustaw:
   - **Branch**: `ccr-f07cd66f-ou14e7`
   - **Root Directory**: `hausihelfer/backend`
   - **Language / Runtime**: `Docker`
   - **Region**: `Frankfurt (EU Central)`
   - **Instance Type**: `Free`
3. **Environment Variables**: dodaj
   - `ANTHROPIC_API_KEY` = Twój klucz z kroku 1
   - `FREE_PER_WEEK` = `50` (więcej darmowych zadań na czas testów)
   - `GLOBAL_PER_DAY` = `200` (bezpiecznik kosztów)
4. **Deploy**. Po kilku minutach na górze pojawi się adres, np. `https://hausihelfer-api.onrender.com`.
5. Sprawdź w przeglądarce: `https://<twój-adres>/health` powinien pokazać `{"ok":true}`.

> Zamiast punktu 2 możesz użyć **New → Blueprint** (plik `render.yaml` w repozytorium ma gotowe ustawienia).
> Darmowy serwer „zasypia” po ok. 15 min bez ruchu. Pierwsze zadanie po przerwie trwa wtedy do minuty.

## 3. Aplikacja na telefon
Podaj adres serwera Claude'owi. Zapisze go w `hausihelfer/app/test-api-url.txt`, a GitHub sam zbuduje APK
(ok. 6 minut) i opublikuje go na stronie **Releases** repozytorium.

Na telefonie:
1. Otwórz w przeglądarce stronę *Releases* repozytorium (zaloguj się do GitHuba, jeśli repozytorium jest prywatne).
2. Pobierz plik `hausihelfer-test-….apk`.
3. Otwórz go i zezwól na instalację z tego źródła („nieznane aplikacje”).
4. Gotowe: zrób zdjęcie zadania domowego.

Na tym etapie zakupy Premium jeszcze nie działają (wymagają konta Google Play i RevenueCat).
Do testów wystarczy darmowy limit z kroku 2.
