// Konfiguracja produktów, skórek i ulepszeń – jedno miejsce do zmiany ekonomii gry.

// ID produktów MUSZĄ być identyczne jak w Google Play Console (Zarabianie → Produkty → Produkty w aplikacji).
export const IAP_PRODUCTS = [
  { id: 'starter_pack', type: 'non-consumable', coins: 2000, skin: 'aurora', char: 'iskra', title: 'Pakiet startowy', icon: '🎁', fallbackPrice: '$2.99', badge: 'JEDNORAZOWO', desc: '2000 monet + bohaterka Iskra + kula Aurora' },
  { id: 'hero_knight', type: 'non-consumable', char: 'rycerz', title: 'Złoty Rycerz', icon: '🛡️', fallbackPrice: '$3.99', badge: 'LEGENDARNY', desc: 'Legendarny bohater ze złotą zbroją i peleryną' },
  { id: 'coins_500', type: 'consumable', coins: 500, title: 'Garść monet', icon: '🪙', fallbackPrice: '$0.99' },
  { id: 'coins_3000', type: 'consumable', coins: 3000, title: 'Worek monet', icon: '💰', fallbackPrice: '$4.99', badge: 'POPULARNE' },
  { id: 'coins_10000', type: 'consumable', coins: 10000, title: 'Skrzynia skarbów', icon: '👑', fallbackPrice: '$9.99', badge: 'NAJLEPSZA OFERTA' },
  { id: 'double_coins', type: 'non-consumable', title: 'Podwójne monety na zawsze', icon: '⚡', fallbackPrice: '$3.99' },
];

export const SKINS = [
  { id: 'classic', name: 'Klasyk', color: 0xffc83d, emissive: 0x6b4a00, metal: 0.9, rough: 0.25, trail: 0xffd75e, price: 0 },
  { id: 'ruby', name: 'Rubin', color: 0xff2d55, emissive: 0x5a0015, metal: 0.6, rough: 0.2, trail: 0xff5f7e, price: 500 },
  { id: 'emerald', name: 'Szmaragd', color: 0x19e38b, emissive: 0x004d2b, metal: 0.6, rough: 0.2, trail: 0x5dffb5, price: 1000 },
  { id: 'ocean', name: 'Ocean', color: 0x2f8cff, emissive: 0x002a66, metal: 0.5, rough: 0.15, trail: 0x6cb2ff, price: 1500 },
  { id: 'chrome', name: 'Chrom', color: 0xe8eef7, emissive: 0x202830, metal: 1.0, rough: 0.05, trail: 0xffffff, price: 2500 },
  { id: 'lava', name: 'Lawa', color: 0xff6a00, emissive: 0xff2a00, metal: 0.2, rough: 0.5, trail: 0xff8a1f, price: 4000 },
  { id: 'void', name: 'Pustka', color: 0x1a0933, emissive: 0x8a2bff, metal: 0.8, rough: 0.1, trail: 0xb26bff, price: 7500 },
  { id: 'aurora', name: 'Aurora', color: 0x7bfff2, emissive: 0x00b3ff, metal: 0.7, rough: 0.05, trail: 0x9dffec, price: -1, exclusive: true },
];

export const UPGRADES = [
  { id: 'magnet', name: 'Magnes', icon: '🧲', desc: 'Dłuższy czas działania magnesu', base: 6, step: 2, maxLevel: 5, unit: 's' },
  { id: 'shield', name: 'Tarcza', icon: '🛡️', desc: 'Dłuższy czas działania tarczy', base: 8, step: 2, maxLevel: 5, unit: 's' },
  { id: 'boost', name: 'Start z doładowaniem', icon: '🚀', desc: 'Więcej monet za każdą monetę na trasie', base: 1, step: 1, maxLevel: 4, unit: '× monet', isMult: true },
];

export const upgradeCost = (level) => 300 * Math.pow(2, level); // 300, 600, 1200, ...
export const continueCost = (used) => 150 * Math.pow(2, used); // 150, 300, 600 ...
export const DAILY_REWARDS = [100, 150, 200, 300, 400, 600, 1000];

