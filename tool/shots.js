// Kullanım: node tool/shots.js  (build/web sunulurken: python3 -m http.server 8765 -d build/web)
const { chromium } = require('playwright');
const path = require('path');
const out = path.join(__dirname, '..', 'comparison');
const shots = [
  ['01', 'tab=0&scroll=0'],
  ['02', 'tab=0&scroll=SCROLL2&compact=1'],
  ['03', 'tab=0&scroll=SCROLL3'],
  ['04', 'tab=1&scroll=0'],
  ['05', 'tab=1&scroll=306'],
  ['06', 'tab=2&scroll=0'],
  ['07', 'tab=2&scroll=SCROLL7'],
  ['08', 'tab=2&scroll=SCROLL8&compact=1'],
];
const S = JSON.parse(process.env.SCROLLS || '{}');
(async () => {
  const b = await chromium.launch({ args: ['--use-gl=swiftshader', '--enable-unsafe-swiftshader'] });
  const only = process.argv[2];
  for (const [n, q0] of shots) {
    if (only && !only.split(',').includes(n)) continue;
    const q = q0.replace(/SCROLL(\d)/, (_, k) => S[k] ?? 0);
    const ctx = await b.newContext({ viewport: { width: 430, height: 932 }, deviceScaleFactor: 923 / 430 });
    const p = await ctx.newPage();
    p.on('console', m => { if (m.type() === 'error') console.log('console:', m.text().slice(0, 200)); });
    await p.goto('http://localhost:8765/?' + q);
    await p.waitForTimeout(6000);
    await p.screenshot({ path: `${out}/app_${n}.png` });
    await ctx.close();
    console.log('shot', n, q);
  }
  await b.close();
})();
