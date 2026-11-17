# 🪙 Coin Rush – gra iOS z mikropłatnościami

Gra zręcznościowa na iPhone'a: przesuwasz koszyk palcem, łapiesz spadające monety 🪙 i diamenty 💎, unikasz bomb 💣. Gra przyspiesza z czasem.

Technologia: **SwiftUI + SpriteKit + StoreKit 2**, iOS 16+, bez zewnętrznych bibliotek.

## Model zarobkowy (mikropłatności)

| Produkt | Typ (App Store Connect) | Product ID | Cena (propozycja) |
|---|---|---|---|
| 500 monet | Consumable | `com.twojafirma.coinrush.coins500` | 4,99 zł |
| 3000 monet | Consumable | `com.twojafirma.coinrush.coins3000` | 19,99 zł |
| 10 000 monet | Consumable | `com.twojafirma.coinrush.coins10000` | 49,99 zł |
| Podwójne monety (na zawsze) | Non-Consumable | `com.twojafirma.coinrush.doublecoins` | 14,99 zł |

Na co gracz wydaje monety:
- **Kontynuacja po przegranej** – 100 monet (raz na rundę),
- **Skórki koszyka** – od 250 do 5000 monet.

Jest też przycisk **„Przywróć zakupy”** (Apple go wymaga przy produktach niekonsumowalnych).

## Struktura projektu

```
project.yml                 – definicja projektu Xcode (XcodeGen)
CoinRush.storekit           – lokalna konfiguracja sklepu do testów w Xcode
CoinRush/App                – punkt wejścia aplikacji
CoinRush/Game               – rozgrywka (SpriteKit) i sesja gry
CoinRush/Store              – StoreManager: zakupy, przywracanie, weryfikacja transakcji
CoinRush/Model              – zapis stanu gracza, skórki
CoinRush/Views              – menu, ekran gry, sklep
CoinRush/Resources          – ikona, kolory, manifest prywatności
```

## Uruchomienie (potrzebny Mac z Xcode 16+)

```bash
brew install xcodegen
xcodegen generate
open CoinRush.xcodeproj
```

W Xcode wybierz symulator iPhone'a i naciśnij ▶︎. Sklep działa od razu – zakupy są symulowane z pliku `CoinRush.storekit` (nic nie płacisz). Historię testowych transakcji zobaczysz w *Debug → StoreKit → Manage Transactions*.

## Publikacja w App Store – krok po kroku

1. **Konto Apple Developer** – <https://developer.apple.com/programs/> (99 USD/rok).
2. **Umowa na aplikacje płatne** – App Store Connect → *Business* → podpisz „Paid Apps Agreement”, uzupełnij dane bankowe i podatkowe. Bez tego mikropłatności nie zadziałają.
3. **Zmień identyfikatory** – zamień `com.twojafirma` na własny prefiks w:
   - `project.yml` (`bundleIdPrefix`, `PRODUCT_BUNDLE_IDENTIFIER`) i wpisz swój `DEVELOPMENT_TEAM`,
   - `CoinRush/Store/StoreManager.swift` (`ProductID`),
   - `CoinRush.storekit` (`productID`).
   Potem ponownie `xcodegen generate`.
4. **Utwórz aplikację** w App Store Connect (*Apps → +*) z tym samym Bundle ID.
5. **Dodaj produkty** – *Monetization → In-App Purchases*: utwórz 4 produkty z tabeli powyżej (identyczne Product ID i typy), dodaj nazwę i opis po polsku, cenę oraz zrzut ekranu sklepu (wymagany do recenzji).
6. **Testy sandbox** – *Users and Access → Sandbox* → utwórz konto testowe i przetestuj zakupy na prawdziwym iPhonie (TestFlight).
7. **Wysyłka buildu** – w Xcode: *Product → Archive → Distribute App → App Store Connect*.
8. **Strona w sklepie** – zrzuty ekranu (iPhone 6,9″ i 6,5″), opis, słowa kluczowe, kategoria *Games → Arcade*, ocena wiekowa, **link do polityki prywatności** (wymagany), w sekcji *App Privacy* zaznacz „Data Not Collected”.
9. **Dołącz produkty IAP do pierwszej wersji** (przy pierwszym zgłoszeniu muszą być wysłane razem z aplikacją) i kliknij *Submit for Review*.

## Uwagi

- Monety są zapisywane lokalnie (`UserDefaults`). Każda transakcja jest naliczana tylko raz. Przy większej skali warto dodać własny serwer i weryfikację transakcji po stronie serwera (App Store Server API).
- Jeśli dodajesz nowe pakiety monet, dopisz je w `ProductID.coinAmounts` i w App Store Connect.
- GitHub Actions (`.github/workflows/ios-build.yml`) kompiluje projekt na macOS przy każdym pushu.