// Bohaterowie jeżdżący na kuli. price: -1 = tylko z zakupu w sklepie (iap).
// (id zostają stare, żeby zachować zapisy graczy)
export const CHARACTERS = [
  { id: 'kuba', name: 'Rycerzyk Kuba', bio: 'Najmłodszy rycerz Bajkogrodu. Ma drewniany miecz i wielkie serce.', price: 0 },
  { id: 'mila', name: 'Wróżka Mila', bio: 'Jej różdżka sypie gwiezdnym pyłem. Uwielbia zbierać złote monety.', price: 800 },
  { id: 'mruczek', name: 'Kot w Butach', bio: 'Elegancki kocur w kapeluszu z piórem. Zawsze ląduje na czterech łapach.', price: 1500 },
  { id: 'bit', name: 'Smoczek Bzik', bio: 'Mały smok, który zamiast ognia kicha iskierkami. Kocha błyskotki.', price: 2500 },
  { id: 'astro', name: 'Księżniczka Ola', bio: 'Zamiast czekać na ratunek, sama wskoczyła na Złotą Kulę!', price: 4000 },
  { id: 'cien', name: 'Skrzat Brodacz', bio: 'Strażnik leśnych ścieżek. Jego latarenka rozświetla każdą ciemność.', price: 7000 },
  { id: 'iskra', name: 'Czarodziejka Iskra', bio: 'Strażniczka Złotej Kuli. Jej włosy płoną magicznym światłem.', price: -1, iap: 'starter_pack' },
  { id: 'rycerz', name: 'Złoty Rycerz', bio: 'Legenda Bajkogrodu. Wraca zawsze, gdy miasto traci kolory.', price: -1, iap: 'hero_knight' },
];

// Poziomy trudności.
export const DIFFICULTIES = {
  easy: { name: 'Łatwy', icon: '🙂', start: 12, max: 26, accel: 0.18, density: 0.55, gap: 5, reward: 1 },
  medium: { name: 'Średni', icon: '😎', start: 15, max: 34, accel: 0.32, density: 1, gap: 0, reward: 1.5 },
  hard: { name: 'Trudny', icon: '🔥', start: 19, max: 44, accel: 0.48, density: 1.45, gap: -2.5, reward: 2 },
};

// Rozdziały historii – krainy Bajkogrodu (od dystansu `at` w metrach) i ich kolory.
export const CHAPTERS = [
  { at: 0, title: 'Rozdział 1: Miodowa Wioska', line: 'Szaruch kradnie kolory miasta! Zbieraj złote monety, by je przywrócić!', who: 'iskra',
    skyTop: 0x3fa9ff, skyBottom: 0xffe1f0, grass: 0x8fdc6a, tint: 0xffffff, sun: 0xfff1d6, lamp: 0xffc94d, light: 1, rainbow: true },
  { at: 600, title: 'Rozdział 2: Cukierkowe Wzgórza', line: 'Hehehe! Zamienię wasze cukierki w szary kamień!', who: 'baron',
    skyTop: 0xb48cff, skyBottom: 0xffd6ea, grass: 0xa8e88a, tint: 0xfff0f8, sun: 0xffe0f0, lamp: 0xff8fc8, light: 0.95, rainbow: false },
  { at: 1400, title: 'Rozdział 3: Grzybowy Las', line: 'Zmierzcha się… ale latarenki skrzatów wskażą nam drogę!', who: 'iskra',
    skyTop: 0x3c4aa8, skyBottom: 0xffa98a, grass: 0x58b884, tint: 0xe6deff, sun: 0xffb27a, lamp: 0xffc94d, light: 0.72, rainbow: false },
  { at: 2400, title: 'Rozdział 4: Szary Zamek Szarucha', line: 'Tu wszystko jest szare i MOJE! Nikt nie dotrze do zamku!', who: 'baron', villain: true,
    skyTop: 0x3d3852, skyBottom: 0x9a93ad, grass: 0x7d8577, tint: 0xa6a1b5, sun: 0xd6d0e6, lamp: 0xb388ff, light: 0.6, rainbow: false },
  { at: 3500, title: 'FINAŁ: Kolory wróciły!', line: 'Nieeee! Moja szarość… znika! Wszystko znów jest kolorowe!', who: 'baron', final: true,
    skyTop: 0x38b4ff, skyBottom: 0xfff0b0, grass: 0x7ee36a, tint: 0xffffff, sun: 0xfff6d6, lamp: 0xffd23f, light: 1.05, rainbow: true },
];
export const STORY_BONUS = { easy: 500, medium: 1000, hard: 2500 };

export const STORY_INTRO = [
  { who: 'iskra', name: 'Czarodziejka Iskra', text: 'Dawno, dawno temu było sobie Bajkogród – najbardziej kolorowe miasto na świecie. Jego sercem była Złota Kula.' },
  { who: 'baron', name: 'Czarnoksiężnik Szaruch', text: 'Hehehe! Nie znoszę kolorów! Zamknę je w złotych monetach i rozrzucę po całym królestwie!' },
  { who: 'iskra', name: 'Czarodziejka Iskra', text: 'Każda złota moneta to zaklęty kawałek koloru. Jeśli je zbierzemy, Bajkogród znów rozkwitnie!' },
  { who: 'kuba', name: 'Rycerzyk Kuba', text: 'Wskakuję na Złotą Kulę! Przejadę przez wszystkie krainy aż do Szarego Zamku!' },
  { who: 'iskra', name: 'Czarodziejka Iskra', text: 'Uważaj na płotki i zaczarowane przeszkody! Zbieraj monety i odczaruj miasto. Powodzenia, bohaterze!' },
];
