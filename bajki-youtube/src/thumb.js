// Makes a 1280x720 YouTube thumbnail per episode from a chosen scene moment.
const { chromium } = require('playwright');
const path = require('path');
const PICK = [[0, 33, 'Gdzie jest\nzłoty żołądź?'], [1, 17.8, 'Boję się\nburzy!'], [2, 29, 'Niespodzianka\nna urodziny!']];
(async () => {
  const b = await chromium.launch();
  const pg = await b.newPage({ viewport: { width: 1920, height: 1080 } });
  await pg.goto('file://' + path.join(__dirname, 'render.html'));
  await pg.evaluate(() => document.fonts.ready);
  for (const [ep, t, title] of PICK) {
    await pg.evaluate(([ep, t, title]) => {
      setup(ep); setT(t);
      document.getElementById('sub').style.opacity = 0;
      document.getElementById('card').style.opacity = 0;
      let o = document.getElementById('thumb');
      if (!o) { o = document.createElement('div'); o.id = 'thumb'; document.body.append(o); }
      o.style.cssText = 'position:absolute;left:70px;top:50px;font:800 150px/0.95 "Baloo 2";color:#fff;white-space:pre;-webkit-text-stroke:14px #2a1a0c;paint-order:stroke fill;text-shadow:0 12px 0 #2a1a0c';
      o.textContent = title;
      let tag = document.getElementById('tag');
      if (!tag) { tag = document.createElement('div'); tag.id = 'tag'; document.body.append(tag); }
      tag.style.cssText = 'position:absolute;right:60px;top:60px;background:#ffc93c;color:#2a1a0c;font:800 56px "Baloo 2";padding:8px 34px 2px;border-radius:30px;border:8px solid #2a1a0c';
      tag.textContent = 'Odc. ' + (ep + 1);
    }, [ep, t, title]);
    const file = path.join(__dirname, '..', 'build', `miniatura-odcinek-${ep + 1}.png`);
    await pg.screenshot({ path: file + '.full.png' });
    require('child_process').execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-i', file + '.full.png', '-vf', 'scale=1280:720', file]);
    require('fs').unlinkSync(file + '.full.png');
  }
  await b.close();
})();
