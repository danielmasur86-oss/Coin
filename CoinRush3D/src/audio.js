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
