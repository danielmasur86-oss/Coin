# 🪙 Coin Rush 3D – gra 3D na Androida z mikropłatnościami

Nieskończony bieg po neonowej trasie w stylu synthwave. Toczysz złotą kulę po 3 pasach, zbierasz monety, przeskakujesz bariery i omijasz ściany. Gra stale przyspiesza.

**Technologia:** Three.js (grafika 3D z efektem bloom) + Capacitor 8 (aplikacja Android) + Google Play Billing 9 (przez `cordova-plugin-purchase`).

## Rozgrywka

- **Przesunięcie palcem ← →** albo tapnięcie lewej/prawej połowy ekranu zmienia pas
- **Przesunięcie ↑** to skok, **↓** szybkie lądowanie
- Power-upy: 🧲 **magnes** (przyciąga monety) i 🛡️ **tarcza** (chroni przed jednym uderzeniem)
- Rekord, nagroda dzienna (7 dni z rosnącą nagrodą), wibracje, dźwięki, tryb niskiej grafiki dla słabszych telefonów

## Model zarobkowy

| Produkt | Typ w Play Console | Product ID | Proponowana cena |
|---|---|---|---|
| Pakiet startowy (2000 monet + skórka Aurora) | Jednorazowy, bez konsumpcji | `starter_pack` | 9,99 zł |
| 500 monet | Konsumpcyjny | `coins_500` | 4,99 zł |
| 3000 monet | Konsumpcyjny | `coins_3000` | 19,99 zł |
| 10 000 monet | Konsumpcyjny | `coins_10000` | 49,99 zł |
| Podwójne monety na zawsze | Jednorazowy, bez konsumpcji | `double_coins` | 14,99 zł |

Na co gracze wydają monety:
- **kontynuacja po przegranej**: 150, potem 300, potem 600 monet (maks. 3 razy na rundę, 6 sekund na decyzję),
- **7 skórek kuli** w cenie od 500 do 7500 monet,
- **ulepszenia** magnesu, tarczy i wartości monet (od 300 monet, każdy kolejny poziom kosztuje 2× więcej).

Ceny i ekonomię zmienisz w jednym pliku: `src/config.js`.

## Uruchomienie w przeglądarce (do testów)

```bash
cd CoinRush3D
npm install
npm run dev        # otwórz podany adres; na komputerze steruj strzałkami i spacją
```

W przeglądarce sklep działa w **trybie testowym**: zakup tylko się symuluje i nic nie płacisz.

## Budowanie aplikacji Android

**Opcja A: GitHub Actions (bez instalowania czegokolwiek).** Każdy push do `CoinRush3D/` uruchamia workflow *Android build*. W zakładce *Actions* → ostatni przebieg → *Artifacts* pobierzesz:
- `coinrush3d-debug-apk` – zainstaluj na telefonie i testuj,
- `coinrush3d-release-aab` – podpisany pakiet do Sklepu Play. Pojawi się, gdy dodasz sekrety podpisu (patrz niżej).

**Opcja B: lokalnie w Android Studio.**
```bash
npm run android    # buduje grę, kopiuje do projektu Android i otwiera Android Studio
```
W Android Studio wybierz *Build → Generate Signed App Bundle*.

## Publikacja w Sklepie Play, krok po kroku

1. **Konto dewelopera** na <https://play.google.com/console>. Opłata jednorazowa to 25 USD. Uwaga: nowe konta prywatne muszą przed publikacją przeprowadzić **test zamknięty z min. 12 testerami przez 14 dni**.
2. **Profil płatności** (Ustawienia → Profil płatności). Bez niego nie dodasz produktów w aplikacji.
3. **Zmień identyfikator aplikacji.** Zamień `com.twojafirma.coinrush3d` na własny (np. `pl.twojenazwisko.coinrush3d`) w:
   - `capacitor.config.json` (`appId`),
   - `android/app/build.gradle` (`namespace` i `applicationId`),
   - ścieżce i pakiecie `android/app/src/main/java/.../MainActivity.java`.
   Identyfikatora **nie da się zmienić** po pierwszej publikacji.
