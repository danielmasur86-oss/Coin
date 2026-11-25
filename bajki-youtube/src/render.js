// Renders each episode frame by frame to a silent H.264 MP4 and writes timing metadata.
// Usage: node render.js <episodeIndex> [fps] [--still t]
const { chromium } = require('playwright');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

(async () => {
  const ep = +process.argv[2];
  const fps = +(process.argv[3] || 25);
  const stillIdx = process.argv.indexOf('--still');
  const out = path.join(__dirname, '..', 'build');
  fs.mkdirSync(out, { recursive: true });
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
  await page.goto('file://' + path.join(__dirname, 'render.html'));
  await page.evaluate(() => document.fonts.ready);
  const meta = await page.evaluate(e => window.setup(e), ep);
  fs.writeFileSync(path.join(out, `ep${ep + 1}.json`), JSON.stringify(meta, null, 1));
  if (stillIdx > 0) {
    for (const t of process.argv.slice(stillIdx + 1)) {
      await page.evaluate(t => window.setT(t), +t);
      await page.screenshot({ path: path.join(out, `ep${ep + 1}-still-${t}.png`) });
    }
    await browser.close();
    return;
  }
  const frames = Math.ceil(meta.total * fps);
  const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(fps), '-i', '-',
    '-c:v', 'libx264', '-preset', 'medium', '-crf', '18', '-pix_fmt', 'yuv420p', path.join(out, `ep${ep + 1}-video.mp4`)],
    { stdio: ['pipe', 'inherit', 'inherit'] });
  for (let i = 0; i < frames; i++) {
    await page.evaluate(t => window.setT(t), i / fps);
    const buf = await page.screenshot({ type: 'jpeg', quality: 93 });
    if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
    if (i % 250 === 0) console.log(`ep${ep + 1}: ${i}/${frames}`);
  }
  ff.stdin.end();
  await new Promise(r => ff.on('close', r));
  await browser.close();
  console.log(`ep${ep + 1} done: ${frames} frames, ${meta.total.toFixed(1)} s`);
})();
