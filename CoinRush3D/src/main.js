import { Capacitor } from '@capacitor/core';
import { App } from '@capacitor/app';
import { Haptics, ImpactStyle, NotificationType } from '@capacitor/haptics';
import { Game } from './game.js';
import { save } from './save.js';
import { billing } from './billing.js';
import { sfx } from './audio.js';
import { IAP_PRODUCTS, SKINS, UPGRADES, upgradeCost, continueCost, DAILY_REWARDS } from './config.js';

const $ = (s) => document.querySelector(s);
const $$ = (s) => [...document.querySelectorAll(s)];
const S = () => save.get();

// ---------- haptyka ----------
const haptic = {
  light: () => S().settings.haptics && Capacitor.isNativePlatform() && Haptics.impact({ style: ImpactStyle.Light }).catch(() => {}),
  heavy: () => S().settings.haptics && Capacitor.isNativePlatform() && Haptics.notification({ type: NotificationType.Error }).catch(() => {}),
  success: () => S().settings.haptics && Capacitor.isNativePlatform() && Haptics.notification({ type: NotificationType.Success }).catch(() => {}),
};

// ---------- ekrany ----------
let mode = 'menu'; // menu | play | pause | over
const overlays = ['shop', 'daily', 'settings'];
function show(id) { $('#' + id).classList.remove('hidden'); }
function hide(id) { $('#' + id).classList.add('hidden'); }
function openOverlay(id) { overlays.forEach(hide); show(id); sfx.click(); }
function closeOverlays() { overlays.forEach(hide); }
const overlayOpen = () => overlays.some((id) => !$('#' + id).classList.contains('hidden'));

function toast(msg, ms = 2200) {
  const t = $('#toast');
  t.textContent = msg;
  t.classList.remove('hidden');
  clearTimeout(toast.t);
  toast.t = setTimeout(() => t.classList.add('hidden'), ms);
}

// ---------- gra ----------
let continuesUsed = 0;
let contTimer = null;

const game = new Game($('#c'), {
  onScore: (d) => { $('#hud-dist').textContent = d; },
  onCoin: (c) => { $('#hud-coins').textContent = c; sfx.coin(); },
  onPickup: (type) => { sfx.power(); haptic.light(); toast(type === 'magnet' ? '🧲 Magnes!' : '🛡️ Tarcza!', 1000); },
  onShieldBreak: () => { sfx.shieldBreak(); haptic.light(); },
  onPower: (m, s) => {
    $('#pw-magnet').classList.toggle('on', m > 0);
    $('#pw-shield').classList.toggle('on', s > 0);
    $('#pw-magnet i').style.transform = `scaleX(${m})`;
    $('#pw-shield i').style.transform = `scaleX(${s})`;
  },
  onDeath: (r) => gameOver(r),
});
game.setSkin(S().skin);
game.setQuality(S().settings.quality);

function upgradeValue(id) {
  const u = UPGRADES.find((x) => x.id === id);
  return u.base + u.step * S().upgrades[id];
}

function startGame() {
  sfx.unlock();
  closeOverlays();
  ['menu', 'over', 'pause'].forEach(hide);
  show('hud');
  const hint = $('#hint');
  hint.style.display = S().games < 3 ? '' : 'none';
  hint.style.animation = 'none'; void hint.offsetWidth; hint.style.animation = '';
  $('#hud-coins').textContent = 0;
  continuesUsed = 0;
  runFinalized = false;
  mode = 'play';
  game.start({
    skin: S().skin,
    magnetTime: upgradeValue('magnet'),
    shieldTime: upgradeValue('shield'),
    coinValue: upgradeValue('boost') * (S().doubleCoins ? 2 : 1),
  });
}

function gameOver({ distance, coins }) {
  mode = 'over';
  sfx.crash();
  haptic.heavy();
  hide('hud');
  $('#ov-dist').textContent = distance + ' m';
  $('#ov-coins').textContent = coins;
  const record = distance > S().best;
  $('#ov-record').classList.toggle('hidden', !record);
  $('#ov-double').classList.toggle('hidden', S().doubleCoins);

  const cost = continueCost(continuesUsed);
  $('#cont-cost').textContent = cost;
  $('#continue-box').classList.toggle('hidden', continuesUsed >= 3);
  if (continuesUsed < 3) armContinue(); else finalizeRun();
  setTimeout(() => show('over'), 450);
  refreshPrices();
}