4. **Klucz podpisu** (zrób to raz i nie zgub pliku!):
   ```bash
   keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Dla GitHub Actions dodaj w repozytorium (*Settings → Secrets and variables → Actions*):
   `KEYSTORE_BASE64` (wynik `base64 -w0 upload.jks`), `KEYSTORE_PASSWORD`, `KEY_ALIAS` (`upload`), `KEY_PASSWORD`.
   Lokalnie możesz zamiast tego utworzyć `android/keystore.properties` (jest w `.gitignore`):
   ```
   storeFile=/pełna/ścieżka/upload.jks
   storePassword=...
   keyAlias=upload
   keyPassword=...
   ```
5. **Utwórz aplikację** w Play Console i wgraj pierwszy plik `.aab` na ścieżkę **Test wewnętrzny**. Produkty w aplikacji da się dodać dopiero po wgraniu builda z uprawnieniem BILLING, a ten projekt je ma.
6. **Dodaj produkty** (*Zarabianie → Produkty → Produkty w aplikacji*) z ID **dokładnie** jak w tabeli wyżej i aktywuj je.
7. **Testy zakupów:** *Ustawienia → Testowanie licencji* → dodaj swój adres Gmail. Zainstaluj aplikację z linku testu wewnętrznego. Zakupy testowe są wtedy darmowe.
8. **Karta sklepu:** wymagane są ikona 512×512 (`assets/icon-only.png` przeskaluj), grafika 1024×500 i min. 2 zrzuty ekranu z telefonu, opis oraz kategoria *Gry → Zręcznościowe*.
9. **Formularze:** ocena treści (IARC), grupa docelowa (zalecam 13+), sekcja *Bezpieczeństwo danych*. Gra nie zbiera danych, zakupy obsługuje Google. Potrzebny jest też **link do polityki prywatności**. Szablon jest w `public/privacy.html`: uzupełnij dane w nawiasach `[...]` i opublikuj go (np. na GitHub Pages).
10. **Wydanie:** test zamknięty → produkcja. Przy każdej aktualizacji `versionCode` musi rosnąć. GitHub Actions ustawia go automatycznie z numeru przebiegu.

## Zalecane przed dużą skalą

- **Walidacja zakupów po stronie serwera.** Obecnie zakupy są przyjmowane bezpośrednio w aplikacji, co wystarcza na start. Przy większych przychodach podłącz walidator (np. iaptic.com albo własny serwer z Google Play Developer API) przez `store.validator` w `src/billing.js`. To utrudnia oszustwa.
- **Zapis w chmurze.** Postęp jest zapisywany lokalnie, więc po odinstalowaniu przepada. Nie dotyczy to zakupów jednorazowych: wracają przez „Przywróć zakupy”.
- **Reklamy nagradzane** (np. AdMob: „obejrzyj reklamę = darmowa kontynuacja”) to dodatkowe źródło przychodu. Wymagają aktualizacji polityki prywatności i formularza zgody (UMP).
- **Analityka** (Firebase), żeby sprawdzać, gdzie gracze odpadają i co kupują.

## Struktura

```
CoinRush3D/
  index.html           – ekrany UI (menu, HUD, sklep, pauza, koniec gry)
  src/game.js          – silnik 3D: świat, gracz, przeszkody, kolizje, efekty
  src/main.js          – logika ekranów, sterowanie, sklep, nagrody dzienne
  src/billing.js       – Google Play Billing + tryb testowy w przeglądarce
  src/config.js        – produkty, ceny, skórki, ulepszenia
  src/save.js          – zapis postępu
  src/audio.js         – proceduralne dźwięki (bez plików i licencji)
  public/privacy.html  – szablon polityki prywatności
  assets/              – źródła ikony i ekranu startowego
  android/             – projekt Android Studio (Capacitor)
```
