// Trwały zapis stanu gracza (localStorage w WebView Androida).
const KEY = 'coinrush3d.save.v1';

const defaults = () => ({
  coins: 0,
  best: 0,
  totalCoins: 0,
  games: 0,
  ownedSkins: ['classic'],
  skin: 'classic',
  character: 'kuba',
  ownedChars: ['kuba'],
  difficulty: 'medium',
  bestBy: { easy: 0, medium: 0, hard: 0 },
  storyDone: { easy: false, medium: false, hard: false },
  introSeen: false,
  iapOwned: [],
  upgrades: { magnet: 0, shield: 0, boost: 0 },
  doubleCoins: false,
  starterGranted: false,
  deliveredTx: [],
  daily: { last: null, streak: 0 },
  settings: { sound: true, haptics: true, quality: 'high' },
});

let state;
try {
  state = { ...defaults(), ...JSON.parse(localStorage.getItem(KEY) || '{}') };
  state.upgrades = { ...defaults().upgrades, ...state.upgrades };
  state.settings = { ...defaults().settings, ...state.settings };
  state.bestBy = { ...defaults().bestBy, ...state.bestBy };
  state.storyDone = { ...defaults().storyDone, ...state.storyDone };
  state.bestBy.medium = Math.max(state.bestBy.medium, state.best || 0);
  if (state.doubleCoins && !state.iapOwned.includes('double_coins')) state.iapOwned.push('double_coins');
  if (state.starterGranted && !state.iapOwned.includes('starter_pack')) state.iapOwned.push('starter_pack');
} catch {
  state = defaults();
}

const listeners = new Set();
export const save = {
  get: () => state,
  commit() {
    try { localStorage.setItem(KEY, JSON.stringify(state)); } catch {}
    listeners.forEach((fn) => fn(state));
  },
  onChange(fn) { listeners.add(fn); },
  addCoins(n) { state.coins += n; save.commit(); },
  spend(n) {
    if (state.coins < n) return false;
    state.coins -= n; save.commit(); return true;
  },
};
