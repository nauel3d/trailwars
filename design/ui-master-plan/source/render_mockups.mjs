// Local design export only; does not connect to Roblox or author runtime UI.
import fs from 'node:fs/promises';
import path from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath} from 'node:url';
const here=path.dirname(fileURLToPath(import.meta.url));
const plan=path.dirname(here), root=path.resolve(plan,'../..');
const pkg=process.env.TRAILWARS_NODE_MODULES || 'C:/Users/User/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules';
const config=path.join(here,'fontconfig.xml');
await fs.writeFile(config,`<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><dir>${path.join(here,'fonts').replaceAll('\\','/')}</dir><dir>C:/Windows/Fonts</dir><cachedir>${path.join(plan,'qa/font-cache').replaceAll('\\','/')}</cachedir></fontconfig>`);
process.env.FONTCONFIG_FILE=config;
const sharp=createRequire(import.meta.url)(path.join(pkg,'sharp'));
const pages=JSON.parse(await fs.readFile(path.join(plan,'mockup-manifest.json'),'utf8'));
const cache=new Map();
async function embedded(file){if(!cache.has(file))cache.set(file,'data:image/png;base64,'+(await fs.readFile(file)).toString('base64'));return cache.get(file);}
for(const page of pages){
 const file=path.join(plan,'qa/raster-input',page.slug+'.svg');let svg=await fs.readFile(file,'utf8');
 const urls=[...new Set([...svg.matchAll(/xlink:href="([^\"]+)"/g)].map(m=>m[1]))].filter(u=>!u.startsWith('data:'));
 for(const url of urls)svg=svg.replaceAll(url,await embedded(path.resolve(plan,'mockups',url)));
 await sharp(Buffer.from(svg)).png().toFile(path.join(plan,'mockups',page.slug+'.png'));
}
const cards=[];const cw=334,ch=240,cols=5;const rows=Math.ceil(pages.length/cols);
for(let i=0;i<pages.length;i++){
 const p=pages[i];const input=await sharp(path.join(plan,'mockups',p.slug+'.png')).resize({width:326,height:207,fit:'inside'}).toBuffer();
 const meta=await sharp(input).metadata();const x=(i%cols)*cw+(cw-meta.width)/2,y=Math.floor(i/cols)*ch+26;
 cards.push({input,left:Math.round(x),top:Math.round(y)});
 cards.push({input:Buffer.from(`<svg width="334" height="24"><text x="5" y="18" font-family="Arial" font-size="13" fill="#382037">${p.slug}</text></svg>`),left:(i%cols)*cw,top:Math.floor(i/cols)*ch});
}
await sharp({create:{width:cols*cw,height:rows*ch,channels:3,background:'#EEE7DF'}}).composite(cards).jpeg({quality:90}).toFile(path.join(plan,'qa/contact-sheet.jpg'));
console.log(JSON.stringify({rendered:pages.length,root,contactSheet:'qa/contact-sheet.jpg'}));
