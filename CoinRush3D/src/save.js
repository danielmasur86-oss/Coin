// Trwały zapis stanu gracza (localStorage w WebView Androida).
const KEY = 'coinrush3d.save.v1';

const defaults = () => ({
  coins: 0,
  best: 0,
  totalCoins: 0,
  games: 0,
  ownedSkins: ['classic'],
  skin: 'classic',
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
