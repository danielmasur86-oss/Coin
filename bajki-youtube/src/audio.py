"""Synthesises an original soundtrack (music, rain, thunder) for one episode and writes SRT subtitles.
Usage: python3 audio.py <episode_number>"""
import json, sys, wave
from pathlib import Path
import numpy as np

SR = 44100
ep = int(sys.argv[1])
build = Path(__file__).resolve().parent.parent / "build"
meta = json.loads((build / f"ep{ep}.json").read_text())
total = meta["total"]
n = int(total * SR) + SR
rng = np.random.default_rng(ep)
t_all = np.arange(n) / SR


def note(freq, dur, amp):
    t = np.arange(int(dur * SR)) / SR
    env = np.exp(-t * 5.5) * np.minimum(1, t * 200)
    return amp * env * (np.sin(2 * np.pi * freq * t) + 0.3 * np.sin(4 * np.pi * freq * t) + 0.08 * np.sin(6 * np.pi * freq * t))


def add(buf, start, sig):
    i = int(start * SR)
    j = min(len(buf), i + len(sig))
    if i < len(buf):
        buf[i:j] += sig[: j - i]


hz = lambda m: 440 * 2 ** ((m - 69) / 12)
music = np.zeros(n)
beat = 60 / 104
# C major pentatonic melody, 4 bars of 8 eighth-notes, original
mel = [72, 76, 79, 76, 74, 72, 74, 76,  79, 81, 79, 76, 74, 76, 72, None,
       72, 74, 76, 79, 81, 84, 81, 79,  76, 74, 72, 74, 76, 74, 72, None]
bass = [48, 43, 45, 43, 48, 43, 41, 43]  # one per bar (2 per 4-bar phrase pair)
chords = [[60, 64, 67], [55, 59, 62], [57, 60, 64], [55, 59, 62]]
pos = 0.0
k = 0
while pos < total:
    m = mel[k % len(mel)]
    if m:
        add(music, pos, note(hz(m), 0.6, 0.16))
    if k % 8 == 0:
        bar = (k // 8) % 4
        add(music, pos, note(hz(bass[(k // 8) % len(bass)]), 1.6, 0.22))
        for c in chords[bar]:
            add(music, pos + beat, note(hz(c), 1.0, 0.045))
            add(music, pos + 3 * beat, note(hz(c), 1.0, 0.045))
    pos += beat / 2
    k += 1

# intro sparkle and ending chord
for i, m in enumerate([72, 76, 79, 84, 88]):
    add(music, 0.2 + i * 0.12, note(hz(m), 0.8, 0.12))
for m in [60, 64, 67, 72, 76]:
    add(music, total - 4.6, note(hz(m), 3.5, 0.09))

# volume: duck during rain, fade out at end
vol = np.ones(n)
rain = np.zeros(n)
noise = rng.standard_normal(n)
lp = np.zeros(n)
a = 0.35
for i in range(1, n):  # one-pole low-pass for soft rain
    lp[i] = lp[i - 1] + a * (noise[i] - lp[i - 1])
for s, e in meta["rain"]:
    w = np.clip(np.minimum(t_all - s, e - t_all) / 1.0, 0, 1)
    rain = np.maximum(rain, w)
    vol = np.minimum(vol, 1 - 0.45 * w)
rain_sig = 0.09 * lp * rain
fade = np.clip((total - t_all) / 2.5, 0, 1)
music *= vol * fade

thunder = np.zeros(n)
for tt in meta["thunder"]:
    d = 2.8
    m = int(d * SR)
    br = np.cumsum(rng.standard_normal(m))
    br -= np.convolve(br, np.ones(400) / 400, mode="same")
    br /= np.abs(br).max() + 1e-9
    tt_ = np.arange(m) / SR
    env = np.minimum(1, tt_ * 30) * np.exp(-tt_ * 1.6) * (1 + 0.5 * np.sin(tt_ * 9))
    add(thunder, tt + 0.12, 0.55 * br * env)

mix = music + rain_sig + thunder
mix /= max(1.0, np.abs(mix).max() / 0.89)
pcm = (mix * 32767).astype(np.int16)
with wave.open(str(build / f"ep{ep}.wav"), "wb") as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(pcm.tobytes())


def ts(x):
    ms = int(round(x * 1000))
    return f"{ms // 3600000:02}:{ms // 60000 % 60:02}:{ms // 1000 % 60:02},{ms % 1000:03}"


srt = "\n".join(f"{i + 1}\n{ts(s['a'])} --> {ts(s['b'])}\n{s['t']}\n" for i, s in enumerate(meta["subs"]))
(build / f"ep{ep}.srt").write_text(srt, encoding="utf-8")
print(f"ep{ep}: audio {total:.1f}s, {len(meta['thunder'])} thunders")
