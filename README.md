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

---

# ⛏️ Imperium Kopalni – gra idle z mikropłatnościami

Druga aplikacja w tym repozytorium (osobny target `MineEmpire`, własne Bundle ID). Gra typu *idle tycoon*: rozbudowujesz kopalnię, a pieniądze płyną nawet wtedy, gdy nie grasz.

## Jak działa rozgrywka

1. **Szyby** – górnicy ⛏️ wydobywają urobek 🪨, który odkłada się w szybie.
2. **Winda** 🛗 – wywozi urobek z szybów (od góry) na powierzchnię.
3. **Magazyn** 🚚 – sprzedaje urobek za gotówkę 💰.

Dochód = najwolniejsze ogniwo z tych trzech, więc trzeba ulepszać wszystko po kolei.

- **Dotknij pracownika** – pracuje przez 8 sekund.
- **Kierownik** 🧑‍💼 – jednostka pracuje sama, bez przerwy, także gdy aplikacja jest zamknięta.
- **Poziomy** – przycisk „Poziom” (x1 / x10 / x50 / MAX). Co 25 poziomów szyb pracuje 2× szybciej.
- **Nowe szyby** – każdy kolejny jest ~10× wydajniejszy; można je odblokować gotówką albo diamentami.
- **Dochód offline** – po powrocie gra wypłaca zarobki kierowników (do 4 h, z „Sejfem offline” do 24 h).
- **Darmowy boost x2** – 10 minut co 4 godziny (zachęca do powrotów).

## Mikropłatności

Waluta premium to **diamenty 💎**.

| Produkt | Typ (App Store Connect) | Product ID | Cena (propozycja) |
|---|---|---|---|
| 80 diamentów | Consumable | `com.twojafirma.mineempire.diamonds80` | 4,99 zł |
| 500 diamentów | Consumable | `com.twojafirma.mineempire.diamonds500` | 24,99 zł |
| 1200 diamentów | Consumable | `com.twojafirma.mineempire.diamonds1200` | 49,99 zł |
| Podwójny dochód (na zawsze) | Non-Consumable | `com.twojafirma.mineempire.doubleincome` | 29,99 zł |
| Sejf offline – 24 h (na zawsze) | Non-Consumable | `com.twojafirma.mineempire.offlinevault` | 14,99 zł |

Na co gracz wydaje diamenty:
- **Boost x2 na 30 min** – 15 💎,
- **Walizka gotówki** (1 h produkcji od razu) – 25 💎,
- **Odbierz dochód offline x2** – 10 💎,
- **Odblokowanie szybu** bez czekania – od 30 💎 (drożej za dalsze szyby).

Każda transakcja jest naliczana tylko raz (zapamiętane ID transakcji), zwroty odbierają ulepszenia na zawsze, jest przycisk **„Przywróć zakupy”**.

## Struktura

```
MineEmpire.storekit         – lokalny sklep do testów w Xcode
MineEmpire/App              – punkt wejścia, start/zatrzymanie symulacji
MineEmpire/Model            – Economy.swift (cały balans gry w jednym pliku), stan gracza
MineEmpire/Game             – MineEngine: symulacja 10×/s, zakupy, zapis, dochód offline
MineEmpire/Store            – MineStore: StoreKit 2
MineEmpire/Views            – ekran kopalni, ulepszenia, sklep, „Witaj z powrotem”
```

## Uruchomienie

Jak wyżej: `xcodegen generate`, otwórz `CoinRush.xcodeproj`, wybierz schemat **MineEmpire** i naciśnij ▶︎. Zakupy są symulowane z pliku `MineEmpire.storekit`.

Publikacja – te same kroki co dla Coin Rush, tylko z Bundle ID `com.twojafirma.mineempire` (zmień prefiks w `project.yml`, `MineEmpire/Store/MineStore.swift` i `MineEmpire.storekit`) oraz produktami z tabeli powyżej. Kategoria w App Store: *Games → Simulation*.

Balans (ceny, tempo, czasy boostów) zmienisz w jednym miejscu: `MineEmpire/Model/Economy.swift`.
