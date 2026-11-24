// Konfiguracja produktów, skórek i ulepszeń – jedno miejsce do zmiany ekonomii gry.

// ID produktów MUSZĄ być identyczne jak w Google Play Console (Zarabianie → Produkty → Produkty w aplikacji).
export const IAP_PRODUCTS = [
  { id: 'starter_pack', type: 'non-consumable', coins: 2000, skin: 'aurora', char: 'iskra', title: 'Pakiet startowy', icon: '🎁', fallbackPrice: '9,99 zł', badge: 'JEDNORAZOWO', desc: '2000 monet + bohaterka Iskra + kula Aurora' },
  { id: 'hero_knight', type: 'non-consumable', char: 'rycerz', title: 'Złoty Rycerz', icon: '🛡️', fallbackPrice: '12,99 zł', badge: 'LEGENDARNY', desc: 'Legendarny bohater ze złotą zbroją i peleryną' },
  { id: 'coins_500', type: 'consumable', coins: 500, title: 'Garść monet', icon: '🪙', fallbackPrice: '4,99 zł' },
  { id: 'coins_3000', type: 'consumable', coins: 3000, title: 'Worek monet', icon: '💰', fallbackPrice: '19,99 zł', badge: 'POPULARNE' },
  { id: 'coins_10000', type: 'consumable', coins: 10000, title: 'Skrzynia skarbów', icon: '👑', fallbackPrice: '49,99 zł', badge: 'NAJLEPSZA OFERTA' },
  { id: 'double_coins', type: 'non-consumable', title: 'Podwójne monety na zawsze', icon: '⚡', fallbackPrice: '14,99 zł' },
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
export const CHARACTERS = [
  { id: 'kuba', name: 'Kuba „Turbo”', bio: 'Kurier z Dzielnicy Neonów. Zna każdy skrót w mieście i nigdy się nie spóźnia.', price: 0 },
  { id: 'mila', name: 'Mila', bio: 'DJ-ka z dachów miasta. Słyszy rytm ulic nawet przez słuchawki.', price: 800 },
  { id: 'mruczek', name: 'Mruczek', bio: 'Kot, który spadł na kulę i… polubił to. Zawsze ląduje na czterech łapach.', price: 1500 },
  { id: 'bit', name: 'BIT-0', bio: 'Robot sprzątający, który zbuntował się przeciw Baronowi. Kocha błyszczące monety.', price: 2500 },
  { id: 'astro', name: 'Astro Ola', bio: 'Astronautka, której rakieta wylądowała w porcie. Szuka paliwa ze złotych monet.', price: 4000 },
  { id: 'cien', name: 'Cień', bio: 'Tajemniczy ninja. Mówią, że był kiedyś ochroniarzem Barona…', price: 7000 },
  { id: 'iskra', name: 'Iskra', bio: 'Ostatnia strażniczka Złotej Kuli. Jej włosy płoną światłem miasta.', price: -1, iap: 'starter_pack' },
  { id: 'rycerz', name: 'Złoty Rycerz', bio: 'Legenda Neo-Miasta. Wraca tylko wtedy, gdy miasto gaśnie.', price: -1, iap: 'hero_knight' },
];

// Poziomy trudności.
export const DIFFICULTIES = {
  easy: { name: 'Łatwy', icon: '🙂', start: 12, max: 26, accel: 0.18, density: 0.55, gap: 5, reward: 1 },
  medium: { name: 'Średni', icon: '😎', start: 15, max: 34, accel: 0.32, density: 1, gap: 0, reward: 1.5 },
  hard: { name: 'Trudny', icon: '🔥', start: 19, max: 44, accel: 0.48, density: 1.45, gap: -2.5, reward: 2 },
};

// Rozdziały historii – dzielnice miasta (od dystansu `at` w metrach).
export const CHAPTERS = [
  { at: 0, title: 'Rozdział 1: Dzielnica Neonów', line: 'Baron ukradł światło miasta! Zbieraj monety, by je przywrócić!', who: 'iskra',
    sky: 0x0a0420, a: 0xff2fd6, b: 0x22e6ff },
  { at: 600, title: 'Rozdział 2: Port Świateł', line: 'Hahaha! Moje drony zgaszą każdą latarnię w porcie!', who: 'baron',
    sky: 0x04161f, a: 0xff8a1f, b: 0x1fffd2 },
  { at: 1400, title: 'Rozdział 3: Cyber-Ogrody', line: 'Jesteśmy blisko! Ogrody już odzyskują kolory!', who: 'iskra',
    sky: 0x041a0c, a: 0x7dff3a, b: 0xffe14d },
  { at: 2400, title: 'Rozdział 4: Wieża Barona', line: 'Nikt nie dotrze na szczyt mojej wieży! NIKT!', who: 'baron',
    sky: 0x1a0208, a: 0xff1a3c, b: 0xb026ff },
  { at: 3500, title: 'FINAŁ: Miasto ocalone!', line: 'Nieeeee! Moje światło… wraca do miasta!', who: 'baron', final: true,
    sky: 0x120630, a: 0xffc928, b: 0x22e6ff },
];
export const STORY_BONUS = { easy: 500, medium: 1000, hard: 2500 };

export const STORY_INTRO = [
  { who: 'iskra', name: 'Iskra', text: 'Neo-Miasto zawsze świeciło najjaśniej na świecie. Jego sercem była Złota Kula – źródło całego światła.' },
  { who: 'baron', name: 'Baron Szaruch', text: 'Ha! Od dziś całe światło należy do mnie! Zamienię je w monety i schowam w mojej wieży!' },
  { who: 'iskra', name: 'Iskra', text: 'Baron rozrzucił złote monety po podniebnych autostradach. Każda moneta to kawałek światła miasta.' },
  { who: 'kuba', name: 'Kuba „Turbo”', text: 'Wskakuję na Złotą Kulę! Zbiorę każdą monetę i dotrę do Wieży Barona!' },
  { who: 'iskra', name: 'Iskra', text: 'Uważaj na bariery i ściany Barona! Przejedź 4 dzielnice i ocal miasto. Powodzenia, bohaterze!' },
];
