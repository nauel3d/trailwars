// Standalone research-gallery verification. No reference-game or desktop control.
import fs from 'node:fs/promises';
import path from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath,pathToFileURL} from 'node:url';
import assert from 'node:assert/strict';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'../..');
const dependencies=process.env.TRAILWARS_NODE_MODULES||'C:/Users/User/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const {chromium}=createRequire(import.meta.url)(path.join(dependencies,'playwright'));
const browser=await chromium.launch({headless:true,channel:process.env.TRAILWARS_BROWSER_CHANNEL||'msedge'});
const errors=[]; const results=[];
try {
  for(const size of [{width:1080,height:1060},{width:320,height:1120}]) {
    const page=await browser.newPage({viewport:size});
    page.on('pageerror',e=>errors.push(e.message));
    await page.goto(pathToFileURL(path.join(root,'research/match-and-powers/11-review-gallery.html')).href);
    await page.waitForTimeout(1900);
    let state=await page.evaluate(()=>window.reviewState());
    assert.equal(state.rows.find(r=>r.id==='sun').total,9);
    assert.equal(state.rows.find(r=>r.id==='you').total,8);
    assert.equal(state.rows.find(r=>r.id==='sun').position,'translateY(0px)');
    const bounds=await page.evaluate(()=>({document:document.documentElement.scrollWidth,viewport:innerWidth,logo:document.querySelector('header img').naturalWidth}));
    assert.ok(bounds.document<=bounds.viewport,'Review gallery must not overflow horizontally');
    assert.ok(bounds.logo>0,'Existing SNAP wordmark loads');
    await page.screenshot({path:path.join(root,`research/match-and-powers/11-review-${size.width}.png`),fullPage:true});
    await page.getByRole('button',{name:'Show final results'}).click();
    state=await page.evaluate(()=>window.reviewState());
    assert.equal(state.rows.find(r=>r.id==='sun').total,15);
    await page.getByRole('checkbox',{name:'Reduced motion'}).check();
    state=await page.evaluate(()=>window.reviewState());
    assert.equal(state.rows.find(r=>r.id==='sun').total,9);
    assert.equal(state.timers,0,'Reduced motion settles with no queued timers');
    results.push({viewport:size,interRoundLeader:'SUN',interRoundLeaderPoints:9,finalLeaderPoints:15,reducedMotion:true,horizontalOverflow:false});
    await page.close();
  }
  assert.deepEqual(errors,[],'No gallery runtime errors');
  await fs.writeFile(path.join(root,'research/match-and-powers/11-review-verification.json'),JSON.stringify({kind:'Original HTML research proposal; not Roblox',results,errors},null,2)+'\n');
  console.log(JSON.stringify({passed:true,viewports:results.length,errors}));
} finally { await browser.close(); }