let runFinalized = false;
function armContinue() {
  const bar = $('#cont-timer');
  bar.style.transition = 'none'; bar.style.width = '100%';
  requestAnimationFrame(() => requestAnimationFrame(() => { bar.style.transition = 'width 6s linear'; bar.style.width = '0%'; }));
  clearTimeout(contTimer);
  contTimer = setTimeout(() => finalizeRun(), 6000);
}
function finalizeRun() {
  if (runFinalized) return;
  runFinalized = true;
  clearTimeout(contTimer);
  $('#continue-box').classList.add('hidden');
  const s = S();
  s.coins += game.coins;
  s.totalCoins += game.coins;
  s.best = Math.max(s.best, Math.floor(game.distance));
  s.games += 1;
  save.commit();
}

function tryContinue() {
  const cost = continueCost(continuesUsed);
  if (S().coins + game.coins < cost) {
    toast('Za mało monet – doładuj w sklepie 🛒');
    clearTimeout(contTimer);
    openOverlay('shop'); selectTab('coins');
    return;
  }
  // najpierw płacimy monetami zebranymi w tej rundzie, resztę z portfela
  const fromRun = Math.min(game.coins, cost);
  game.coins -= fromRun;
  if (cost - fromRun > 0) save.spend(cost - fromRun);
  continuesUsed++;
  clearTimeout(contTimer);
  hide('over');
  show('hud');
  $('#hud-coins').textContent = game.coins;
  mode = 'play';
  sfx.buy();
  game.revive();
}

function toMenu() {
  if (mode === 'over') finalizeRun();
  game.running = false;
  ['over', 'pause', 'hud'].forEach(hide);
  closeOverlays();
  show('menu');
  mode = 'menu';
  renderAll();
}

function pause() {
  if (mode !== 'play') return;
  mode = 'pause';
  game.setPaused(true);
  show('pause');
}
function resume() {
  hide('pause');
  mode = 'play';
  game.setPaused(false);
}

// ---------- sterowanie: dotyk + klawiatura ----------
let touch = null;
addEventListener('touchstart', (e) => {
  if (mode !== 'play') return;
  const t = e.changedTouches[0];
  touch = { x: t.clientX, y: t.clientY, used: false };
}, { passive: true });
addEventListener('touchmove', (e) => {
  if (!touch || touch.used || mode !== 'play') return;
  const t = e.changedTouches[0];
  const dx = t.clientX - touch.x, dy = t.clientY - touch.y;
  if (Math.max(Math.abs(dx), Math.abs(dy)) < 28) return;
  touch.used = true;
  handleSwipe(Math.abs(dx) > Math.abs(dy) ? (dx > 0 ? 'right' : 'left') : (dy > 0 ? 'down' : 'up'));
}, { passive: true });
addEventListener('touchend', (e) => {
  if (touch && !touch.used && mode === 'play' && !e.target.closest('button')) {
    // tap: lewa/prawa połowa ekranu = zmiana pasa
    const t = e.changedTouches[0];
    handleSwipe(t.clientX < innerWidth / 2 ? 'left' : 'right');
  }
  touch = null;
});
addEventListener('keydown', (e) => {
  const map = { ArrowLeft: 'left', a: 'left', ArrowRight: 'right', d: 'right', ArrowUp: 'up', w: 'up', ' ': 'up', ArrowDown: 'down', s: 'down' };
  if (map[e.key] && mode === 'play') { e.preventDefault(); handleSwipe(map[e.key]); }
  if (e.key === 'Escape') mode === 'play' ? pause() : mode === 'pause' && resume();
});
function handleSwipe(dir) {
  if (dir === 'left' && game.move(-1)) { sfx.lane(); haptic.light(); }
  if (dir === 'right' && game.move(1)) { sfx.lane(); haptic.light(); }
  if (dir === 'up' && game.jump()) sfx.jump();
  if (dir === 'down') game.drop();
}

// ---------- sklep ----------
function selectTab(tab) {
  $$('.tabs button').forEach((b) => b.classList.toggle('active', b.dataset.tab === tab));
  $$('.tab-body').forEach((b) => b.classList.toggle('active', b.id === 'tab-' + tab));
}

function renderCoinsTab() {
  const el = $('#tab-coins');
  el.innerHTML = '';
  for (const p of IAP_PRODUCTS) {
    const owned = billing.owned(p.id);
    if (p.id === 'starter_pack' && owned) continue;
    const card = document.createElement('div');
    card.className = 'card' + (p.type === 'non-consumable' ? ' feature' : '');
    card.innerHTML = `
      ${p.badge ? `<span class="badge">${p.badge}</span>` : ''}
      <div class="ico">${p.icon}</div>
      <div class="info"><b>${p.coins && p.type === 'consumable' ? p.coins.toLocaleString('pl-PL') + ' monet' : p.title}</b>
        <small>${p.desc || (p.type === 'consumable' ? p.title : 'Każda zebrana moneta liczy się podwójnie')}</small></div>
      <button class="btn gold-btn act" data-buy="${p.id}" ${owned ? 'disabled' : ''}>${owned ? 'Kupione ✓' : `<span data-price="${p.id}"></span>`}</button>`;
    el.appendChild(card);
  }
  const note = document.createElement('p');
  note.className = 'note';
  note.textContent = billing.isNative() ? 'Płatności obsługuje Google Play.' : 'Tryb testowy przeglądarki – płatności są symulowane.';
  el.appendChild(note);
  refreshPrices();
}

