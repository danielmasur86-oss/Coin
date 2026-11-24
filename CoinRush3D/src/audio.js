// Proceduralne efekty dźwiękowe (WebAudio) – bez plików audio, zero problemów z licencjami.
import { save } from './save.js';

let ctx;
const ac = () => (ctx ||= new (window.AudioContext || window.webkitAudioContext)());

function tone(freq, dur, type = 'sine', vol = 0.15, slide = 0) {
  if (!save.get().settings.sound) return;
  const c = ac();
  const o = c.createOscillator();
  const g = c.createGain();
  o.type = type;
  o.frequency.setValueAtTime(freq, c.currentTime);
  if (slide) o.frequency.exponentialRampToValueAtTime(Math.max(30, freq + slide), c.currentTime + dur);
  g.gain.setValueAtTime(vol, c.currentTime);
  g.gain.exponentialRampToValueAtTime(0.0001, c.currentTime + dur);
  o.connect(g).connect(c.destination);
  o.start();
  o.stop(c.currentTime + dur);
}

let coinPitch = 0, lastCoin = 0;
export const sfx = {
  unlock() { try { ac().resume(); } catch {} },
  coin() {
    const now = performance.now();
    coinPitch = now - lastCoin < 400 ? Math.min(coinPitch + 1, 10) : 0;
    lastCoin = now;
    tone(880 * Math.pow(2, coinPitch / 12), 0.12, 'triangle', 0.12);
  },
  jump: () => tone(300, 0.2, 'sine', 0.15, 400),
  lane: () => tone(500, 0.05, 'square', 0.03),
  power: () => { tone(523, 0.15, 'triangle'); setTimeout(() => tone(784, 0.25, 'triangle'), 90); },
  shieldBreak: () => tone(900, 0.3, 'sawtooth', 0.08, -700),
  crash: () => { tone(160, 0.5, 'sawtooth', 0.2, -120); tone(80, 0.6, 'square', 0.12, -40); },
  buy: () => [523, 659, 784, 1046].forEach((f, i) => setTimeout(() => tone(f, 0.18, 'triangle', 0.12), i * 70)),
  click: () => tone(660, 0.04, 'square', 0.04),
};

// ---------- Muzyka w tle: wesoła bajkowa melodia generowana na żywo ----------
const N = (n) => 440 * Math.pow(2, (n - 69) / 12); // numer MIDI -> Hz
const CHORDS = [[60, 64, 67], [57, 60, 64], [53, 57, 60], [55, 59, 62]]; // C, Am, F, G
const MELODY = [
  76, 0, 79, 0, 77, 76, 74, 0, 72, 0, 74, 76, 79, 0, 0, 0,
  76, 0, 72, 0, 74, 0, 76, 74, 72, 0, 69, 0, 72, 0, 0, 0,
  77, 0, 76, 0, 74, 0, 72, 0, 74, 76, 77, 0, 79, 0, 81, 0,
  79, 0, 77, 76, 74, 0, 71, 0, 72, 0, 0, 0, 0, 0, 0, 0,
];
let timer = null, step = 0, nextT = 0, master = null;

function note(freq, t, dur, type, vol) {
  const c = ac();
  const o = c.createOscillator(), g = c.createGain();
  o.type = type;
  o.frequency.setValueAtTime(freq, t);
  g.gain.setValueAtTime(0.0001, t);
  g.gain.exponentialRampToValueAtTime(vol, t + 0.01);
  g.gain.exponentialRampToValueAtTime(0.0001, t + dur);
  o.connect(g).connect(master);
  o.start(t);
  o.stop(t + dur + 0.02);
}

export const music = {
  start() {
    if (timer || !save.get().settings.sound) return;
    const c = ac();
    if (!master) { master = c.createGain(); master.connect(c.destination); }
    master.gain.cancelScheduledValues(c.currentTime);
    master.gain.setValueAtTime(0.0001, c.currentTime);
    master.gain.exponentialRampToValueAtTime(0.5, c.currentTime + 0.6);
    const spb = 60 / 132 / 2; // ósemki przy 132 BPM
    nextT = c.currentTime + 0.05;
    timer = setInterval(() => {
      while (nextT < c.currentTime + 0.25) {
        const bar = Math.floor(step / 16) % 4, s16 = step % 16;
        const chord = CHORDS[bar];
        if (s16 % 4 === 0) note(N(chord[0] - 24), nextT, spb * 3.5, 'triangle', 0.22);
        note(N(chord[s16 % 3] + 12), nextT, spb * 0.9, 'sine', 0.05);
        const m = MELODY[step % MELODY.length];
        if (m) note(N(m), nextT, spb * 1.8, 'triangle', 0.09);
        if (s16 % 4 === 2) note(N(96), nextT, 0.03, 'square', 0.012);
        nextT += spb;
        step++;
      }
    }, 60);
  },
  stop() {
    if (!timer) return;
    clearInterval(timer);
    timer = null;
    const c = ac();
    master.gain.cancelScheduledValues(c.currentTime);
    master.gain.setValueAtTime(master.gain.value, c.currentTime);
    master.gain.exponentialRampToValueAtTime(0.0001, c.currentTime + 0.3);
  },
};
