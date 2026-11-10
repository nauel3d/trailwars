import fs from 'node:fs/promises';import path from 'node:path';import {createRequire} from 'node:module';import {fileURLToPath} from 'node:url';
const r=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const pkg=process.env.TRAILWARS_NODE_MODULES||'C:/Users/User/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const sharp=createRequire(import.meta.url)(path.join(pkg,'sharp'));
const pages=JSON.parse(await fs.readFile(path.join(r,'manifest.json'),'utf8'));
for(const p of pages)await sharp(path.join(r,'qa/raster-input',p.id+'.svg')).png().toFile(path.join(r,'exports',p.id+'.png'));
for(const id of ['a-home-desktop','a-results-desktop'])await sharp(path.join(r,'qa/raster-input',id+'.svg'),{density:144}).png().toFile(path.join(r,'exports',id+'-1920.png'));
const selected=pages.filter(p=>p.file.startsWith('concepts/')&&p.id.includes('desktop'));const cards=[];
for(let i=0;i<selected.length;i++){const p=selected[i];cards.push({input:await sharp(path.join(r,'exports',p.id+'.png')).resize(640,360).toBuffer(),left:(i%3)*640,top:Math.floor(i/3)*390+30});cards.push({input:Buffer.from(`<svg width="640" height="28"><text x="12" y="22" font-family="Arial" font-size="18" fill="#20334C">${p.id}</text></svg>`),left:(i%3)*640,top:Math.floor(i/3)*390});}
await sharp({create:{width:1920,height:1170,channels:3,background:'#DDD9CF'}}).composite(cards).png().toFile(path.join(r,'exports/concept-comparison.png'));
for(const f of ['hover-racer','homing-rocket','turret-rocket','action-face-9slice','quiet-panel-9slice'])await sharp(path.join(r,'component-designs',f+'.svg')).png().toFile(path.join(r,'component-designs',f+'.png'));
const montage=[];const names=['a-home-desktop','a-home-portrait','a-hud-desktop','a-results-portrait'];
for(let i=0;i<names.length;i++){const input=await sharp(path.join(r,'exports',names[i]+'.png')).resize({width:i%2?300:960,height:650,fit:'contain',background:'#EFEDE5'}).toBuffer();montage.push({input,left:i%2?960:0,top:Math.floor(i/2)*690+30});}
await sharp({create:{width:1260,height:1380,channels:3,background:'#EFEDE5'}}).composite(montage).png().toFile(path.join(r,'exports/recommended-preview.png'));
console.log(`Exported ${pages.length} PNG proposals and comparison`);