function renderSkinsTab() {
  const el = $('#tab-skins');
  el.innerHTML = '<div class="grid"></div>';
  const grid = el.firstChild;
  for (const sk of SKINS) {
    const owned = S().ownedSkins.includes(sk.id);
    const sel = S().skin === sk.id;
    const hex = (n) => '#' + n.toString(16).padStart(6, '0');
    const card = document.createElement('div');
    card.className = 'card skin' + (sel ? ' sel' : '');
    let action;
    if (sel) action = '<button class="btn" disabled>Wybrana</button>';
    else if (owned) action = `<button class="btn" data-equip="${sk.id}">Wybierz</button>`;
    else if (sk.exclusive) action = `<button class="btn gold-btn" data-buy="starter_pack">🎁 Pakiet</button>`;
    else action = `<button class="btn gold-btn" data-skin="${sk.id}">🪙 ${sk.price.toLocaleString('pl-PL')}</button>`;
    card.innerHTML = `<div class="swatch" style="background: radial-gradient(circle at 35% 30%, #fff 0, ${hex(sk.color)} 30%, ${hex(sk.emissive)} 100%); box-shadow: 0 0 18px ${hex(sk.trail)}"></div>
      <b>${sk.name}</b>${action}`;
    grid.appendChild(card);
  }
}

function renderUpgradesTab() {
  const el = $('#tab-upgrades');
  el.innerHTML = '';
  for (const u of UPGRADES) {
    const lvl = S().upgrades[u.id];
    const max = lvl >= u.maxLevel;
    const val = u.base + u.step * lvl;
    const card = document.createElement('div');
    card.className = 'card';
    card.innerHTML = `<div class="ico">${u.icon}</div>
      <div class="info"><b>${u.name}</b><small>${u.desc} · teraz ${val}${u.isMult ? '' : ' '}${u.unit}</small>
        <div class="lvl">${Array.from({ length: u.maxLevel }, (_, i) => `<i class="${i < lvl ? 'on' : ''}"></i>`).join('')}</div></div>
      <button class="btn gold-btn act" data-upgrade="${u.id}" ${max ? 'disabled' : ''}>${max ? 'MAX' : '🪙 ' + upgradeCost(lvl).toLocaleString('pl-PL')}</button>`;
    el.appendChild(card);
  }
}

function refreshPrices() {
  $$('[data-price]').forEach((e) => { e.textContent = billing.price(e.dataset.price); });
}

function renderAll() {
  $$('.coins').forEach((e) => { e.textContent = S().coins.toLocaleString('pl-PL'); });
  $('#best').textContent = S().best;
  $('#daily-dot').classList.toggle('hidden', !dailyAvailable());
  renderCoinsTab();
  renderSkinsTab();
  renderUpgradesTab();
}

async function buy(id) {
  sfx.click();
  show('busy');
  try {
    await billing.buy(id);
  } catch (e) {
    toast('❌ ' + (e.message || 'Zakup nieudany'));
  } finally {
    hide('busy');
  }
}

billing.onDelivered((p) => {
  sfx.buy();
  haptic.success();
  toast(p.type === 'consumable' ? `✅ +${p.coins.toLocaleString('pl-PL')} monet!` : `✅ ${p.title} – dziękujemy!`, 3000);
  if (p.id === 'double_coins' && mode === 'play') game.coinValue *= 2;
  renderAll();
});
billing.onChange(() => { refreshPrices(); });
save.onChange(() => {
  $$('.coins').forEach((e) => { e.textContent = S().coins.toLocaleString('pl-PL'); });
});

// ---------- nagroda dzienna ----------
const today = () => new Date().toISOString().slice(0, 10);
const yesterday = () => new Date(Date.now() - 864e5).toISOString().slice(0, 10);
const dailyAvailable = () => S().daily.last !== today();

