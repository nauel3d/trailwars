// Local generated-artifact verification only. Never connects to Roblox or a live website.
import fs from 'node:fs/promises';import path from 'node:path';import {createRequire} from 'node:module';import {fileURLToPath,pathToFileURL} from 'node:url';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const pkg=process.env.TRAILWARS_NODE_MODULES||'C:/Users/User/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const {chromium}=createRequire(import.meta.url)(path.join(pkg,'playwright'));
const browser=await chromium.launch({headless:true,executablePath:'C:/Program Files/Google/Chrome/Application/chrome.exe'});
const page=await browser.newPage({viewport:{width:1440,height:1000}});const errors=[];page.on('pageerror',e=>errors.push(e.message));
await page.goto(pathToFileURL(path.join(root,'review-gallery.html')).href);await page.evaluate(()=>document.fonts.ready);
const links=await page.locator('[href],[src]').evaluateAll(els=>els.flatMap(el=>['href','src'].map(a=>el.getAttribute(a)).filter(Boolean)));
const missing=[];for(const link of links){if(/^(https?:|data:|#)/.test(link))continue;try{await fs.access(path.resolve(root,decodeURIComponent(link.split('#')[0])))}catch{missing.push(link)}}
await page.screenshot({path:path.join(root,'qa/gallery-desktop.png')});
await page.locator('[data-filter="portrait"]').click();const shown=await page.locator('#screens > div:visible').count();if(shown<9)throw Error('Missing portrait screen family');
await page.setViewportSize({width:390,height:844});await page.goto(pathToFileURL(path.join(root,'review-gallery.html')).href);await page.screenshot({path:path.join(root,'qa/gallery-phone.png')});const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth);if(overflow)throw Error('Gallery horizontal overflow');
await page.goto(pathToFileURL(path.join(root,'motion-storyboards/interactive-preview.html')).href);await page.locator('#play').click();await page.waitForTimeout(1150);let rows=await page.locator('.row').evaluateAll(els=>els.map(el=>({id:el.dataset.id,y:el.dataset.y,score:el.querySelector('.score').textContent})));if(rows.find(r=>r.id==='you').y!=='0'||rows.find(r=>r.id==='you').score!=='43')throw Error('Rank animation failed');
for(let i=0;i<4;i++){await page.locator('#play').click();await page.waitForTimeout(50);await page.locator('#skip').click();}await page.locator('#reduce').check();await page.locator('#play').click();if(!(await page.locator('#message').textContent()).includes('Reduced motion'))throw Error('Reduced motion did not settle');
const report={ok:!errors.length&&!missing.length,boards:JSON.parse(await fs.readFile(path.join(root,'manifest.json'),'utf8')).length,localLinkReferences:links.length,missing,pageErrors:errors,portraitFamiliesShown:shown,phoneGalleryOverflow:overflow,motion:{scoreAndRank:true,repeatedInterruptions:4,reducedMotion:true},scope:'Local design/gallery check; not Roblox engine, GPU, gameplay, physical-device or audio certification'};
await fs.writeFile(path.join(root,'qa/gallery-check.json'),JSON.stringify(report,null,2));console.log(JSON.stringify(report));await browser.close();if(!report.ok)process.exitCode=1;