function renderDaily() {
  const d = S().daily;
  const streak = d.last === today() || d.last === yesterday() ? d.streak : 0;
  const idx = dailyAvailable() ? streak % 7 : (streak - 1) % 7;
  $('#days').innerHTML = DAILY_REWARDS.map((r, i) =>
    `<div class="day ${i < idx || (!dailyAvailable() && i === idx) ? 'done' : ''} ${i === idx && dailyAvailable() ? 'today' : ''}">Dzień ${i + 1}<b>🪙 ${r}</b></div>`).join('');
  $('#btn-claim').disabled = !dailyAvailable();
  $('#btn-claim').textContent = dailyAvailable() ? 'ODBIERZ' : 'Wróć jutro!';
}

function claimDaily() {
  if (!dailyAvailable()) return;
  const d = S().daily;
  d.streak = d.last === yesterday() ? d.streak + 1 : 1;
  d.last = today();
  const reward = DAILY_REWARDS[(d.streak - 1) % 7];
  save.addCoins(reward);
  sfx.buy();
  haptic.success();
  toast(`🎁 +${reward} monet!`);
  renderDaily();
  renderAll();
}

// ---------- zdarzenia UI ----------
document.addEventListener('click', (e) => {
  const b = e.target.closest('button, [data-open]');
  if (!b) return;
  if (b.dataset.open) { openOverlay(b.dataset.open); if (b.dataset.tab) selectTab(b.dataset.tab); if (b.dataset.open === 'daily') renderDaily(); return; }
  if (b.dataset.tab && b.closest('.tabs')) { selectTab(b.dataset.tab); sfx.click(); return; }
  if (b.hasAttribute('data-close')) { closeOverlays(); sfx.click(); if (mode === 'over' && !runFinalized) armContinue(); return; }
  if (b.dataset.buy) return buy(b.dataset.buy);
  if (b.dataset.equip) { S().skin = b.dataset.equip; save.commit(); game.setSkin(b.dataset.equip); sfx.click(); renderSkinsTab(); return; }
  if (b.dataset.skin) {
    const sk = SKINS.find((s) => s.id === b.dataset.skin);
    if (!save.spend(sk.price)) { toast('Za mało monet'); selectTab('coins'); return; }
    S().ownedSkins.push(sk.id); S().skin = sk.id; save.commit();
    game.setSkin(sk.id); sfx.buy(); haptic.success(); toast(`🎨 Odblokowano: ${sk.name}`);
    renderSkinsTab(); return;
  }
  if (b.dataset.upgrade) {
    const id = b.dataset.upgrade;
    if (!save.spend(upgradeCost(S().upgrades[id]))) { toast('Za mało monet'); selectTab('coins'); return; }
    S().upgrades[id]++; save.commit(); sfx.buy(); haptic.success();
    renderUpgradesTab(); return;
  }
});

$('#btn-play').onclick = startGame;
$('#btn-again').onclick = () => { finalizeRun(); startGame(); };
$('#btn-menu').onclick = toMenu;
$('#btn-continue').onclick = tryContinue;
$('#btn-pause').onclick = pause;
$('#btn-resume').onclick = resume;
$('#btn-quit').onclick = () => { game.running = false; game.coins = 0; toMenu(); };
$('#btn-daily').onclick = () => { openOverlay('daily'); renderDaily(); };
$('#btn-claim').onclick = claimDaily;
$('#btn-settings').onclick = () => {
  $('#set-sound').checked = S().settings.sound;
  $('#set-haptics').checked = S().settings.haptics;
  $('#set-quality').checked = S().settings.quality === 'high';
  openOverlay('settings');
};
$('#set-sound').onchange = (e) => { S().settings.sound = e.target.checked; save.commit(); };
$('#set-haptics').onchange = (e) => { S().settings.haptics = e.target.checked; save.commit(); };
$('#set-quality').onchange = (e) => { S().settings.quality = e.target.checked ? 'high' : 'low'; save.commit(); game.setQuality(S().settings.quality); };
$('#btn-restore').onclick = async () => {
  show('busy');
  try { await billing.restore(); toast(billing.isNative() ? '✅ Zakupy przywrócone' : 'Dostępne tylko w aplikacji'); } finally { hide('busy'); renderAll(); }
};

// ---------- Android: przycisk wstecz, wstrzymanie aplikacji ----------
if (Capacitor.isNativePlatform()) {
  App.addListener('backButton', () => {
    if (overlayOpen()) { closeOverlays(); if (mode === 'over' && !runFinalized) armContinue(); }
    else if (mode === 'play') pause();
    else if (mode === 'pause') resume();
    else if (mode === 'over') toMenu();
    else App.exitApp();
  });
  App.addListener('appStateChange', ({ isActive }) => { if (!isActive) pause(); });
}
document.addEventListener('visibilitychange', () => { if (document.hidden) pause(); });

// ---------- start ----------
renderAll();
billing.init().then(() => { renderAll(); }).catch((e) => console.warn(e));
